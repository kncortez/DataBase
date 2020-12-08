USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[sps_settlement_cod]    Script Date: 8/12/2020 00:13:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Carlos, Cano>
-- Create date: <2020-12-08>
-- Description:	<Guarda información para generar manifiesto de liquidación COD>
-- =============================================
CREATE PROCEDURE [dbo].[sps_settlement_cod]
		@IdManifest INT,
		@GuideQuantityCOD INT,
		@Token NVARCHAR(50)
AS
BEGIN
	
	-- control de actualizaciones para transacción
	DECLARE @RUpdated INT

	BEGIN TRANSACTION

		BEGIN TRY

			-- Actualizar registro en control de manifiestos de despacho
			UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement]
			SET
				User_Received_COD = @Token,
				Date_Received_COD = GETDATE(),
				--Pieces_Dry_Received = @PiecesDryReceived,
				--Pieces_Cold_Received = @PiecesColdReceived,
				Guides_Received_COD = @GuideQuantityCOD,
				Route_Received_COD = GETDATE()
			WHERE ID = @IdManifest

			SET @RUpdated = @@ROWCOUNT

		END TRY

		BEGIN CATCH
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID'
			ROLLBACK TRANSACTION
		END CATCH;

		IF @@TRANCOUNT > 0
		BEGIN
			IF (@IdManifest > 0)
				SELECT			  
					@IdManifest AS 'StatusCode',
					'Registro guardado correctamente' AS 'Description', 
					@@TRANCOUNT AS 'NumTransferID'
			ELSE
				SELECT			  
					0 AS 'StatusCode',
					'Registro no encontrado' AS 'Description', 
					0 AS 'NumTransferID'

			COMMIT TRANSACTION;			
		END
		ELSE
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID'

END
GO



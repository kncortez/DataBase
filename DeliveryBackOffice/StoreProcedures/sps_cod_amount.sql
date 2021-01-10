USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[sps_cod_amount]    Script Date: 8/01/2021 18:23:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Carlos, Cano>
-- Create date: <2020-12-08>
-- Description:	<Modifica el monto de valor COD en la guía origen>
-- =============================================
CREATE PROCEDURE [dbo].[sps_cod_amount]
		@GuideSerie NVARCHAR(2),
		@GuideNumber INT,
		@Amount DECIMAL(14,2),
		@IdManifest BIGINT,
		@Token NVARCHAR(50)
AS
BEGIN
	
	-- control de actualizaciones para transacción
	DECLARE @RUpdated INT

	BEGIN TRANSACTION

		BEGIN TRY

			-- Actualizar monto COD en tabla origen
			UPDATE DeliveryBackOffice.dbo.DeliveryOrder 
			SET Collect_OnDelivery = @Amount,
				User_Collect_OnDelivery = @Token, 
				Date_Collect_OnDelivery = GETDATE() 
			WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber

			-- Actualizar monto COD en proceso de liquidación
			UPDATE DeliveryBackOffice.dbo.DeliverySettlementDetail 
			SET Settlement_Collect_OnDelivery = @Amount
			WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber AND ID_DeliveryOrderBySettlement = @IdManifest

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
			IF (@RUpdated > 0)
				SELECT			  
					1 AS 'StatusCode',
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



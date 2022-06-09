

-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2021-04-28>
-- Description:	<Guarda información para generar manifiesto de liquidación>
-- =============================================
CREATE PROCEDURE [dbo].[sps_settlement_LinehaulsReturns]
		@IdManifest INT,
		@GuideQuantity INT,
		@RouteReceived DATETIME,
		@Token NVARCHAR(50)
AS
BEGIN
	
	-- control de actualizaciones para transacción
	DECLARE @RUpdated INT

	BEGIN TRANSACTION

		BEGIN TRY

			-- Actualizar registro en control de manifiestos de despacho

			update [DeliveryBackOffice].[dbo].[SettlementByPickup]
			set
				TokenUpdated = @Token,
				DateUpdated = GETDATE(),
				GuidesQuantityReceived = @GuideQuantity
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

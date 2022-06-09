


-- =============================================
-- Author:		<Cano, Carlos>
-- Create date: <2020-11-17>
-- Description:	<Guardar el monto liquidado en bodega>
-- =============================================
CREATE PROCEDURE [dbo].[sps_settlement_collect_ondelivery]
		@GuideSerie AS VARCHAR(2),
		@GuideNumber AS INT,
		@Amount DECIMAL(14,2),
		@Token NVARCHAR(50),
		@IdManifest INT
AS
BEGIN
	DECLARE @RModified INT

	BEGIN TRANSACTION

		BEGIN TRY
			
			UPDATE [DeliveryBackOffice].[dbo].[DeliverySettlementDetail]
			SET Settlement_Collect_OnDelivery = @Amount, SettlementCollect_TokenCreated = @Token, SettlementCollect_DateCreated = GETDATE(), Guide_Settlement = 1
			, Guide_Discharged = 1
			WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber AND ID_DeliveryOrderBySettlement = @IdManifest

			SET @RModified = @@ROWCOUNT
			
		END TRY

		BEGIN CATCH
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID',
				@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide',
				@Amount AS 'Amount'
			ROLLBACK TRANSACTION
		END CATCH;

		IF @@TRANCOUNT > 0
		BEGIN
			IF (@RModified > 0)
				SELECT			  
					1 AS 'StatusCode',
					'Registro guardado correctamente' AS 'Description', 
					@@TRANCOUNT AS 'NumTransferID',
					@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide',
					@Amount AS 'Amount'
			ELSE
				SELECT			  
					0 AS 'StatusCode',
					'Registro no encontrado' AS 'Description', 
					0 AS 'NumTransferID',
					@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide',
					@Amount AS 'Amount'

			COMMIT TRANSACTION;			
		END
		ELSE
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID',
				@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide',
				@Amount AS 'Amount'
END

USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[sps_settlement_guide_COD]    Script Date: 29/06/2021 19:02:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






-- =============================================
-- Author:		<Cano, Carlos>
-- Create date: <2020-11-25>
-- Description:	<Registrar transacción de liquidación (cobro) de guías en área de COD>
-- =============================================
ALTER PROCEDURE [dbo].[sps_settlement_guide_COD]
		@GuideSerie NVARCHAR(2),
		@GuideNumbers NVARCHAR(MAX),
		@Token NVARCHAR(50)
AS
BEGIN
	-- control de registros actualizados
	DECLARE @RModified INT
	-- control de guías a manipular
	DECLARE @GuidesTable AS TABLE (Guide_Number INT)

	BEGIN TRANSACTION

		BEGIN TRY
			
			-- Convertir la lista de guías separadas por coma en una tabla
			INSERT @GuidesTable
			SELECT CAST(Item AS INT) FROM DenariusDesktop_Dev.dbo.SplitUnlimited(@GuideNumbers,',')

			-- actualizar guía debido al proceso de liquidación
			UPDATE [DeliveryBackOffice].[dbo].[DeliverySettlementDetail]
			SET 
				GuideDischarged_TokenCreated = @Token, 
				GuideDischarged_DateCreated = GETDATE(), 
				Guide_Discharged = 1 -- guía liquidada en COD
			WHERE 
				Guide_Serie = @GuideSerie 
				AND Guide_Number IN (
					SELECT Guide_Number FROM @GuidesTable
				)
				AND Guide_Settlement = 1 -- guía liquidada previamente en bodega

			SET @RModified = @@ROWCOUNT

			INSERT INTO [dbo].[ProcessedGuideCOD]
					   ([GuideSerie]
					   ,[GuideNumber]
					   ,[CourierManId]
					   ,[Date]
					   ,[BatchCODId]
					   ,[BatchCODIdCommission]
					   ,[DataOriginId]
					   ,[Notificated]
					   ,[Token])
			SELECT @GuideSerie
					,da.[Guide_Number]
					,da.[ID_Courier]
					,GETDATE()
					,NULL
					,NULL
					,26
					,0
					,@Token
			FROM [dbo].[DeliveryAttempt] AS da
			INNER JOIN [dbo].[DeliveryOrder] AS do
				ON da.[Guide_Serie] = do.[Guide_Serie] 
			WHERE do.[Collect_OnDelivery] > 0
				AND da.[Guide_Serie] = @GuideSerie 
				AND da.[Guide_Number] IN (
					SELECT Guide_Number FROM @GuidesTable
				)
						
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
			IF (@RModified > 0)
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


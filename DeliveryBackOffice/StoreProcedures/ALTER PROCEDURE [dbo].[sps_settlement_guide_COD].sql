USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[sps_settlement_guide_COD]    Script Date: 2/07/2021 01:22:49 ******/
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
	-- control de guía a iterar
	DECLARE @GuideNumber INT
	-- CourierId de la guía a iterar
	DECLARE @CourierId INT

	BEGIN TRANSACTION

		BEGIN TRY
			
			IF OBJECT_ID('tempdb.dbo.#GuidesTemp', 'U') IS NOT NULL DROP TABLE #GuidesTemp;

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


			-- insertar guía en la tabla de guías procesadas COD
			-- Se insertar guías en tabla temporal
			SELECT * 
			INTO #GuidesTemp
			FROM @GuidesTable

			-- mientras la tabla no este vacía
			WHILE EXISTS(SELECT * FROM #GuidesTemp)
			BEGIN
				-- se obtiene la guía a iterar
				SELECT TOP 1 @GuideNumber = Guide_Number FROM #GuidesTemp

				-- se verifica que no exita en las guías procesadas
				IF NOT EXISTS 
					(SELECT 1
					FROM [dbo].[ProcessedGuideCOD]
					WHERE [GuideNumber] = @GuideNumber
				)
				BEGIN
					-- se obtiene el id del courierman
					SELECT TOP 1 @CourierId = ID_Courier 
					FROM [dbo].[DeliveryAttempt] 
					WHERE [Guide_Serie] = @GuideSerie
						AND [Guide_Number] = @GuideNumber
					
					-- se inserta en las guías procesadas si contine COD 
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
					SELECT do.[Guide_Serie]
						,do.[Guide_Number]
						,@CourierId
						,GETDATE()
						,NULL
						,NULL
						,26
						,0
						,@Token
					FROM [dbo].[DeliveryOrder] do
					WHERE do.[Guide_Number] = @GuideNumber
						AND do.[Guide_Serie] = @GuideSerie
						AND do.[Collect_OnDelivery] > 0
				END
				-- se elimina la guía de la tabla temporal
				DELETE #GuidesTemp WHERE Guide_Number = @GuideNumber
			END		
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


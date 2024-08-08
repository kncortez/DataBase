
-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2021-10-27>
-- Description:	<Registrar transacción de guías ya entregadas en Liquidación de Entregas>
-- =============================================
CREATE PROCEDURE [dbo].[sps_settlement_guide_delivered_overall]
	-- Add the parameters for the stored procedure here
	@InGuides NVARCHAR(MAX),
	@Token NVARCHAR(50),
	@IdManifest INT
AS
BEGIN
	DECLARE @RModified INT

	BEGIN TRANSACTION
		BEGIN TRY

			IF OBJECT_ID('tempdb.dbo.#listGuidesoOverall', 'U') IS NOT NULL
			DROP TABLE #listGuidesoOverall;

			CREATE TABLE #listGuidesoOverall
			(
				ItemSerie NVARCHAR(2),
				ItemNumber INT
			);
			CREATE NONCLUSTERED INDEX IDX_TMP_listGuidesoOverall_Item ON #listGuidesoOverall (ItemSerie, ItemNumber);

			INSERT INTO [#listGuidesoOverall]
			(
			    [ItemSerie],
			    [ItemNumber]
			)
			SELECT
				SUBSTRING(Item, 1, 2) ItemSerie
				,SUBSTRING(Item, 3, IIF(CHARINDEX('-', Item) = 0, (LEN(item)), (CHARINDEX('-', Item) - 3))) ItemNumber
			FROM DeliveryBackOffice.dbo.SplitUnlimited(@InGuides, ',')

			UPDATE dsd
			SET
				Settlement_Collect_OnDelivery = CASE WHEN do.IsLastMileReturn = 1 THEN 0 ELSE do.Collect_OnDelivery END, 
				SettlementCollect_TokenCreated = @Token, 
				SettlementCollect_DateCreated = GETDATE(), 
				Guide_Settlement = 1, -- guía liquidada en bodega
				Guide_Returned = 0,  -- guía liquidada vía material devuelto
				Guide_Delivered = 1,  -- guía liquidada vía comprobante de entrega
				StatusOrderId=5
			FROM [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] dsd
			INNER JOIN #listGuidesoOverall lg
				ON dsd.Guide_Serie = lg.ItemSerie AND dsd.Guide_Number = lg.ItemNumber
			INNER JOIN DeliveryOrder do WITH(NOLOCK)
				ON lg.ItemSerie = do.Guide_Serie AND lg.ItemNumber = do.Guide_Number
			WHERE 
				dsd.RowStatus = 1
				AND dsd.ID_DeliveryOrderBySettlement = @IdManifest
		
		SET @RModified = @@ROWCOUNT
						
		END TRY

		BEGIN CATCH
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID',
				0 AS 'SubStatusCode'
			ROLLBACK TRANSACTION
		END CATCH;

	IF @@TRANCOUNT > 0
		BEGIN
			IF (@RModified > 0)
			BEGIN
				SELECT			  
					1 AS 'StatusCode',
					'Registros guardado correctamente' AS 'Description', 
					@@TRANCOUNT AS 'NumTransferID',
					1 AS 'SubStatusCode'

				SELECT
					1 AS 'StatusCode'
				   ,'Registros guardado correctamente' AS 'Description'
				   ,@@TRANCOUNT AS 'NumTransferID'
				   ,CONCAT(lg.ItemSerie, lg.ItemNumber) Guide
				   ,(CASE
						WHEN dsd.Settlement_Collect_OnDelivery IS NULL THEN 0
						ELSE dsd.Settlement_Collect_OnDelivery
					END) Amount
				   ,1 AS 'SubStatusCode'
				   ,CASE
						WHEN DOR.IsLastMileReturn = 1 THEN ISNULL(doad.GuideReturnAttemptCount, 1)
						ELSE ISNULL(doad.GuideDeliveryAttemptCount, 1)
					END AS RetriesMade--Numero intentos de entrega fallidas
				   ,CASE
						WHEN DOR.IsLastMileReturn = 1 THEN ISNULL(doad.GuideReturnMaxAttemptCount, 2)
						ELSE ISNULL(doad.GuideDeliveryMaxAttemptCount, 2)
					END AS RetriesAllowed ---Numero de intentos permitidos
				   ,'' 'Retries'
				   ,0 ValidateAbandonedPackage
				   ,0 IsMarkedReturn
				FROM #listGuidesoOverall lg
				INNER JOIN DeliveryOrder DOR WITH (NOLOCK)
					ON DOR.Guide_Serie = lg.ItemSerie
						AND DOR.Guide_Number = lg.ItemNumber
				INNER JOIN DeliverySettlementDetail dsd WITH (NOLOCK)
					ON dsd.Guide_Serie = lg.ItemSerie
						AND dsd.Guide_Number = lg.ItemNumber
				LEFT JOIN DeliveryOrderAttemptData doad WITH (NOLOCK)
					ON doad.GuideSerie = DOR.Guide_Serie
						AND doad.GuideNumber = DOR.Guide_Number
						AND doad.RowStatus = 1
				WHERE dsd.ID_DeliveryOrderBySettlement = @IdManifest
				AND dsd.RowStatus = 1
				AND dsd.Guide_Settlement = 1 -- guía liquidada en bodega
				AND dsd.Guide_Returned = 0  -- guía liquidada vía material devuelto
				AND dsd.Guide_Delivered = 1  -- guía liquidada vía comprobante de entrega

			END
			ELSE
				SELECT			  
					0 AS 'StatusCode',
					'Registros no encontrados' AS 'Description', 
					0 AS 'NumTransferID',
					0 AS 'SubStatusCode'

			COMMIT TRANSACTION;			
		END
		ELSE
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID',
				0 AS 'SubStatusCode'
END
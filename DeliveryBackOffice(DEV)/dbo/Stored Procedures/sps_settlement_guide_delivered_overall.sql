
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

			SELECT
			SUBSTRING(Item, 1, 2) ItemSerie
			,SUBSTRING(Item, 3, IIF(CHARINDEX('-', Item) = 0, (LEN(item)), (CHARINDEX('-', Item) - 3))) ItemNumber
			INTO #listGuidesoOverall
			FROM DeliveryBackOffice.dbo.SplitUnlimited(@InGuides, ',')


			UPDATE dsd
			SET
				Settlement_Collect_OnDelivery = do.Collect_OnDelivery, 
				SettlementCollect_TokenCreated = @Token, 
				SettlementCollect_DateCreated = GETDATE(), 
				Guide_Settlement = 1, -- guía liquidada en bodega
				Guide_Returned = 0,  -- guía liquidada vía material devuelto
				Guide_Delivered = 1  -- guía liquidada vía comprobante de entrega
			FROM [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] dsd
			JOIN #listGuidesoOverall lg
				ON dsd.Guide_Serie = lg.ItemSerie AND dsd.Guide_Number = lg.ItemNumber
			JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] do
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

				SELECT 1 AS 'StatusCode'
					, 'Registros guardado correctamente' AS 'Description'
					, @@TRANCOUNT AS 'NumTransferID'
					, CONCAT(lg.ItemSerie, lg.ItemNumber) Guide
					, (case when dsd.Settlement_Collect_OnDelivery IS NULL then 0 else dsd.Settlement_Collect_OnDelivery end) Amount
					, 1 AS 'SubStatusCode'
					, COUNT(DORD.StatusOrderId)		AS RetriesMade--Numero intentos de entrega fallidas
					, (case when RH.Attempt is NULL then 2 else RH.Attempt end)		AS RetriesAllowed ---Numero de intentos permitidos
				FROM #listGuidesoOverall lg
					LEFT JOIN DeliveryOrder DOR ON DOR.Guide_Serie=lg.ItemSerie AND DOR.Guide_Number=lg.ItemNumber
					LEFT JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] dsd ON dsd.Guide_Serie = lg.ItemSerie AND dsd.Guide_Number = lg.ItemNumber
					LEFT JOIN DBO.DeliveryOrderDetail DORD  ON DOR.Guide_Serie=DORD.Guide_Serie AND DOR.Guide_Number=DORD.Guide_Number
						AND DORD.StatusOrderId= (select StatusOrderId from dbo.StatusOrder where OrderDescription ='Intento de entrega fallida')
					LEFT JOIN DBO.Customer CU ON DOR.IdCustomer=CU.IdCustomer
					LEFT JOIN DBO.RatebyCustomer RC ON CU.IdCustomer=RC.RbcIdCustomer AND rc.RbcRowStatus ='true' AND rc.RbcCodeOfReference IS NULL
					LEFT JOIN RateHeader RH ON RC.RbcIdRate=RH.RheId AND rh.RheRowStatus ='true'							
				WHERE dsd.ID_DeliveryOrderBySettlement = @IdManifest
					AND dsd.RowStatus = 1
					AND Guide_Settlement = 1 -- guía liquidada en bodega
					AND Guide_Returned = 0  -- guía liquidada vía material devuelto
					AND Guide_Delivered = 1  -- guía liquidada vía comprobante de entrega
				GROUP BY lg.ItemSerie,lg.ItemNumber,CU.IdCustomer,RH.Attempt,DORD.StatusOrderId,dsd.Settlement_Collect_OnDelivery 

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
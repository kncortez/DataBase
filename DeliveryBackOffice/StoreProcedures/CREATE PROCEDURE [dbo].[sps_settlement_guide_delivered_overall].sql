USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[sps_settlement_guide_delivered_overall]    Script Date: 28/10/2021 07:34:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

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
				dsd.ID_DeliveryOrderBySettlement = @IdManifest
		
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
					, CONCAT(dsd.Guide_Serie, dsd.Guide_Number) Guide
					, dsd.Settlement_Collect_OnDelivery Amount
					, 1 AS 'SubStatusCode'
				FROM [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] dsd
				JOIN #listGuidesoOverall lg
					ON dsd.Guide_Serie = lg.ItemSerie AND dsd.Guide_Number = lg.ItemNumber
				WHERE dsd.ID_DeliveryOrderBySettlement = @IdManifest
					AND Guide_Settlement = 1 -- guía liquidada en bodega
					AND Guide_Returned = 0  -- guía liquidada vía material devuelto
					AND Guide_Delivered = 1  -- guía liquidada vía comprobante de entrega
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
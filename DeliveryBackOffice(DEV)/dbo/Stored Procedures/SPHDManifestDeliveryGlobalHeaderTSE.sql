
-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2023-05-31>
-- Description:	<Description, Cabecera de manifiesto global de entrega>
-- =============================================
CREATE PROCEDURE [dbo].[SPHDManifestDeliveryGlobalHeaderTSE]
AS
BEGIN

    SET NOCOUNT ON;

    SELECT COUNT([B].[GuideNumber]) [TotalGuide],
           0 [Totalpiece],
           COUNT([B].[GuideNumber]) AS [Sobres]
    FROM [DeliveryBackOffice].[dbo].[TSERoutePreparationHeader] [A] WITH (NOLOCK)
        INNER JOIN [DeliveryBackOffice].[dbo].[TSERoutePreparationDetail] [B] WITH (NOLOCK)
            ON [A].[IDTSERoutePreparationHeader] = [B].[TSERoutePreparationHeaderID]
               AND [B].[RowStatus] = 1
        INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] [DO] WITH (NOLOCK)
            ON [DO].[Guide_Serie] = [B].[GuideSerie]
               AND [DO].[Guide_Number] = [B].[GuideNumber]
               AND [DO].[StatusOrderId] <> 7
    WHERE [A].[HasLastDeliveryProccess] = 1
		AND [DO].[Pieces_Dry] > 1
          AND [A].[RowStatus] = 1
    UNION ALL
    SELECT 0 [TotalGuide],
           COUNT([C].[Detail]) [Totalpiece],
           0 AS [Sobres]
    FROM [DeliveryBackOffice].[dbo].[TSERoutePreparationHeader] [A] WITH (NOLOCK)
        INNER JOIN [DeliveryBackOffice].[dbo].[TSERoutePreparationDetail] [B] WITH (NOLOCK)
            ON [A].[IDTSERoutePreparationHeader] = [B].[TSERoutePreparationHeaderID]
               AND [B].[RowStatus] = 1
        INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] [DO] WITH (NOLOCK)
            ON [DO].[Guide_Serie] = [B].[GuideSerie]
               AND [DO].[Guide_Number] = [B].[GuideNumber]
               AND [DO].[StatusOrderId] <> 7
        INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] [C] WITH (NOLOCK)
            ON [B].[GuideSerie] = [C].[GuideSerie]
               AND [B].[GuideNumber] = [C].[GuideNumber]
    WHERE [A].[HasLastDeliveryProccess] = 1
		AND [DO].[Pieces_Dry] > 1
          AND [A].[RowStatus] = 1;


END;
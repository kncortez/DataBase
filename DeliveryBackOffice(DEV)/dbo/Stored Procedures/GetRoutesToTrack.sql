
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2021-11-30>
-- Description:	< Retorna las rutas de un día tomando en cuenta el hub donde se genero el manifiesto >
-- =============================================
CREATE PROCEDURE [dbo].[GetRoutesToTrack]
    @Date DATE,
    @Hub TblExtPlatTextParameterList READONLY,
    @ServiceType BIGINT = 2
AS
BEGIN

    SELECT CONCAT(SR.First_Name, ' ', SR.Last_Name) 'Courier',
           ISNULL(HL.HubAbbreviation, 'N/A') 'Hub',
           MAX(   CASE
                      WHEN ISNULL(DO.Courier_Route, 'N/A') LIKE 'U%' THEN
                          ISNULL(DO.Courier_Route, 'N/A')
                      ELSE
                          'N/A'
                  END
              ) 'Route',
           DOBS.ID 'Manifest',
           COUNT(DISTINCT DO.Guide_Number) 'TotalServices',
           ISNULL(SUM(DOA.TotalCount), 0) 'TotalAlerts',
           COUNT(DISTINCT DO2.Guide_Number) 'TotalSuccessfulDeliveries',
           SUM(   CASE
                      WHEN DO2.IsCollect = 1 THEN
                          ISNULL(DO2.PriceShippment, 0) + ISNULL(DO2.Collect_OnDelivery, 0)
                      ELSE
                          ISNULL(DO2.Collect_OnDelivery, 0)
                  END
              ) 'TotalConfirmedCharge',
           SUM(   CASE
                      WHEN DO.IsCollect = 1 THEN
                          ISNULL(DO.PriceShippment, 0) + ISNULL(DO.Collect_OnDelivery, 0)
                      ELSE
                          ISNULL(DO.Collect_OnDelivery, 0)
                  END
              ) 'TotalToCharge'
    FROM [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] DOBS WITH (NOLOCK)
        LEFT JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] DSD WITH (NOLOCK)
            ON DOBS.ID = DSD.ID_DeliveryOrderBySettlement
               AND DSD.RowStatus = 1
        LEFT JOIN [DeliveryBackOffice].[dbo].[SenderReceiver] SR WITH (NOLOCK)
            ON DOBS.ID_Courier = SR.ID
        INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
            ON DSD.Guide_Serie = DO.Guide_Serie
               AND DSD.Guide_Number = DO.Guide_Number
        LEFT JOIN [DeliveryBackOffice].[dbo].[CatStation] CS WITH (NOLOCK)
            ON DOBS.DispatchedStationId = CS.IdStation
        LEFT JOIN [DeliveryBackOffice].[dbo].[HubLogistics] HL WITH (NOLOCK)
            ON CS.HubLogisticId = HL.IdHubLogistic
        LEFT JOIN
        (
            SELECT DOAA.GuideSerie,
                   DOAA.GuideNumber,
                   COUNT(DISTINCT DOAA.IdDeliveryOrderAlert) 'TotalCount'
            FROM [DeliveryBackOffice].[dbo].[DeliveryOrderAlert] DOAA WITH (NOLOCK)
            WHERE DOAA.ServiceTypeId = 2 -- Entrega
                  AND DOAA.RowStatus = 1
            GROUP BY DOAA.GuideSerie,
                     DOAA.GuideNumber
        ) DOA
            ON DSD.Guide_Serie = DOA.GuideSerie
               AND DSD.Guide_Number = DOA.GuideNumber
        LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DO2 WITH (NOLOCK) -- Guías las cuales se confirma su entrega y cobro
            ON DSD.Guide_Serie = DO2.Guide_Serie
               AND DSD.Guide_Number = DO2.Guide_Number
               AND DO2.StatusOrderId IN ( 5, 24, 25 ) -- Entregado|COD Liquidado|COD Pagado
    WHERE CAST(DOBS.Date_Dispatched AS DATE) = @Date
          AND REPLACE(ISNULL(HL.HubAbbreviation, 'N/A'), ' ', '')IN
              (
                  SELECT REPLACE(TextParameter, ' ', '')FROM @Hub
              ) /*
	AND
	(
		REPLACE(ISNULL(DO.Courier_Route,'N/A'),' ','') = 'N/A'
		OR
		LEFT(REPLACE(ISNULL(DO.Courier_Route,'N/A'),' ',''),1) = 'U'
	)*/
    GROUP BY SR.First_Name,
             SR.Last_Name,
             HL.HubAbbreviation,
             --,DO.Courier_Route
             DOBS.ID;


END;
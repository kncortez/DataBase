-- =============================================
-- Author:		<Alfredo Monroy>
-- Create date: <2021-10-07>
-- Description:	<Reporte de Guías Última Milla>
-- =============================================
-- =============================================
-- Modified:	<Alberto, Ixchop>
-- Create date: <2022-02-01>
-- Description:	<Se agregaron los campos HUB,Ruta,Vehiculo,Kilometraje,TipoCourier>
-- =============================================
CREATE PROCEDURE [dbo].[RptLastMileRoutes]
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN

            SELECT 
			ROW_NUMBER() OVER (ORDER BY DOBS.Date_Dispatched) Renglon,
			CONVERT(VARCHAR(10), DOBS.Date_Dispatched, 103) Date_Dispatched,
			HBL.HubAbbreviation Hub,
			CR.RegionName AS Region,
			SRE.CUI Courierman_Id,
			SRE.First_Name + ' ' + SRE.Last_Name Courierman_Name,
			TYSRE.TypeName Driver_Type,
			CRT.CodeRoute Route_Name,
			CVH.UnitNumber Vehicle,
			DOBS.StartingKilometers Out_KM,
			DOBS.ID Settlement_Id,
			DOBS.Guides_Dispatched,
			(DOBS.Pieces_Dry_Dispatched + DOBS.Pieces_Cold_Dispatched) Pieces_Dispatched,
			CONVERT(VARCHAR(8), DOBS.Date_Dispatched, 114) Time_Dispatched,
			CONVERT(VARCHAR(8), DOBS.Route_Received, 114) Time_Settlement,
			SUM(IIF(DSD.Guide_Returned = 1, 1, 0)) Guides_Returned,
			SUM(IIF(DSD.Guide_Returned = 1, (DO.Pieces_Dry + DO.Pieces_Cold), 0)) Returned_Pieces,
			SUM(IIF(DSD.Guide_Delivered = 1, 1, 0)) Guides_Delivered,
			SUM(IIF(DSD.Guide_Delivered = 1, (DO.Pieces_Dry + DO.Pieces_Cold), 0)) Delivered_Pieces,
			(DOBS.Pieces_Dry_Dispatched + DOBS.Pieces_Cold_Dispatched) Delivery_effectiveness,
			CONVERT(TIME, DOBS.Date_Dispatched - DOBS.Route_Received) Time_on_route

            FROM DeliveryBackOffice.dbo.DeliveryOrderBySettlement DOBS 
				LEFT JOIN DeliveryBackOffice.dbo.DeliverySettlementDetail DSD ON DSD.ID_DeliveryOrderBySettlement=DOBS.ID
                LEFT  JOIN DeliveryBackOffice.dbo.DeliveryOrder DO ON DO.Guide_Serie = DSD.Guide_Serie
                       AND DO.Guide_Number = DSD.Guide_Number
					   AND DSD.RowStatus = 1
				LEFT  JOIN DeliveryBackOffice.dbo.SenderReceiver SRE ON SRE.ID = DOBS.ID_Courier
				LEFT JOIN DeliveryBackOffice.dbo.CatTypeSenderReceiver TYSRE ON SRE.CatTypeSenderReceiverId=TYSRE.IdCatTypeSenderReceiver
				LEFT JOIN DeliveryBackOffice.dbo.HubLogistics HBL ON HBL.IdHubLogistic=SRE.HubLogisticId AND HBL.HubStatus=1
				LEFT JOIN DeliveryBackOffice.dbo.HubByRegion HBR ON SRE.HubLogisticId=HBR.HubLogisticId AND HBR.RowStatus=1
				LEFT JOIN DeliveryBackOffice.dbo.CatRegion CR ON HBR.RegionId=CR.IdCatRegion AND CR.RowStatus=1
				LEFT JOIN DeliveryBackOffice.dbo.CatRoute CRT ON DOBS.CatRouteId=CRT.IdRoute AND CRT.RowStatus=1
				LEFT JOIN DeliveryBackOffice.dbo.CatVehicle CVH on DOBS.CatVehicleId=cvh.IdVehicle
            WHERE CAST(DOBS.Date_Dispatched AS DATE)
            BETWEEN @StartDate AND @EndDate
            GROUP BY DOBS.ID,DOBS.Date_Dispatched,SRE.CUI,SRE.First_Name,SRE.Last_Name,DOBS.Guides_Dispatched,DOBS.Pieces_Dry_Dispatched,Pieces_Cold_Dispatched
			,DOBS.Route_Received,HBL.HubAbbreviation,CR.RegionName,TYSRE.TypeName,CRT.CodeRoute,CVH.UnitNumber,DOBS.StartingKilometers

END;
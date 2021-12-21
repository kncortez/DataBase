USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[RptLastMileRoutes]    Script Date: 20/12/2021 14:40:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alfredo Monroy>
-- Create date: <2021-10-07>
-- Description:	<Reporte de Guías Última Milla>
-- =============================================
ALTER PROCEDURE [dbo].[RptLastMileRoutes]
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN

    SELECT ROW_NUMBER() OVER (ORDER BY DOS.Date_Dispatched) Renglon,
           CONVERT(VARCHAR(10), DOS.Date_Dispatched, 103) Date_Dispatched,
           '' Hub,
           '' AS Region,
           SRE.CUI Courierman_Id,
           SRE.First_Name + ' ' + SRE.Last_Name Courierman_Name,
           '' Driver_Type,
           '' Route_Name,
           '' Vehicle,
           0 Out_KM,
           DOS.ID Settlement_Id,
           DOS.Guides_Dispatched,
           (DOS.Pieces_Dry_Dispatched + DOS.Pieces_Cold_Dispatched) Pieces_Dispatched,
           CONVERT(VARCHAR(8), DOS.Date_Dispatched, 114) Time_Dispatched,
           CONVERT(VARCHAR(8), DOS.Route_Received, 114) Time_Settlement,
           ISNULL(SUB1.Guide_Returned, 0) Guides_Returned,
           ISNULL(SUB1.Piece_Returned, 0) Returned_Pieces,
           ISNULL(SUB1.Guide_Delivered, 0) Guides_Delivered,
           ISNULL(SUB1.Piece_Delivered, 0) Delivered_Pieces,
           IIF((DOS.Pieces_Dry_Dispatched + DOS.Pieces_Cold_Dispatched) <> 0,
               (0 / (DOS.Pieces_Dry_Dispatched + DOS.Pieces_Cold_Dispatched)),
               0) Delivery_effectiveness,
           CONVERT(TIME, DOS.Date_Dispatched - DOS.Route_Received) Time_on_route
    FROM DeliveryBackOffice.dbo.DeliveryOrderBySettlement DOS
        JOIN DeliveryBackOffice.dbo.SenderReceiver SRE
            ON SRE.ID = DOS.ID_Courier
        LEFT JOIN
        (
            SELECT DSD.ID_DeliveryOrderBySettlement,
                   SUM(IIF(DSD.Guide_Returned = 1, 1, 0)) Guide_Returned,
                   SUM(IIF(DSD.Guide_Returned = 1, (DO.Pieces_Dry + DO.Pieces_Cold), 0)) Piece_Returned,
                   SUM(IIF(DSD.Guide_Delivered = 1, 1, 0)) Guide_Delivered,
                   SUM(IIF(DSD.Guide_Delivered = 1, (DO.Pieces_Dry + DO.Pieces_Cold), 0)) Piece_Delivered
            FROM DeliveryBackOffice.dbo.DeliverySettlementDetail DSD
                JOIN DeliveryBackOffice.dbo.DeliveryOrder DO
                    ON DO.Guide_Serie = DSD.Guide_Serie
                       AND DO.Guide_Number = DSD.Guide_Number
					   AND DSD.RowStatus = 1
                JOIN DeliveryBackOffice.dbo.DeliveryOrderBySettlement DOBS
                    ON DOBS.ID = DSD.ID_DeliveryOrderBySettlement
            WHERE CAST(DOBS.Date_Dispatched AS DATE)
            BETWEEN @StartDate AND @EndDate
            GROUP BY DSD.ID_DeliveryOrderBySettlement
        ) SUB1
            ON SUB1.ID_DeliveryOrderBySettlement = DOS.ID
    WHERE CAST(DOS.Date_Dispatched AS DATE)
    BETWEEN @StartDate AND @EndDate;

END;
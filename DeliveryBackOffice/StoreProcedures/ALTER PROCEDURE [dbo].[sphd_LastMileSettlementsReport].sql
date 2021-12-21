USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[sphd_LastMileSettlementsReport]    Script Date: 21/12/2021 08:53:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      <Sazo,Cesar>
-- Create date: <2021-12-06>
-- Description: <Obtener informacion para el mostrar los datos necesarios del Reporte Liquidaciones Última Milla>
-- =============================================

ALTER PROCEDURE [dbo].[sphd_LastMileSettlementsReport] (@fromDate AS DATE,
@toDate AS DATE,
@hubsIds AS NVARCHAR(MAX))
AS
BEGIN
	SELECT
		dst.id 'Manifiesto'
	   ,cst.StationName 'Hub'
	   ,CONVERT(DATE, dst.Date_Received) 'Fecha'
	   ,CONCAT(dsd.Guide_Serie, dsd.Guide_Number) 'Guia'
	   ,CONCAT(ord.Sender_FirstName,' ', ord.Sender_LastName) 'Remitente'
	   ,CONCAT(ord.Receiver_FirstName,' ', ord.Receiver_LastName) 'Destinatario'
	   ,CONCAT(sdr.First_Name, ' ', sdr.Last_Name) 'Piloto'
	   ,IIF(ord.IsCollect = 1, ord.PriceShippment, 0) 'Collect'
	   ,ord.Collect_OnDelivery 'COD'
	FROM dbo.DeliveryOrderBySettlement dst
	JOIN dbo.DeliverySettlementDetail dsd
		ON dsd.ID_DeliveryOrderBySettlement = dst.id
		AND dsd.RowStatus = 1
	JOIN dbo.DeliveryOrder ord
		ON ord.Guide_Serie = dsd.Guide_Serie
			AND ord.Guide_Number = dsd.Guide_Number
	JOIN dbo.CatStation cst
		ON cst.IdStation = dst.SettlementStationId
	JOIN dbo.SenderReceiver sdr
		ON sdr.id = dst.ID_Courier
	WHERE CONVERT(DATE, dst.Date_Received)
	BETWEEN @fromDate AND @toDate
	AND DispatchedStationId IN (SELECT
			Name
		FROM splitstring(@hubsIds, ','))
	AND dsd.Settlement_Collect_OnDelivery > 0
	ORDER BY cst.IdStation, dst.Date_Received, dst.id, ord.Guide_Number
END
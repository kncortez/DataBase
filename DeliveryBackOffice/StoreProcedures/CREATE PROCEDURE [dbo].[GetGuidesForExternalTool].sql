
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2021-08-18>
-- Description:	< Obtener guías de un día especifico, agrupandolas por manifiesto y ruta y ordenandolas por numero de guía para utilizar en una plataforma externa >
CREATE PROCEDURE [dbo].[GetGuidesForExternalTool]
	@Date AS DATETIME
AS
BEGIN
	SELECT 
		CONCAT ( DOS.ID, '_',  DOR.Courier_Route) ManifiestoRoute
		,CONCAT (DOR.Guide_Serie, DOR.Guide_Number) Guide
		,CONCAT( DOR.Receiver_FirstName , ' ', ISNULL(DOR.Receiver_LastName,'')) ReceiverName
		,DOR.Receiver_Address
		,DOR.Receiver_Phone
		,DOR.Receiver_Email
		,DOR.Pieces_Dry
		,DOR.Pieces_Cold
		,ISNULL(DOR.PriceShippment,0) PriceShippment
		,DOR.Collect_OnDelivery
		,ISNULL(DOR.IsCollect,0) IsCollect
		,DOR.DateCreated
		,DOS.Date_Dispatched
		,(CASE WHEN DOR.TypeService = 'EXP' OR DOR.TypeService IS NULL THEN 'NDD' ELSE DOR.TypeService END) TypeService
		,SDFG.Latitude
		,SDFG.Longitude
		,SDFG.StartTime
		,SDFG.EndTime
		,DOP.PieceWeight
		,DOP.PiecePhysicalWeight
		,DOP.PieceHeight
		,DOP.PieceLength
		,DOP.PieceWidth
		,ISNULL(DOP.fragile,0) fragile
		,DOP.NoPiece
	FROM
		(
			SELECT DISTINCT
			Guide_Serie,
			Guide_Number,
			ID_Courier
			FROM dbo.DeliveryAttempt
			--WHERE CAST(Date_Created AS DATE) = CAST(@Date AS DATE)
		) DAT
		JOIN DeliveryBackOffice.dbo.DeliveryOrder DOR
			ON DAT.Guide_Serie = DOR.Guide_Serie
			AND DAT.Guide_Number = DOR.Guide_Number
		JOIN DeliveryBackOffice.dbo.DeliverySettlementDetail DSD
			ON DSD.Guide_Serie = DAT.Guide_Serie
			AND DSD.Guide_Number = DAT.Guide_Number
		JOIN DeliveryBackOffice.dbo.DeliveryOrderBySettlement DOS
			ON DOS.ID = DSD.ID_DeliveryOrderBySettlement
			AND DOS.ID_Courier = DAT.ID_Courier
		JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece DOP
			ON DOP.GuideSerie = DOR.Guide_Serie
			AND DOP.GuideNumber = DOR.Guide_Number
		LEFT JOIN DeliveryBackOffice.dbo.ServiceDataForGuide SDFG
			ON DOR.Guide_Serie = SDFG.GuideSerie
			AND DOR.Guide_Number = SDFG.GuideNumber
		LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC
			ON VPC.CodeOfReference = DOR.Sender_ID
	WHERE --DOS.ID = 31203--@IdManifest--31202
		CAST(DOS.Route_Dispatched AS DATE) = CAST(@Date AS DATE)
		AND
		ISNUMERIC( REPLACE(REPLACE( ISNULL(DOR.Receiver_Zone,''),' ',''),'.','') ) = 1 AND DOR.Receiver_Zone IN (15,16) 
		AND
		DOR.Receiver_Town = 'Guatemala'
		AND
		DOR.Receiver_Department = 'Guatemala'
	ORDER BY DOS.ID DESC, DOR.Courier_Route DESC, DOR.Guide_Number ASC;
END
GO

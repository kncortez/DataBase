USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spg_settlement_delivered]    Script Date: 20/07/2021 00:01:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Carlos, Cano>
-- Create date: <2020-11-24>
-- Description:	<Recupera información para generar manifiesto de liquidación (entregas)>
-- =============================================
ALTER PROCEDURE [dbo].[spg_settlement_delivered]
		@IdManifest INT
AS
BEGIN
	
	DECLARE @GuideCount INT

	SET NOCOUNT ON;

	SET @GuideCount = (
		SELECT 
			COUNT(dobs.GuidesQuantity)
		FROM [DeliveryBackOffice].[dbo].[SettlementByPickup] dobs
		JOIN DeliveryBackOffice.dbo.SettlementByPickupDetail dsd ON dsd.SettlementByPickupId = dobs.Id
		WHERE dobs.SequenceCode = @IdManifest
		AND dsd.IsPieceLiquidaded = 1 -- guía y pieza liquidada
	)

	/*
	SELECT 
			dobs.ID, 
			dobs.Date_Received, 
			--dobs.Pieces_Dry_Received, 
			--dobs.Pieces_Cold_Received, 
			@GuideCount as Guides_Received,
			isnull(sr.First_Name,'') + ' ' + isnull(sr.Last_Name,'') as Courier_Name,
			dobs.Route_Received,
			CONVERT(NVARCHAR,lbt.SSN_IdUser) + ' - ' + lbt.SSN_Username as IdUser_Username_Received
		FROM [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] dobs
		JOIN DeliveryBackOffice.dbo.SenderReceiver sr ON sr.ID = dobs.ID_Courier
		JOIN DenariusUser_Dev.dbo.LGN_LogByToken lbt ON lbt.SSN_IdToken = dobs.User_Received
		WHERE dobs.ID = @IdManifest
	*/
	SELECT 
			dobs.SequenceCode as ID, 
			dobs.DatePrinted as DatePrinted, 
			@GuideCount as Guides_Received,
			isnull(sr.First_Name,'') + ' ' + isnull(sr.Last_Name,'') as Courier_Name,
			dobs.DatePrinted as Route_Received,
			CONVERT(NVARCHAR,lbt.SSN_IdUser) + ' - ' + lbt.SSN_Username as IdUser_Username_Received,
			cr.CodeRoute
		FROM [DeliveryBackOffice].[dbo].[SettlementByPickup] dobs
		JOIN DeliveryBackOffice.dbo.SenderReceiver sr ON sr.ID = dobs.IdCourier
		JOIN DenariusUser_Dev.dbo.LGN_LogByToken lbt ON lbt.SSN_IdToken = dobs.TokenCreated
		JOIN RouteAssigment ra on (ra.IdRouteAssigment = dobs.RouteAssigmentId)
		JOIN CatRoute cr on (cr.IdRoute = ra.IdRoute)
		WHERE dobs.SequenceCode = @IdManifest and dobs.SubTypeServiceManagmentId = 2
END
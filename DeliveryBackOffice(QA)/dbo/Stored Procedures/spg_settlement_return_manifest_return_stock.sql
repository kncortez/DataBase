
--drop procedure  [dbo].[spg_settlement_returned_PickUp]
-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2021-03-11>
-- Description:	<Recupera información para generar manifiesto de liquidación (Devolución)>
-- =============================================
CREATE PROCEDURE [dbo].[spg_settlement_return_manifest_return_stock]
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
		WHERE dobs.ID = @IdManifest
		AND dsd.IsReturn = 1 -- guía y pieza liquidada
	)

	SELECT 
			dobs.SequenceCode as ID, 
			dobs.DatePrinted as DatePrinted, 
			--dobs.Pieces_Dry_Received, 
			--dobs.Pieces_Cold_Received, 
			@GuideCount as Guides_Received,
			isnull(sr.First_Name,'') + ' ' + isnull(sr.Last_Name,'') as Courier_Name,
			dobs.DatePrinted as DatedPrinted,
			CONVERT(NVARCHAR,lbt.SSN_IdUser) + ' - ' + lbt.SSN_Username as IdUser_Username_Received,
			cr.CodeRoute
		FROM [DeliveryBackOffice].[dbo].[SettlementByPickup] dobs
		JOIN DeliveryBackOffice.dbo.SenderReceiver sr ON sr.ID = dobs.IdCourier
		JOIN DenariusUser_Dev.dbo.LGN_LogByToken lbt WITH (NOLOCK) ON lbt.SSN_IdToken = dobs.TokenCreated
		JOIN RouteAssigment ra on (ra.IdRouteAssigment = dobs.RouteAssigmentId)
		JOIN CatRoute cr on (cr.IdRoute = ra.IdRoute)
		WHERE dobs.SequenceCode = @IdManifest

END

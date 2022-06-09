
CREATE PROCEDURE [dbo].[spg_deliveryorder_settlement_linehauls]
		@IdManifest INT
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT 
		'ML' + cast(dobs.SequenceCode as varchar(10)) as ID, 
		dobs.DateCreated as Date_Dispatched, 
		dobs.PiecesDry as Pieces_Dry_Dispatched, 
		dobs.PiecesCold as Pieces_Cold_Dispatched, 
		dobs.GuidesQuantity Guides_Dispatched,
		sr.First_Name + ' ' + sr.Last_Name as Courier_Name,
		dobs.DateCreated as Route_Dispatched,
		CONVERT(NVARCHAR,lbt.SSN_IdUser) + ' - ' + lbt.SSN_Username as IdUser_Username_Dispatched,
		(SELECT
				ISNULL(hl_destino.HubAbbreviation, 0) 
			FROM DeliveryBackOffice.dbo.HubLogistics hl_destino
				where  hl_destino.IdHublogistic = sm.IdHubDestination
				) AS ID_HUB_DESTINO
			
	FROM [DeliveryBackOffice].[dbo].SettlementByPickup dobs
	JOIN [DeliveryBackOffice].[dbo].ServiceManagement sm ON sm.IdServiceManagement = dobs.ServiceManagmentId
	LEFT JOIN DeliveryBackOffice.dbo.SenderReceiver sr ON sr.ID = dobs.IdCourier
	LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken lbt ON lbt.SSN_IdToken = dobs.TokenCreated
	WHERE dobs.SequenceCode = @IdManifest

END

CREATE PROCEDURE [dbo].[sphd_getVPC]
	@CustomerID AS INT
AS
BEGIN
	SELECT  vpc.IdVisitPointClient,
    cli.Name,
	vpc.CodeOfReference, 
	ISNULL(cli.Abbreviation,'') + ' - ' + vpc.DescriptionOfClient [Client], 
	vpc.Address [Address],
	vpc.IdSettlement,
	vpc.Phone,
	vpc.IdTownship,
	hub.HubAbbreviation,
	hub.IdHubLogistic
	FROM DeliveryBackOffice.[dbo].[Customer] cli 
	JOIN DeliveryBackOffice.[dbo].[VisitPointClient] vpc ON cli.IdCustomer = vpc.CustomerID
	LEFT JOIN DeliveryBackOffice.dbo.TownshipByHubLogistic tbl ON vpc.IdTownship = tbl.IdTownshipHub AND tbl.StatusTownshipHub = 'true'
	LEFT JOIN DeliveryBackOffice.dbo.HubLogistics hub ON tbl.IdHublogistic = hub.IdHubLogistic
	WHERE vpc.StatusClient = 'true'
	AND vpc.CustomerID = @CustomerID
END
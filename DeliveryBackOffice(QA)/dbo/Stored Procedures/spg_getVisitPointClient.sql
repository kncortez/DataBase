
-- =============================================
-- Author:		<Abner, Juarez>
-- Create date: <2020-02-13>
-- Description:	<Consulta los visit point>
-- =============================================
CREATE PROCEDURE [dbo].[spg_getVisitPointClient]
		@country as varchar(10)
AS
BEGIN
	select  vpc.IdVisitPointClient,
    cli.Name,
	vpc.CodeOfReference, 
	isnull(cli.Abbreviation,'') + ' - ' + vpc.DescriptionOfClient [Client], 
	vpc.Address [Address],
	vpc.IdSettlement,
	vpc.Phone,
	vpc.IdTownship,
	hub.HubAbbreviation,
	hub.IdHubLogistic
	from DeliveryBackOffice.[dbo].[Customer] cli 
	join DeliveryBackOffice.[dbo].[VisitPointClient] vpc on cli.IdCustomer = vpc.CustomerID
	left join DeliveryBackOffice.dbo.TownshipByHubLogistic tbl on vpc.IdTownship = tbl.IdTownshipHub and tbl.StatusTownshipHub = 'true'
	left join DeliveryBackOffice.dbo.HubLogistics hub on tbl.IdHublogistic = hub.IdHubLogistic
	where vpc.StatusClient = 'true' and vpc.CountryId = @country order by [Client]
END
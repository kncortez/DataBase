SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alberto, Ixhcop>
-- Create date: <2022-01-10>
-- Description:	<Obtiene una lista de clientes asociados a sus respectivos puntos de visita>
-- =============================================
CREATE PROCEDURE sphd_getCustomersByVisitPoint	
	@country as varchar(2)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT c.Name + ' ' + ISNULL(ru.UsrEmail, '') Name,
           c.IdCustomer
    FROM DeliveryBackOffice.dbo.Customer c
        LEFT JOIN dbo.Account a 
            ON a.IdCustomer = c.IdCustomer
        LEFT JOIN dbo.RolByUserByAccount rua 
            ON rua.RuaIdAccount = a.AccIdAccount
        LEFT JOIN DeliveryBackOffice.dbo.RegisterUser ru
            ON ru.UsrIdUser = rua.RuaIdUser
    WHERE ISNULL(c.RowSatus, 1) = 1


	select  
		vpc.IdVisitPointClient IdVP,
		isnull(cli.Abbreviation,'') + ' - ' + vpc.DescriptionOfClient [Client], 
		cli.IdCustomer				IdCustomer,
		--cli.Name + ' ' + ISNULL(ru.UsrEmail, '' ) NameEmail,
		cli.Name				Name,
		vpc.CodeOfReference			, 
		vpc.Address [Address],
		vpc.IdSettlement,
		vpc.Phone,
		vpc.IdTownship,
		hub.HubAbbreviation,
		hub.IdHubLogistic,
		vpc.StatusClient
	from DeliveryBackOffice.[dbo].[VisitPointClient] vpc 
	left join DeliveryBackOffice.[dbo].[Customer] cli  on cli.IdCustomer = vpc.CustomerID
		 and vpc.CountryId = @country 
	left join DeliveryBackOffice.dbo.TownshipByHubLogistic tbl on vpc.IdTownship = tbl.IdTownshipHub and tbl.StatusTownshipHub = 'true'
	left join DeliveryBackOffice.dbo.HubLogistics hub on tbl.IdHublogistic = hub.IdHubLogistic and hub.HubStatus='true'
	WHERE 
	vpc.StatusClient=1 and (cli.RowSatus =1 or cli.RowSatus is null)
	order by [Client]





END
GO

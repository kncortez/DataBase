-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-04-07>
-- Description:	< Obtiene la lista de puntos de visita de clientes concatenando >
-- =============================================
CREATE PROCEDURE [dbo].[GetVisitPointOFCustomer]	
	@Country NVARCHAR(2) = 'GT',
	@CustomerId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT
		VPC.IdVisitPointClient IdVP,
		CONCAT('[', VPC.CodeOfReference, '] ', isnull(Cu.Abbreviation,''), (CASE WHEN Cu.Abbreviation IS NULL THEN '' ELSE ' - ' END), VPC.DescriptionOfClient, ' {', REPLACE(REPLACE(REPLACE(ISNULL(VPC.Phone, ''),'(502)',''),'-',''),' ',''),'} ', IIF(VPC.StatusClient = 0, ' [X]', '')) [Client], 
		Cu.IdCustomer				IdCustomer,
		--Cu.Name + ' ' + ISNULL(ru.UsrEmail, '' ) NameEmail,
		Cu.Name				Name,
		VPC.CodeOfReference			, 
		VPC.Address [Address],
		VPC.IdSettlement 'IdSettlement',
		ISNULL(VPC.Phone, '') 'Phone',
		ISNULL(VPC.IdTownship, Twn.IdTownship) 'IdTownship',
		DSC.Hub 'HubAbbreviation',
		HL.IdHubLogistic 'IdHubLogistic',
		VPC.StatusClient,
		VPC.DescriptionOfClient DescriptionOfClient,
		VPC.ContactName ContactName,
		VPC.Email Email,
		ISNULL(Tw.IdProvince, Twn.IdProvince) IdProvince,
		ISNULL(VPC.Latitude,'') Latitude,
		ISNULL(VPC.Longitude,'') Longitude
	from 
		[DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH(NOLOCK)
		left join [DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK) on Cu.IdCustomer = VPC.CustomerID
			 and VPC.CountryId = @country 
		LEFT JOIN [DeliveryBackOffice].[dbo].[Township] Tw WITH(NOLOCK)
			ON Tw.IdTownship = VPC.IdTownship
		LEFT JOIN [DeliveryBackOffice].[dbo].[Township] Twn WITH(NOLOCK)
			on VPC.Town = Twn.TownshipName COLLATE Latin1_General_CI_AI
		LEFT JOIN (
			SELECT
				DSC.HeaderCode
				,MAX(DSC.Hub) 'Hub'
			FROM
				[DeliveryBackOffice].[dbo].[DumpServiceCoverage] DSC WITH(NOLOCK)
			WHERE
				DSC.RowStatus = 1
			GROUP BY
				DSC.HeaderCode
		) DSC
			ON
				ISNULL(Tw.HeaderCode, Twn.HeaderCode) = DSC.HeaderCode
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[HubLogistics] HL WITH(NOLOCK)
			ON
				HL.HubAbbreviation = DSC.Hub
		LEFT JOIN (
			SELECT
				DO.Sender_ID
				,COUNT(DO.Guide_Number) 'OrdersByVisitpoint'
			FROM
				[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
			WHERE
				DO.DateCreated >= DATEADD(DAY, -7,GETDATE())
				AND
				DO.Sender_ID != 0
			GROUP BY
				DO.Sender_ID
		) OrdersByVPC
			ON
				VPC.CodeOfReference = OrdersByVPC.Sender_ID
	WHERE 
		Cu.IdCustomer = @CustomerId
		AND 
		(Cu.RowSatus =1 or Cu.RowSatus is null)
		AND
		VPC.StatusClient=1
	ORDER BY
		ISNULL(OrdersByVPC.OrdersByVisitpoint, -1) DESC
		,VPC.CodeOfReference ASC


END
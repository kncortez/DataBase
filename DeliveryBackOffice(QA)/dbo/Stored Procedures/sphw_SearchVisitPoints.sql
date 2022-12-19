
-- =============================================
-- Author:		<AlbertoIxchop>
-- Create date: <20-09-2022>
-- Description:	<Hace la busqueda de puntos de visita por teléfono, correo o nombre>
-- =============================================
CREATE PROCEDURE [dbo].[sphw_SearchVisitPoints]
	-- Add the parameters for the stored procedure here
	@search NVARCHAR(80)=NULL,
	@filter INT = -1
		--0 TELEFONO,
		--1 CORREO,
		--2 NOMBRE
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT			  
	1 AS 'StatusCode',
	'Registros obtenidos' AS 'Description';


		SELECT 
		VP.CodeOfReference,
		VP.DescriptionOfClient,
		VP.ContactName,
		VP.Address,
		REPLACE(REPLACE(REPLACE(VP.Phone,'(502)',''),'-',''),' ','') 'Phone',
		VP.Email,
		VP.Town,
		VP.Department,
		VP.Latitude,
		VP.Longitude,
		ISNULL(UA.IdCityPlace,0) 'IdCityPlace',
		CP.CityPlace,
		PR.PerFirstName 'FirstName',
		PR.PerLastName 'LastName',
		AC.AccIdAccount 'IdAccount',
		IIF((CU.[Name] = 'Cliente Referenciado' AND CU.Domain = '@forzadelivery'),1,0) 'IsReferredCustomer',
		CU.Name 'CustomerName'
		FROM DBO.VisitPointClient VP
		LEFT JOIN DBO.UserAddress UA ON VP.CodeOfReference=UA.CodeOfReference
		LEFT JOIN DBO.Customer CU ON CU.IdCustomer=VP.CustomerID
		LEFT JOIN [DeliveryBackOffice].[dbo].[Account] Ac WITH(NOLOCK)
					ON Ac.IdCustomer = VP.CustomerID
		LEFT JOIN [DeliveryBackOffice].[dbo].[RolByUserByAccount] RBUBA WITH(NOLOCK)
					ON RBUBA.RuaIdAccount = Ac.AccIdAccount
		LEFT JOIN [DeliveryBackOffice].[dbo].[RegisterUser] RU WITH(NOLOCK)
					ON RU.UsrIdUser = RBUBA.RuaIdUser
		LEFT JOIN [DeliveryBackOffice].[dbo].[Person] PR WITH(NOLOCK)
					ON PR.PerIdPerson = RU.UsrIdPerson
		LEFT JOIN DBO.CatCityPlace CP ON UA.IdCityPlace=CP.IdCityPlace
		WHERE 
		(
			@filter =-1
			OR
			(@filter = 0 AND VP.Phone  LIKE '%'+@search+'%' COLLATE Latin1_General_CI_AI)
			OR
			(@filter = 1 AND RU.UsrEmail = @search COLLATE Latin1_General_CI_AI)
			OR
			(@filter = 2 AND CONCAT(PR.PerFirstName,' ',PR.PerLastName) like '%'+@search+'%' COLLATE Latin1_General_CI_AI)
		)
		AND VP.StatusClient = 1	;

	
END
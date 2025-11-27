
-- =============================================
-- Author:      <Andres, Ruiz>
-- Create date: <2022-05-12>
-- Description: < Busqueda avanzada de clientes buscando por una concidencia en puntos de visita >
-- =============================================
-- =============================================
-- Author:      <Daniel, Ramirez>
-- Create date: <2024-05-24>
-- Description: < Se agrego filtro para datos por pais, por defecto GT >
-- =============================================
CREATE PROCEDURE [dbo].[AdvancedGetCustomers]
(
    @Filter    NVARCHAR(100),
    @IdCountry NVARCHAR(2) = 'GT'
)
AS
BEGIN

	SELECT
		RTRIM(
				CONCAT(
					'[', Cu.IdCustomer, '] '
					, Cu.Name
					, ' '
					, IIF(Cu.CommercialName IS NOT NULL, CONCAT('[',Cu.CommercialName,'] '),'')
					, REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(Cu.CustomerPhone, RU.Phone),'(502)',''),'(504)',''),'-',''),' ','')
					, ' '
					, IIF(Cu.IdCustomerType = 3, CONCAT(ISNULL(RU.UsrEmail, ''),' '), '')
					, CONCAT('{', VPC.DescriptionOfClient, '}')
				)
			) 'Name',
			Cu.IdCustomerType,
			Cu.IdCustomer,
			VPC.IdVisitPointClient,
			ISNULL(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(Cu.CustomerPhone, RU.Phone),'(502)',''),'(504)',''),'-',''),' ',''),'') 'Phone'
	FROM
		[DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
        LEFT JOIN 
			[DeliveryBackOffice].[dbo].[Account] Ac WITH(NOLOCK)
				ON 
					Ac.IdCustomer = Cu.IdCustomer
        LEFT JOIN 
			[DeliveryBackOffice].[dbo].[RolByUserByAccount] RBUBA WITH(NOLOCK)
				ON 
					RBUBA.RuaIdAccount = Ac.AccIdAccount
        LEFT JOIN 
			[DeliveryBackOffice].[dbo].[RegisterUser] RU WITH(NOLOCK)
				ON 
					RU.UsrIdUser = RBUBA.RuaIdUser
		INNER JOIN
			[DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH(NOLOCK)
			ON
				Cu.IdCustomer = VPC.CustomerID
	WHERE
		VPC.DescriptionOfClient LIKE '%' + @Filter + '%' COLLATE Latin1_General_CI_AI
        AND VPC.StatusClient = 1
        AND IIF(VPC.CountryId IS NULL,'GT',VPC.CountryId) = @IdCountry
	UNION
	SELECT
		RTRIM(
				CONCAT(
					'[', Cu.IdCustomer, '] '
					, Cu.Name
					, ' '
					, IIF(Cu.CommercialName IS NOT NULL, CONCAT('[',Cu.CommercialName,'] '),'')
					, REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(Cu.CustomerPhone, RU.Phone),'(502)',''),'(504)',''),'-',''),' ','')
					, ' '
					, IIF(Cu.IdCustomerType = 3, CONCAT(ISNULL(RU.UsrEmail, ''),' '), '')
					, CONCAT('{', VPC.DescriptionOfClient,'|',VPC.Phone, '}')
				)
			) 'Name',
			Cu.IdCustomerType,
			Cu.IdCustomer,
			VPC.IdVisitPointClient,
			ISNULL(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(Cu.CustomerPhone, RU.Phone),'(502)',''),'(504)',''),'-',''),' ',''),'') 'Phone'
	FROM
		[DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
        LEFT JOIN 
			[DeliveryBackOffice].[dbo].[Account] Ac WITH(NOLOCK)
				ON 
					Ac.IdCustomer = Cu.IdCustomer
        LEFT JOIN 
			[DeliveryBackOffice].[dbo].[RolByUserByAccount] RBUBA WITH(NOLOCK)
				ON 
					RBUBA.RuaIdAccount = Ac.AccIdAccount
        LEFT JOIN 
			[DeliveryBackOffice].[dbo].[RegisterUser] RU WITH(NOLOCK)
				ON 
					RU.UsrIdUser = RBUBA.RuaIdUser
		INNER JOIN
			[DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH(NOLOCK)
			ON
				Cu.IdCustomer = VPC.CustomerID
	WHERE
		  VPC.Phone LIKE '%' + @Filter + '%' COLLATE Latin1_General_CI_AI
      AND VPC.StatusClient = 1
      AND IIF(VPC.CountryId IS NULL,'GT',VPC.CountryId) = @IdCountry

END


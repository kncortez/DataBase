-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-04-07>
-- Description:	< Obtiene la lista de clientes concatenando ID, nombre, nombre comercial, télefono, correo y puntos de visita>
-- =============================================
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-05-12>
-- Description:	< Remover campo de puntos de visita >
-- =============================================
-- =============================================
-- Author:      <Daniel, Ramirez>
-- Create date: <2024-05-24>
-- Description: <Agregar filtro de pais, por defecto GT>
-- =============================================
CREATE PROCEDURE [dbo].[GetCustomers]	
(
  @IdCountry VARCHAR(2) = 'GT'
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    
    SELECT
		DISTINCT
			RTRIM(
				CONCAT(
					'[', Cu.IdCustomer, '] '
					, Cu.Name
					, ' '
					, IIF(Cu.CommercialName IS NOT NULL, CONCAT('[',Cu.CommercialName,'] '),'')
					, REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(Cu.CustomerPhone, RU.Phone),'(502)',''),'(504)',''),'-',''),' ','')
					, ' '
					, IIF(Cu.IdCustomerType = 3, CONCAT(ISNULL(RU.UsrEmail, ''),' '), '')
				)
			) 'Name',
			Cu.IdCustomerType,
			Cu.IdCustomer,
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
    WHERE 
		ISNULL(Cu.RowSatus, 1) = 1
      AND IIF(cu.CountryID IS NULL, 'GT', cu.CountryID) = @IdCountry
	ORDER BY
		Cu.IdCustomer ASC

END
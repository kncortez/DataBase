-- =============================================
-- Author:		<Author,Edelman Vásquez>
-- Create date: <Create Date,2023-08-05>
-- Description:	<Description,Obtener nombre de los clientes corporativos para mostrar en un dropdownlist en módulo de gestión de Usuarios corporativos activos>
-- =============================================
CREATE PROCEDURE [dbo].[SPHD_GetCorporateUsers] 

AS
BEGIN

	SET NOCOUNT ON;

	
		SELECT 
		DISTINCT RTRIM([C].[Name]) AS [Name]
		FROM 
		[DeliveryBackOffice].[dbo].[customer] C WITH(NOLOCK)
		INNER JOIN 
		[DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH(NOLOCK)
		      ON [C].[IdCustomer] = [VPC].[CustomerId]
		WHERE [C].[IdCustomerType]=1
		      AND [C].RowSatus =1 
		ORDER BY [Name] ASC

   
END
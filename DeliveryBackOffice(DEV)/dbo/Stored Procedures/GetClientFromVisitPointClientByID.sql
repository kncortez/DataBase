
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-10-05>
-- Description:	<Obtener datos de cliente basado en el codigo de referencia de un punto de visita>
-- =============================================

CREATE PROCEDURE [dbo].[GetClientFromVisitPointClientByID]
	@CodeOfReference AS int
AS
BEGIN

	SELECT 
		IIF(LTRIM(RTRIM(ISNULL(VPC.Phone,''))) != '', LTRIM(RTRIM(VPC.Phone)), Cu.CustomerPhone) 'destinationPhone',
		IIF(LTRIM(RTRIM(ISNULL(VPC.DescriptionOfClient,''))) != '', LTRIM(RTRIM(VPC.DescriptionOfClient)), ISNULL(Cu.CommercialName, Cu.[Name])) 'destinationClientName',
		LTRIM(RTRIM(VPC.[Address])) 'AddressPickup'
	FROM 
		[DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH(NOLOCK)
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
			ON
				VPC.CustomerID = Cu.IdCustomer
	WHERE 
		VPC.CodeOfReference = @CodeOfReference

END
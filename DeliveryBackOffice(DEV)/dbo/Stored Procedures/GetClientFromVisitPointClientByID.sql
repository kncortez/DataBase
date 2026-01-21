/* =================================================
   SP:        [dbo].[ValidateBatchInvoice]
   Propósito: <Obtener datos de cliente basado en el codigo de referencia de un punto de visita>
   Autor:     <Andres Ruiz>
   Historia:  <>
   Fecha:     2022-10-05
============================================
=== CHANGELOG ================================
-- 2025-01-21 | Historia/épica: FDAPI-2982 | Autor: Cristian Azurdia |
-- 2022-10-05 | Historia/épica:  | Autor: Andres Ruiz |
=========================================== */

CREATE PROCEDURE [dbo].[GetClientFromVisitPointClientByID]
	@CodeOfReference AS int
AS
BEGIN

    SELECT 
    	ISNULL(dvpc.PrefixNumber, '') 'PrefixNumber',
    	IIF(LTRIM(RTRIM(ISNULL(VPC.Phone,''))) != '', LTRIM(RTRIM(VPC.Phone)), Cu.CustomerPhone) 'destinationPhone',
    	IIF(LTRIM(RTRIM(ISNULL(VPC.DescriptionOfClient,''))) != '', LTRIM(RTRIM(VPC.DescriptionOfClient)), ISNULL(Cu.CommercialName, Cu.[Name])) 'destinationClientName',
    	LTRIM(RTRIM(VPC.[Address])) 'AddressPickup'
    FROM 
    	[DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH(NOLOCK)
    	LEFT JOIN [DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
    		ON VPC.CustomerID = Cu.IdCustomer
    	LEFT JOIN [DeliveryBackOffice].[dbo].[DefaultValuesPerCountry] dvpc WITH(NOLOCK)
    		ON cu.CountryID = dvpc.IdCountry
	WHERE 
		VPC.CodeOfReference = @CodeOfReference

END
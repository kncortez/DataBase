
-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-09-01>
-- Description:	<SP para cargar data a Contact Center sobre clientes, este se ejecuta de 1 AM a 3 AM>
-- =============================================
-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-09-30>
-- Description:	<Se ha comentado la necesidad de cambiar los datos de tipo de cliente que se estan enviando, tomando la actividad que realizan en vez de si es individual, corporativo o redistribuidor>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_GetGuideFCCDataClients] 	
AS
BEGIN
	
	SET NOCOUNT ON;
	--- Información de Cliente por VisitPoint
 SELECT 
        ISNULL(VPC.ContactName,C.Name) AS ContactName,
		ISNULL(VPC.Address,'N/D') AS Address,
		ISNULL(C.CommercialName,C.Name) AS ComercialName,
		ISNULL(D.CommercialSegmentName,'N/D') AS TypeClient,
		ISNULL(VPC.Phone,'N/D') AS Phone	
 FROM [dbo].[VisitPointClient] VPC WITH (NOLOCK)
	LEFT JOIN [dbo].[Customer] C  WITH (NOLOCK)
 ON vpc.CustomerID = C.IdCustomer  AND C.RowSatus=1
	INNER JOIN [dbo].[CustomerType] CT WITH (NOLOCK)
 ON CT.IdCustomerType = C.IdCustomerType 
    LEFT JOIN [dbo].CatCommercialSegment D WITH (NOLOCK)
 ON  C.CommercialSegmentID = D.IdCommercialSegment
 WHERE VPC.StatusClient = 1
 ORDER BY VPC.DateCreated DESC;
END
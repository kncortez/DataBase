
-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-09-01>
-- Description:	<SP para cargar data a Contact Center sobre clientes, este se ejecuta de 1 AM a 3 AM>
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
		ISNULL(CT.Description,'N/D') AS TypeClient,
		ISNULL(VPC.Phone,'N/D') AS Phone	
 FROM [dbo].VisitPointClient VPC WITH (NOLOCK)
	LEFT JOIN Customer C  WITH (NOLOCK)
 ON vpc.CustomerID = C.IdCustomer 
	INNER JOIN CustomerType CT WITH (NOLOCK)
 ON CT.IdCustomerType =C.IdCustomerType 
 WHERE VPC.StatusClient = 1
 ORDER BY VPC.DateCreated DESC;
END
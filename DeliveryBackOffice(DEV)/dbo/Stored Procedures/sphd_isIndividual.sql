
-- =============================================
-- Author:      <Sazo,Cesar>
-- Create date: <2021-11-19>
-- Description: <Validar si el cliente es individual>
-- =============================================

CREATE PROCEDURE [dbo].[sphd_isIndividual]
    @CustomerID AS INT
AS
BEGIN
    SELECT 1
    FROM DeliveryBackOffice.dbo.Customer c
        INNER JOIN DeliveryBackOffice.dbo.CustomerType ct
            ON c.IdCustomerType = ct.IdCustomerType
    WHERE c.IdCustomer = @CustomerID
	AND c.IdCustomerType = 3
END
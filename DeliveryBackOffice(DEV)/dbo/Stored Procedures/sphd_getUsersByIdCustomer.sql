
-- =============================================
-- Author:      <Sazo,Cesar>
-- Create date: <2021-11-02>
-- Description: <Obtener informacion de los clientes individuales>
-- =============================================

CREATE PROCEDURE [dbo].[sphd_getUsersByIdCustomer]
    @IdVisitPointClient AS INT
AS
BEGIN
    SELECT c.Name + ' ' + ISNULL(ru.UsrEmail, '') Name
    FROM DeliveryBackOffice.dbo.Customer c
        INNER JOIN DeliveryBackOffice.dbo.CustomerType ct
            ON c.IdCustomerType = ct.IdCustomerType
        LEFT JOIN dbo.Account a 
            ON a.IdCustomer = c.IdCustomer
        LEFT JOIN dbo.RolByUserByAccount rua 
            ON rua.RuaIdAccount = a.AccIdAccount
        LEFT JOIN DeliveryBackOffice.dbo.RegisterUser ru
            ON ru.UsrIdUser = rua.RuaIdUser
        JOIN DeliveryBackOffice.[dbo].[VisitPointClient] vpc 
            ON c.IdCustomer = vpc.CustomerID
    WHERE ISNULL(c.RowSatus, 1) = 1 AND
    vpc.IdVisitPointClient =  @IdVisitPointClient
END
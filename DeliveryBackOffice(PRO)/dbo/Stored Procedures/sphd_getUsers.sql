
-- =============================================
-- Author:      <Sazo,Cesar>
-- Create date: <2021-12-03>
-- Description: <Obtener informacion de los clientes>
-- =============================================

CREATE PROCEDURE [dbo].[sphd_getUsers]
AS
BEGIN
    SELECT c.Name + ' ' + ISNULL(ru.UsrEmail, '') Name,
           c.IdCustomer
    FROM DeliveryBackOffice.dbo.Customer c
        LEFT JOIN dbo.Account a 
            ON a.IdCustomer = c.IdCustomer
        LEFT JOIN dbo.RolByUserByAccount rua 
            ON rua.RuaIdAccount = a.AccIdAccount
        LEFT JOIN DeliveryBackOffice.dbo.RegisterUser ru
            ON ru.UsrIdUser = rua.RuaIdUser
    WHERE ISNULL(c.RowSatus, 1) = 1
END
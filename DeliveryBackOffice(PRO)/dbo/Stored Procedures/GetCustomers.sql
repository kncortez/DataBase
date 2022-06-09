-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-04-07>
-- Description:	< Obtiene la lista de clientes concatenando ID, nombre, nombre comercial, télefono, correo y puntos de visita>
-- =============================================
CREATE PROCEDURE [dbo].[GetCustomers]
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;


    SELECT DISTINCT
           RTRIM(CONCAT(
                           '[',
                           Cu.IdCustomer,
                           '] ',
                           Cu.Name,
                           ' ',
                           IIF(Cu.CommercialName IS NOT NULL, CONCAT('[', Cu.CommercialName, '] '), ''),
                           REPLACE(REPLACE(REPLACE(ISNULL(Cu.CustomerPhone, RU.Phone), '(502)', ''), '-', ''), ' ', ''),
                           ' ',
                           IIF(Cu.IdCustomerType = 3, CONCAT(ISNULL(RU.UsrEmail, ''), ' '), ''),
                           REPLACE(
                                      REPLACE(
                                                 CONCAT(
                                                           '{',
                                                 --(
                                                 --    SELECT STUFF(
                                                 --           (
                                                 --               SELECT CONCAT('|', VPC.DescriptionOfClient, '')
                                                 --               FROM [DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH (NOLOCK)
                                                 --               WHERE VPC.StatusClient = 1
                                                 --                     AND VPC.CustomerID = Cu.IdCustomer
                                                 --               FOR XML PATH('')
                                                 --           ),
                                                 --           1,
                                                 --           1,
                                                 --           ''
                                                 --                )
                                                 --),
                                                           '}'
                                                       ),
                                                 '&amp;',
                                                 '&'
                                             ),
                                      '&quot;',
                                      '"'
                                  ),
                           IIF(Cu.TypeOfBusinessID IS NOT NULL, CONCAT('{', CTOB.TypeOfBusinessDescription, '}'), '')
                       )
                ) 'Name',
           Cu.IdCustomerType,
           Cu.IdCustomer,
           ISNULL(REPLACE(REPLACE(REPLACE(ISNULL(Cu.CustomerPhone, RU.Phone), '(502)', ''), '-', ''), ' ', ''), '') 'Phone'
    FROM [DeliveryBackOffice].[dbo].[Customer] Cu WITH (NOLOCK)
        LEFT JOIN [DeliveryBackOffice].[dbo].[Account] Ac WITH (NOLOCK)
            ON Ac.IdCustomer = Cu.IdCustomer
        LEFT JOIN [DeliveryBackOffice].[dbo].[RolByUserByAccount] RBUBA WITH (NOLOCK)
            ON RBUBA.RuaIdAccount = Ac.AccIdAccount
        LEFT JOIN [DeliveryBackOffice].[dbo].[RegisterUser] RU WITH (NOLOCK)
            ON RU.UsrIdUser = RBUBA.RuaIdUser
        LEFT JOIN [DeliveryBackOffice].[dbo].[CatTypeOfBusiness] CTOB WITH (NOLOCK)
            ON Cu.TypeOfBusinessID = CTOB.IdTypeOfBusiness
    WHERE ISNULL(Cu.RowSatus, 1) = 1
    ORDER BY Cu.IdCustomer ASC;

END;
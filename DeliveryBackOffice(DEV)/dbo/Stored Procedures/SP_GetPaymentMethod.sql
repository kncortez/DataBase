-- =============================================
-- Author:		<Aylinne Recinos>
-- Create date: <2024-28-10>
-- Description:	<Método para obtener el listado de tarjetas registradas>
-- =============================================

CREATE PROCEDURE [dbo].[SP_GetPaymentMethod]
@IdAccount INT
AS
BEGIN  
    SELECT  cpv.IdCustomerPaymentValue AS Id,
            cpv.DisplayText AS DisplayText,
            IIF(cpv.IsDefault = 1, 'true','false') AS IsDefault
    FROM CustomerPaymentValue cpv  
    WHERE (cpv.AccountId = @IdAccount  
    OR (cpv.AccountId IS NULL AND cpv.CustomerId = (SELECT IdCustomer FROM Account WHERE AccIdAccount = @IdAccount)))  
    AND cpv.RowStatus = 1  
END ;
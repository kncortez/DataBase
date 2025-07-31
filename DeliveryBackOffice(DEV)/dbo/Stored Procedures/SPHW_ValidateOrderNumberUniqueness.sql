-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,31/07/2025>
-- Description:	<Description,Validar UUID para transferencia PayWayOne SV>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_ValidateOrderNumberUniqueness]
    @OrderNumber NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 FROM [dbo].[RegistrationofTransactionProcessStates] 
        WHERE OrderNumber = @OrderNumber
    ) OR EXISTS (
        SELECT 1 FROM [dbo].[CreditCardTransactionByCustomer] 
        WHERE OrderNumber = @OrderNumber
    )
    BEGIN
        SELECT 1 AS IsDuplicated; -- Ya existe
    END
    ELSE
    BEGIN
        SELECT 0 AS IsDuplicated; -- Es único
    END
END


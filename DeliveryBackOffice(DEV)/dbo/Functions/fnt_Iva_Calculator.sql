
CREATE FUNCTION [dbo].[fnt_Iva_Calculator](@Calculate bit, @IdCountry nvarchar(2), @Value decimal(12,2), @getTax bit  )
RETURNS decimal (12,2)
BEGIN

    DECLARE @TaxRate decimal (12,2)
    DECLARE @AmountNonTaxes decimal (12,2)
    DECLARE @TaxValue decimal(12,2)
    DECLARE @ReturnValue decimal(12,2)


    IF @Calculate ='true'
    BEGIN

        SET @TaxRate = (SELECT [value] FROM ConfigParams WHERE  [Name] = 'TaxPercentage' and [Status] = 1 and IdCountry = @IdCountry)
        SET @AmountNonTaxes = @Value / @TaxRate
        SET @TaxValue = @AmountNonTaxes * (1-@TaxRate)

        IF  @getTax ='true'
            SET @ReturnValue = @TaxValue
        ELSE
            SET @ReturnValue= @AmountNonTaxes

    END
    ELSE 
    BEGIN

        IF @getTax ='TRUE'
            SET @ReturnValue = 0
        ELSE
            SET @ReturnValue = @Value

    END

    RETURN @ReturnValue

END

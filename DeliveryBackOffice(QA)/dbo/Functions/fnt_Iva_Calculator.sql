
CREATE FUNCTION [dbo].[fnt_Iva_Calculator](@Calculate bit, @IdCountry nvarchar(2), @Value decimal(12,2), @getTax bit  )
RETURNS decimal (12,2)
BEGIN
  DECLARE @TaxRate decimal (12,2)
  DECLARE @AmountNonTaxes decimal (12,2)
  DECLARE @TaxValue decimal(12,2)
  DECLARE @ReturnValue decimal(12,2)


  if @Calculate ='true'
	BEGIN
		set @TaxRate =  (select top 1 ( sur.PercentValue) from dbo.Surcharge sur where sur.IdSurcharge = 6 )
		set @AmountNonTaxes = @Value / (1+ (@TaxRate/100))
		set @TaxValue = @AmountNonTaxes * (@TaxRate /100)
		If @getTax ='true'
			set @ReturnValue = @TaxValue
		else
			set @ReturnValue= @AmountNonTaxes
	END
	ELSE 
	begin
		IF @getTax ='TRUE'
		set @ReturnValue = 0
		ELSE
		set @ReturnValue = @Value
	end

	return @ReturnValue

END

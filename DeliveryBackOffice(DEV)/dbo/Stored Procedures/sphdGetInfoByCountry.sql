-- =============================================
-- Author:		<Brandon, Pedroza>
-- Create date: <2025-05-01>
-- Description:	<Multipais SV - Se obtienen informacion por pais>
-- =============================================
CREATE PROCEDURE [dbo].[sphdGetInfoByCountry]
	@IdCountry AS NVARCHAR(2)= 'GT'
AS
BEGIN

	SET NOCOUNT ON;
		SELECT 
		DNIShortName,
		DNIDescription,
		RegxDNI,
		TaxShortName,
		TaxDescription,
		RegxPayerTaxNumber,
		DNIMaxLength,
		PrefixNumber,
		IconFlag,
		CC.Symbol AS SymbolCurrency,
		CultureInfo
	FROM DefaultValuesPerCountry DPC WITH(NOLOCK)
	INNER JOIN DeliveryCurrency DC WITH(NOLOCK)
		ON DC.Currency_IdCountry = DPC.IdCountry
	INNER JOIN CatCurrencyCOD CC
		ON DC. IdCurrencyCOD = CC.IdCatCurrencyCOD
	WHERE DPC.IdCountry = @IdCountry
		AND DC.DefaultPerCountry = 1;


	SELECT IconFlag,
		PrefixNumber
	FROM DefaultValuesPerCountry WITH(NOLOCK)

END

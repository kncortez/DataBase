-- =============================================
-- Author:		<Brandon, Pedroza>
-- Create date: <2024-06-11>
-- Description:	<Obtiene las monedas disponibles para un pais, haciendo la relacion entre CatCurrencyCOD y DeliveryCurrency>
-- =============================================
CREATE PROCEDURE [dbo].[sphdGetCurrencyByCountry] @IdCountry AS NVARCHAR(2) = 'GT'
AS
BEGIN
SELECT CU.IdCatCurrencyCOD [IdCurrency],
       DC.Currency_Name [Name],
       DC.Currency_Symbol [Symbol],
       DC.Currency_Name + ' - ' + DC.Currency_Symbol AS [Description],
	   CU.CodeISO [CodeISO]
FROM DeliveryCurrency DC
    INNER JOIN CatCurrencyCOD CU WITH (NOLOCK)
        ON DC.IdCurrencyCOD = CU.IdCatCurrencyCOD WITH (NOLOCK)
WHERE CU.RowStatus = 1
      AND IIF(DC.Currency_IdCountry IS NULL, 'GT', DC.Currency_IdCountry) = @IdCountry
END

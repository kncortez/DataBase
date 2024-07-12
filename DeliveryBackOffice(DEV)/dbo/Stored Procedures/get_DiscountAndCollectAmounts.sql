-- =============================================
-- Author:		<Tito Garcia>
-- Create date: <11-07-2024>
-- Description:	<Obtiene los montos de descuento y collect en los envios segun el pais donde este ingresando >
-- =============================================
CREATE PROCEDURE [dbo].[get_DiscountAndCollectAmounts] 
	@CodeAppGT NVARCHAR(100),
	@CodeAppHN NVARCHAR(100)
AS
BEGIN
    DECLARE @jsonResult NVARCHAR(MAX);

    BEGIN
        SET @jsonResult =
        (
            SELECT STUFF(
                            (
							SELECT 
								',{"Country":"' + ISNULL(CONVERT(VARCHAR, e.IdCountry), '') + '",' 
								+ '"DiscountAmount":"' + ISNULL(CONVERT(VARCHAR, cp.value), '') + '",' 
								+ '"CollectAmount":"' + ISNULL(CONVERT(VARCHAR, rh.CollectRate), '') + '",' 
								+ '"CurrencySymbol":"' + ISNULL(CONVERT(VARCHAR, ccc.Symbol), '') 
								+ '"' + '}'
							FROM Ecommerce e WITH (NOLOCK)
								INNER JOIN Customer c WITH (NOLOCK) 
									ON e.IdCustomer = c.IdCustomer
								INNER JOIN RatebyCustomer rbc WITH (NOLOCK) 
									ON c.IdCustomer = rbc.RbcIdCustomer
								INNER JOIN RateHeader rh WITH (NOLOCK) 
									ON rbc.RbcIdRate = rh.RheId
								INNER JOIN CatCurrencyCOD ccc 
									ON ccc.IdCatCurrencyCOD = rh.IdCurrency
								LEFT JOIN [dbo].ConfigParams cp 
									ON cp.Name = 'DiscountAmuountByCountry' 
													AND cp.IdCountry = c.CountryID 
													AND cp.Status = 1
							WHERE e.userkey IN (@CodeAppGT,@CodeAppHN)
							ORDER BY e.IdCountry ASC
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)')
                          , 1
                          , 1
                          , ''
                        )
        );
    END;
    SELECT '[' + @jsonResult + ']' FormatJson;
END;



-- =============================================
-- Author:		<Oscar,Morales>
-- Create date: <2021-11-26>
-- Description:	<Obtiene información de divisas y denominaciones>
-- =============================================

CREATE PROCEDURE [dbo].[GetMoneyDenominations]
    -- Add the parameters for the stored procedure here
    @IdCountry NVARCHAR(10)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
	
	SELECT Currency_Id, Currency_Name, Currency_Symbol, CONCAT(Currency_Name, ' ', Currency_Symbol) Currency_Label
	FROM DeliveryCurrency
	WHERE Currency_IdCountry = @IdCountry AND Currency_Status = 1
	ORDER BY Currency_Order

	SELECT cm.IdCatMoney, cm.CurrencyId, cm.Type, cm.Value Denomination 
	FROM CatMoney cm
	INNER JOIN DeliveryCurrency dc 
		ON cm.CurrencyId = dc.Currency_Id
	WHERE dc.Currency_IdCountry = @IdCountry AND dc.Currency_Status = 1 
		AND cm.RowStatus = 1
	ORDER BY cm.Type, cm.Value DESC


    SET NOCOUNT OFF;
END;
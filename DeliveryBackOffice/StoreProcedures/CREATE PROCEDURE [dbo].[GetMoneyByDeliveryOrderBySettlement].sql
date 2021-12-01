USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[GetMoneyByDeliveryOrderBySettlement]    Script Date: 30/11/2021 10:56:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Oscar,Morales>
-- Create date: <2021-11-30>
-- Description:	<Obtiene información de las denominaciones registradas en liquidación ultima milla COD>
-- =============================================

CREATE PROCEDURE [dbo].[GetMoneyByDeliveryOrderBySettlement]
    -- Add the parameters for the stored procedure here
	@IdDeliveryOrderBySettlement INT
AS
BEGIN
	
	--Table 0 TotalAmountCount
	SELECT SUM(mdos.Quantity*cm.Value) TotalAmountCount
	FROM MoneyByDeliveryOrderBySettlement mdos
	INNER JOIN CatMoney cm
		ON mdos.CatMoneyId = cm.IdCatMoney
	WHERE DeliveryOrderBySettlementId = @IdDeliveryOrderBySettlement

	--Table 1 Currency
	SELECT TOP 1 CONCAT(dc.Currency_Name, ' ', dc.Currency_Symbol) Currency 
	FROM MoneyByDeliveryOrderBySettlement mdos
	INNER JOIN CatMoney cm
		ON mdos.CatMoneyId = cm.IdCatMoney
	INNER JOIN DeliveryCurrency dc
		ON cm.CurrencyId = dc.Currency_Id
	WHERE DeliveryOrderBySettlementId = @IdDeliveryOrderBySettlement

END;
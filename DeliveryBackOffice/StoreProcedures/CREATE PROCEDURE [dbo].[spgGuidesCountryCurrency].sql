USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[spgGuidesCountryCurrency]    Script Date: 14/01/2021 7:38:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		<Gomez, Hugo>
-- Create date: <2021-01-08>
-- Description:	<Devuelve los montos y la suma del total del servicio>
-- =============================================
CREATE PROCEDURE [dbo].[spgGuidesCountryCurrency]
	 @OrderCurrency int,
	 @CurrencyId varchar(10)
	

AS
BEGIN

  select Currency_Description, Currency_Symbol, Currency_Name from DeliveryCurrency
  where Currency_Order = @OrderCurrency and Currency_IdCountry = @CurrencyId

END
GO



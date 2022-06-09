-- =============================================
-- Author:		<Abner, Juarez>
-- Create date: <2020-02-16>
-- Description:	<Retorna el valor de la tabla CatToCharge>
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_valueCharge]
AS
BEGIN
	--SELECT Value FROM [DeliveryBackOffice].[dbo].[CatToCharge] WHERE IdToCharge = 1;
	SELECT cargo.Value [Value] FROM  [dbo].[CatToCharge] cargo
				JOIN [dbo].[Unit] unidad on cargo.UnitId = unidad.IdUnit
				JOIN DeliveryBackOffice.dbo.DeliveryCurrency curr
					on curr.Currency_IdCountry = cargo.CountryId
					and curr.Currency_Id = cargo.CurrencyId
	where unidad.TypeUnit = 'Price'
	and cargo.Name = 'PickupRate'
	and cargo.CountryId = 'GT'
END
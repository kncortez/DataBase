-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2025-04-08>
-- Description:	<Método para validar el monto minimo de COD que se desea ingresar en la creación de una guía multipaís.>
-- =============================================

CREATE PROCEDURE [dbo].[SPHW_GetValidateMinimumCODAmount]
@ConfigParamsName NVARCHAR(25) = 'MinimumCODAmount',
@AmmountCashOnDelivery DECIMAL(18, 2) = 1,
@IdCountry NVARCHAR(2) = 'GT'
AS
BEGIN
BEGIN TRY

	DECLARE @AmountMinimum DECIMAL(18, 2) =
	(SELECT CAST([Value] AS DECIMAL(18, 2)) FROM DeliveryBackOffice.dbo.ConfigParams
	WHERE [Name] = @ConfigParamsName AND (IdCountry = @IdCountry OR (IdCountry IS NULL AND @IdCountry = 'GT')))

	IF @AmmountCashOnDelivery >= @AmountMinimum
	BEGIN
		SELECT
			'TRUE' AS Result
	END
	ELSE
	BEGIN
		SELECT
			'Monto mínimo para COD es de ' + CCC.Symbol + '.' + CAST(@AmountMinimum AS NVARCHAR(10)) AS Result
		FROM
		DeliveryBackOffice.dbo.DeliveryCurrency DC WITH(NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.CatCurrencyCOD CCC WITH(NOLOCK)
			ON DC.IdCurrencyCOD = CCC.IdCatCurrencyCOD
		WHERE DC.Currency_IdCountry = @IdCountry AND DC.DefaultPerCountry = 1
	END;

END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
END;
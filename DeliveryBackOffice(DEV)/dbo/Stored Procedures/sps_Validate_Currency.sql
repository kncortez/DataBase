-- =============================================
-- Author:		<CRISTIAN SUAZO>
-- Create date: <2024-05-243>
-- Description:	<Valida el tipo de moneda aceptado por un pais para una nueva preparacion en Hermes>
-- =============================================
-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2025-04-02>
-- Description:	<Cambios de multipaís para SV.>
-- =============================================
CREATE PROCEDURE [dbo].[sps_Validate_Currency] 
		@GuideSerie NVARCHAR(2) = 'FD',
		@GuideNumber INT,
		@CountryId NVARCHAR(3) = 'GT'
AS
BEGIN
	DECLARE @Currency INT,
            @Validate INT

	SELECT @Currency = C.IdCatCurrencyCOD FROM DeliveryBackOffice.dbo.CatCurrencyCOD C WITH(NOLOCK)
	INNER JOIN DeliveryBackOffice.dbo.DeliveryCurrency DC WITH(NOLOCK) 
		ON C.IdCatCurrencyCOD = DC.IdCurrencyCOD
	WHERE DC.Currency_IdCountry = @CountryId AND DC.DefaultPerCountry = 1

	PRINT @Currency
	BEGIN TRY

	-------Validamos si la divisa es la misma al pais logueado, si no devuelve 0
        PRINT 'ENTRO'
		SELECT @Validate = C.IdCost 
		FROM Cost C
		WHERE GuideNumber = @GuideNumber 
		AND C.GuideSerie = @GuideSerie
		AND ISNULL(C.ShippingCurrency,1) = @Currency

		IF @Validate IS NOT NULL
		BEGIN
			SELECT 
			1 AS 'StatusCode',
			'La moneda origen es la misma al pais logueado!' AS 'Description'
		END
		ELSE
		BEGIN
			SELECT 
			0 AS 'StatusCode',
			'La moneda origen no coincide con el pais logueado' AS 'Description'
		END

	END TRY
	BEGIN CATCH
			SELECT
				0 AS 'StatusCode',
				ERROR_MESSAGE() AS 'Description',
				ERROR_LINE() AS 'Line'
	END CATCH
END
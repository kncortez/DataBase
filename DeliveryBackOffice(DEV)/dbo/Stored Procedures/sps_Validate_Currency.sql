-- =============================================
-- Author:		<CRISTIAN SUAZO>
-- Create date: <2024-05-243>
-- Description:	<Valida el tipo de moneda aceptado por un pais para una nueva preparacion en Hermes>
-- =============================================
CREATE PROCEDURE [dbo].[sps_Validate_Currency] 
		@GuideSerie NVARCHAR(2) = 'FD',
		@GuideNumber INT,
		@CountryId NVARCHAR(3) = 'GT'
AS
BEGIN
	DECLARE @CurrencyContry NVARCHAR(5),
			@Currency INT,
			@Validate INT

	DECLARE @CurrencyGT INT = (SELECT IdCatCurrencyCOD FROM CatCurrencyCOD WHERE Symbol = 'Q')
	DECLARE @CurrencyHN INT = (SELECT IdCatCurrencyCOD FROM CatCurrencyCOD WHERE Symbol = 'L')

	SELECT @Currency = CASE WHEN  @CountryId = 'GT' THEN @CurrencyGT ELSE @CurrencyHN END
	PRINT @Currency
	BEGIN TRY

	-------Validamos si la divisa es la misma al pais logueado, si no devuelve 0
        PRINT 'ENTRO'
		SELECT @Validate = C.IdCost 
		FROM Cost C
		WHERE GuideNumber = @GuideNumber 
		AND C.GuideSerie = @GuideSerie
		AND ISNULL(C.ShippingCurrency,@CurrencyGT) = @Currency

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

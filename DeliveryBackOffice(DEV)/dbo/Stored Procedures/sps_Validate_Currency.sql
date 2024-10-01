-- =============================================
-- Author:		<CRISTIAN SUAZO>
-- Create date: <2024-05-24>
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
            @Validate INT,
            @CurrencyGT INT

    BEGIN TRY
        SET @CurrencyGT =
        (
            SELECT IdCatCurrencyCOD
            FROM CatCurrencyCOD WITH (NOLOCK)
            WHERE Symbol = 'Q'
        )

        SELECT @Currency = CC.IdCatCurrencyCOD
        FROM DeliveryCurrency DC WITH (NOLOCK)
            INNER JOIN CatCurrencyCOD CC WITH (NOLOCK)
                ON DC.IdCurrencyCOD = CC.IdCatCurrencyCOD
        WHERE ISNULL(Currency_IdCountry,'GT') = @CountryId
              AND DefaultPerCountry = 1

        SELECT @Validate = C.IdCost
        FROM Cost C WITH (NOLOCK)
        WHERE GuideNumber = @GuideNumber
              AND C.GuideSerie = @GuideSerie
              AND ISNULL(C.ShippingCurrency, @CurrencyGT) = @Currency

        IF @Validate IS NOT NULL
        BEGIN
            SELECT 1 AS 'StatusCode',
                   'La moneda origen es la misma al pais logueado!' AS 'Description'
        END
        ELSE
        BEGIN
            SELECT 0 AS 'StatusCode',
                   'La moneda origen no coincide con el pais logueado' AS 'Description'
        END

    END TRY
    BEGIN CATCH
        SELECT 0 AS 'StatusCode',
               ERROR_MESSAGE() AS 'Description',
               ERROR_LINE() AS 'Line'
    END CATCH
END
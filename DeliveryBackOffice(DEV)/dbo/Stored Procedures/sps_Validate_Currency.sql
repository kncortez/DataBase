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
	DECLARE @ValidCod NVARCHAR(10), 
			@Paid INT,
			@CurrencyContry NVARCHAR(5),
			@Currency NVARCHAR(10)

	BEGIN TRY
	--SETEAMOS VALORES DE PAGO Y FACTURACION
		SELECT @ValidCod = DO.TypeService,
			   @Paid = TotalAmountPaid
		FROM DeliveryOrder DO WITH(NOLOCK)
		LEFT JOIN Cost C 
			ON DO.Guide_Number = C.GuideNumber
		WHERE DO.Guide_Serie = @GuideSerie 
				AND DO.Guide_Number = @GuideNumber
		
		--VERIFICAR SI LA GUIA YA FUE PAGADA
		IF (SELECT dti_fk_header FROM invoiceDetail WHERE dti_fk_orderNumber = @GuideNumber) IS NULL OR @Paid  IS NULL
		BEGIN
		--VERIFICAR SI ES COD
			IF(@ValidCod = 'COD')
			BEGIN

				SELECT 1 AS 'StatusCode', 
					   ISNULL(DC.Currency_IdCountry, 'GT') AS Country,
					   DC.Currency_Symbol
				FROM Cost C WITH(NOLOCK)
				INNER JOIN DeliveryCurrency DC WITH(NOLOCK) 
					ON C.CodCurrency = DC.Currency_Id
				WHERE C.GuideSerie = @GuideSerie 
					  AND C.GuideNumber = @GuideNumber
					  AND DC.Currency_IdCountry = @CountryId

			END
			IF (@ValidCod = 'STD')
			BEGIN

				SELECT 1 AS 'StatusCode',
					   ISNULL(DC.Currency_IdCountry, 'GT') AS Country,
					   DC.Currency_Symbol
				FROM Cost C WITH(NOLOCK)
				INNER JOIN DeliveryCurrency DC WITH(NOLOCK) 
					ON C.ShippingCurrency = DC.Currency_Id
				WHERE C.GuideSerie = @GuideSerie 
					  AND C.GuideNumber = @GuideNumber
					  AND DC.Currency_IdCountry = @CountryId

			END
			ELSE
			BEGIN
				SELECT
					0 AS 'StatusCode',
					'Tipo de guia desconocido' AS 'Description'
			END
		END
		ELSE
		BEGIN
			SELECT 
				1 AS 'StatusCode',
				'Guia pagada' AS 'Description'
		END
	END TRY
	BEGIN CATCH
			SELECT
				0 AS 'StatusCode',
				ERROR_MESSAGE() AS 'Description'
	END CATCH
END

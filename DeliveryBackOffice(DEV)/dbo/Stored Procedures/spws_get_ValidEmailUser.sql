
/* =================================================
   SP: spws_get_ValidEmailUser
   Propósito: Validar si el correo tiene cuenta y esa cuenta pertenece al país de compra
   Autor:     Edelman Vasquez
   Historia:  PENDIENTE
   Fecha:     2024-07-24
================================================= */
/* === CHANGELOG ============================
2020-01-08 | Historia/épica: (pendiente)  | Autor: Edelman Vásquez  | Validar si el correo tiene cuenta y esa cuenta pertenece al país de compra
2024-04-24 | Historia/épica: FDAPI-5807   | Autor: Cristian Azurdia | Pais de origen depende la moneda del usuario y la moneda por defecto del pais
=========================================== */

CREATE PROCEDURE [dbo].[spws_get_ValidEmailUser]
	@Email VARCHAR(100),
	@CountryId VARCHAR(3) = 'GT'
AS
BEGIN
	SET NOCOUNT ON;

  DECLARE   @IdCountryOrigin  VARCHAR(3) = (SELECT TOP 1
                                                Currency_IdCountry
                                            FROM [DeliveryBackOffice].[dbo].[RegisterUser] ru WITH(NOLOCK)
                                            INNER JOIN CatCurrencyCOD ccc
                                            on ru.UsrCurrency = ccc.CodeISO
                                            INNER JOIN DeliveryCurrency dc
                                            on ccc.IdCatCurrencyCOD = dc.IdCurrencyCOD
                                            WHERE DefaultPerCountry = 1
                                            and UsrEmail = @Email)

    IF(
         EXISTS(SELECT TOP 1 
                     1
          FROM [DeliveryBackOffice].[dbo].[RegisterUser] WHERE UsrEmail = @Email)
      )
      BEGIN
        IF(@IdCountryOrigin = @CountryId)
        BEGIN
            SELECT 1 AS 'IsValid'
        END
          ELSE
            SELECT 0 AS 'IsValid'
      END
         ELSE
            SELECT 1 AS 'IsValid'

END




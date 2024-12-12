

-- =============================================
-- Description:	<SP para obtener información de un cliente que envía archivos para generar guías desde el parser, 
-- 				por medio del correo del que fueron enviados los archivos>
-- Nota: Este SP solamente es utilizado por el parser
-- =============================================
-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <26/08/2024>
-- Description:	<Se agrega el CountryID en la respuesta del SP>
-- =============================================
-- =============================================
-- Author:		<Aylinne Recinos>
-- Create date: <12/12/2024>
-- Description:	<Se agrega el ActiveUser en la respuesta del SP>
-- =============================================

CREATE PROCEDURE [dbo].[sp_get_customerParser]
@Email AS VARCHAR(50)='jordy.lemus@forzadelivery.com'
AS

BEGIN

DECLARE @Cantidad INT
DECLARE @expresion VARCHAR(50)
DECLARE @expresion2 VARCHAR(50)

SET @Cantidad = (SELECT count(IdCustomer) FROM Customer WHERE RegexEmail Like '%' + @Email + '%')

	IF (@Cantidad > 0)
		BEGIN
			SELECT IdCustomer, Name, RegexSubject, RegexEmail, RegexFilename, ISNULL(CountryID,'GT') AS CountryID, ISNULL(RowSatus,1) AS ActiveUser FROM Customer
				 WHERE RegexEmail Like '%' + @Email + '%'
		END

	ELSE 
		BEGIN
			SET @expresion=(SELECT SUBSTRING(@Email,CHARINDEX('@', @Email) + 1,
			LEN(@Email) - CHARINDEX('@', @Email)))

			SET @expresion2 = ('^([\w\.\-]+)@'+@expresion+'$')

			SELECT IdCustomer, Name, RegexSubject, RegexEmail, RegexFilename,ISNULL(CountryID,'GT') AS CountryID  FROM Customer
					WHERE RegexEmail = @expresion2
		END
END
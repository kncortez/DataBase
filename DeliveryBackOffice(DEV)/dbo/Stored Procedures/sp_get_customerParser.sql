

-- =============================================
-- Description:	<SP para obtener información de un cliente que envía archivos para generar guías desde el parser, 
-- 				por medio del correo del que fueron enviados los archivos>
-- Nota: Este SP solamente es utilizado por el parser
-- =============================================

CREATE PROCEDURE [dbo].[sp_get_customerParser]
@Email AS VARCHAR(50)
AS

BEGIN

DECLARE @Cantidad INT
DECLARE @expresion VARCHAR(50)
DECLARE @expresion2 VARCHAR(50)

SET @Cantidad = (SELECT count(IdCustomer) FROM Customer WHERE RegexEmail Like '%' + @Email + '%')

	IF (@Cantidad > 0)
		BEGIN
			SELECT IdCustomer, Name, RegexSubject, RegexEmail, RegexFilename FROM Customer
				 WHERE RegexEmail Like '%' + @Email + '%'
		END

	ELSE 
		BEGIN
			SET @expresion=(SELECT SUBSTRING(@Email,CHARINDEX('@', @Email) + 1,
			LEN(@Email) - CHARINDEX('@', @Email)))

			SET @expresion2 = ('^([\w\.\-]+)@'+@expresion+'$')

			SELECT IdCustomer, Name, RegexSubject, RegexEmail, RegexFilename FROM Customer
					WHERE RegexEmail = @expresion2
		END
END
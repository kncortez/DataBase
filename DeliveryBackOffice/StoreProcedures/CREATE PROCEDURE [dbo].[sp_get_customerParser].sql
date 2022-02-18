USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[sp_get_customerParser]    Script Date: 18/02/2022 09:05:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_get_customerParser]
@Email AS VARCHAR(50)
AS

BEGIN

DECLARE @Cantidad INT
DECLARE @expresion VARCHAR(50)
DECLARE @expresion2 VARCHAR(50)

SET @Cantidad = (SELECT count(IdCustomer) FROM Customer_Parser WHERE RegexEmail Like '%' + @Email + '%')

	IF (@Cantidad > 0)
		BEGIN
			SELECT IdCustomer, Name, RegexSubject, RegexEmail, RegexFilename FROM Customer_Parser
				 WHERE RegexEmail Like '%' + @Email + '%'
		END

	ELSE 
		BEGIN
			SET @expresion=(SELECT SUBSTRING(@Email,CHARINDEX('@', @Email) + 1,
			LEN(@Email) - CHARINDEX('@', @Email)))

			SET @expresion2 = ('^([\w\.\-]+)@'+@expresion+'$')

			SELECT IdCustomer, Name, RegexSubject, RegexEmail, RegexFilename FROM Customer_Parser
					WHERE RegexEmail = @expresion2
		END
END
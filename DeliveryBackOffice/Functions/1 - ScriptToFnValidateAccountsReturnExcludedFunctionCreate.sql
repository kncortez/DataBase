USE [DeliveryBackOffice]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_validate_customer_bank_account]    Script Date: 16/08/2021 09:08:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fn_validate_customer_bank_account]
(
	@NumAccount NVARCHAR(50),
	@BankAccount INT,
	@TypeAccount INT,
	@NameAccount NVARCHAR(MAX)
)
RETURNS NVARCHAR(2000)
AS
BEGIN
	-- REVISION PARA CUENTAS BI CON FORMATO ADECUADO
	--DECLARE @NumAccount NVARCHAR(50) = '3859339136';
	--DECLARE @BankAccount INT = 5;
	--DECLARE @TypeAccount INT = 1; -- 1 = MONETARIA
	--DECLARE @NameAccount NVARCHAR(100) = 'ALVARO';
	DECLARE @FlagIsExcluded BIT = 'FALSE';
	DECLARE @ReasonExcluded NVARCHAR(2000) = NULL;

	SET @NumAccount = RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(RTRIM(LTRIM(@NumAccount)), CHAR(1), ''), CHAR(2), ''), CHAR(3), ''), CHAR(9), ''), CHAR(10), ''), CHAR(13), '')));
	SET @NameAccount = RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(RTRIM(LTRIM(@NameAccount)), CHAR(1), ''), CHAR(2), ''), CHAR(3), ''), CHAR(9), ''), CHAR(10), ''), CHAR(13), '')));

	IF (@NumAccount IS NULL)
	BEGIN
		SET @FlagIsExcluded = 'TRUE';
		SET @ReasonExcluded = 'EL NUMERO DE CUENTA ES NULO.';
	END
	ELSE IF (CHARINDEX('-', @NumAccount) > 0)
	BEGIN
		SET @FlagIsExcluded = 'TRUE';
		SET @ReasonExcluded = 'EL NUMERO DE CUENTA TIENE GUIONES.';
	END
	ELSE IF (CHARINDEX(' ', @NumAccount) > 0)
	BEGIN
		SET @FlagIsExcluded = 'TRUE';
		SET @ReasonExcluded = 'EL NUMERO DE CUENTA TIENE ESPACIOS EN BLANCO INTERMEDIOS.';
	END
	ELSE IF (ISNUMERIC(@NumAccount) <> 1)
	BEGIN
		SET @FlagIsExcluded = 'TRUE';
		SET @ReasonExcluded = 'EL NUMERO DE CUENTA TIENE LETRAS.';
	END
	ELSE IF (@BankAccount IS NULL)
	BEGIN
		SET @FlagIsExcluded = 'TRUE';
		SET @ReasonExcluded = 'EL NUMERO DE CUENTA NO ESTA ASIGNADO A UN BANCO.';
	END
	ELSE IF (@BankAccount < 1)
	BEGIN
		SET @FlagIsExcluded = 'TRUE';
		SET @ReasonExcluded = 'EL NUMERO DE CUENTA ESTA ASIGNADO A UN BANCO INCORRECTO.';
	END
	ELSE IF (@TypeAccount NOT IN (1, 2))
	BEGIN
		SET @FlagIsExcluded = 'TRUE';
		SET @ReasonExcluded = 'EL TIPO DE CUENTA NO ES MONETARIO NI DE AHORRO.';
	END
	ELSE IF (@NameAccount IS NULL)
	BEGIN
		SET @FlagIsExcluded = 'TRUE';
		SET @ReasonExcluded = 'EL NOMBRE DE LA CUENTA ES NULO.';
	END
	ELSE IF (@NameAccount = '')
	BEGIN
		SET @FlagIsExcluded = 'TRUE';
		SET @ReasonExcluded = 'EL NUMERO DE CUENTA NO TIENE NOMBRE DE CUENTA.';
	END
	ELSE IF (LEN(@NameAccount) < 6)
	BEGIN
		SET @FlagIsExcluded = 'TRUE';
		SET @ReasonExcluded = 'EL NOMBRE DE LA CUENTA NO ES VALIDO.';
	END
	ELSE
	BEGIN
		IF @BankAccount = 3 -- BANCO GYT CONTINENTAL
		BEGIN
			IF (LEN(@NumAccount) <> 11)
			BEGIN
				SET @FlagIsExcluded = 'TRUE';
				SET @ReasonExcluded = 'LA LONGITUD DEL NUMERO DE CUENTA NO ES CORRECTA.';
			END
		END
		ELSE IF @BankAccount = 5 -- BANCO DE DESARROLLO RURAL
		BEGIN
			IF (LEN(@NumAccount) NOT IN (10, 14))
			BEGIN
				SET @FlagIsExcluded = 'TRUE';
				SET @ReasonExcluded = 'LA LONGITUD DEL NUMERO DE CUENTA NO ES CORRECTA.';
			END
			ELSE IF ((LEN(@NumAccount) = 14) AND (SUBSTRING(@NumAccount, 1, 1) != '0'))
			BEGIN
				SET @FlagIsExcluded = 'TRUE';
				SET @ReasonExcluded = 'EL NUMERO DE CUENTA DEBE INICIAR CON CERO (0).';
			END
			ELSE IF ((LEN(@NumAccount) = 10) AND (@TypeAccount = 1) AND (SUBSTRING(@NumAccount, 1, 1) != '3'))
			BEGIN
				SET @FlagIsExcluded = 'TRUE';
				SET @ReasonExcluded = 'EL NUMERO DE CUENTA DEBE INICIAR CON TRES (3).';
			END
			ELSE IF ((LEN(@NumAccount) = 10) AND (@TypeAccount = 2) AND (SUBSTRING(@NumAccount, 1, 1) != '4'))
			BEGIN
				SET @FlagIsExcluded = 'TRUE';
				SET @ReasonExcluded = 'EL NUMERO DE CUENTA DEBE INICIAR CON CUATRO (4).';
			END
		END
		ELSE IF @BankAccount = 31 -- BANCO DE AMERICA CENTRAL
		BEGIN
			IF (((@TypeAccount = 1) AND (LEN(@NumAccount) NOT IN (9, 11))) OR
				((@TypeAccount = 2) AND (LEN(@NumAccount) NOT IN (9, 10, 11))))
			BEGIN
				SET @FlagIsExcluded = 'TRUE';
				SET @ReasonExcluded = 'LA LONGITUD DEL NUMERO DE CUENTA NO ES CORRECTA.';
			END
			ELSE IF ((@TypeAccount = 2) AND (LEN(@NumAccount) = 9) AND (SUBSTRING(@NumAccount, 1, 2) != '96'))
			BEGIN
				SET @FlagIsExcluded = 'TRUE';
				SET @ReasonExcluded = 'EL NUMERO DE CUENTA DEBE INICIAR CON NOVENTA Y SEIS (96).';
			END
			ELSE IF ((@TypeAccount = 2) AND (LEN(@NumAccount) = 10) AND (SUBSTRING(@NumAccount, 1, 1) != '1'))
			BEGIN
				SET @FlagIsExcluded = 'TRUE';
				SET @ReasonExcluded = 'EL NUMERO DE CUENTA DEBE INICIAR CON UNO (1).';
			END
		END
		ELSE IF @BankAccount = 33 -- BANCO INDUSTRIAL
		BEGIN
			IF (((@TypeAccount = 1) AND (LEN(@NumAccount) <> 10)) OR 
				((@TypeAccount = 2) AND (LEN(@NumAccount) <> 7)))
			BEGIN
				SET @FlagIsExcluded = 'TRUE';
				SET @ReasonExcluded = 'LA LONGITUD DEL NUMERO DE CUENTA NO ES CORRECTA.';
			END
		END
		ELSE IF @BankAccount = 102 -- BANCO DE GUATEMALA
		BEGIN
			IF (LEN(@NumAccount) > 7)
			BEGIN
				SET @FlagIsExcluded = 'TRUE';
				SET @ReasonExcluded = 'LA LONGITUD DEL NUMERO DE CUENTA NO ES CORRECTA.';
			END
		END
		ELSE IF @BankAccount = 100 -- BANCO DEL CREDITO HIPOTECARIO NACIONAL
		BEGIN
			IF (LEN(@NumAccount) <> 12)
			BEGIN
				SET @FlagIsExcluded = 'TRUE';
				SET @ReasonExcluded = 'LA LONGITUD DEL NUMERO DE CUENTA NO ES CORRECTA.';
			END
			ELSE IF ((@TypeAccount = 1) AND (SUBSTRING(@NumAccount, 1, 2) NOT IN ('01', '02', '03')))
			BEGIN
				SET @FlagIsExcluded = 'TRUE';
				SET @ReasonExcluded = 'EL NUMERO DE CUENTA DEBE INICIAR CON CERO Y UNO (01), CERO Y DOS (02) O CERO Y TRES (03).';
			END
			ELSE IF ((@TypeAccount = 2) AND (SUBSTRING(@NumAccount, 1, 2) NOT IN ('10', '11', '20')))
			BEGIN
				SET @FlagIsExcluded = 'TRUE';
				SET @ReasonExcluded = 'EL NUMERO DE CUENTA DEBE INICIAR CON DIEZ (10), ONCE (1) O VEINTE (20).';
			END
		END
		ELSE IF @BankAccount = 2 -- BANCO DE LOS TRABAJADORES
		BEGIN
			IF (((@TypeAccount = 1) AND (LEN(@NumAccount) NOT IN (8, 9, 10))) OR
				((@TypeAccount = 2) AND (LEN(@NumAccount) NOT IN (4, 5, 6, 7, 8, 9, 10))))
			BEGIN
				SET @FlagIsExcluded = 'TRUE';
				SET @ReasonExcluded = 'LA LONGITUD DEL NUMERO DE CUENTA NO ES CORRECTA.';
			END
			ELSE IF ((@TypeAccount = 1) AND (SUBSTRING(@NumAccount, 1, 1) IN ('0', '4')))
			BEGIN
				SET @FlagIsExcluded = 'TRUE';
				SET @ReasonExcluded = 'EL NUMERO DE CUENTA DEBE INICIAR CON CERO (0) O CUATRO (4).';
			END
			ELSE IF ((@TypeAccount = 2) AND (SUBSTRING(@NumAccount, 1, 1) = '0'))
			BEGIN
				SET @FlagIsExcluded = 'TRUE';
				SET @ReasonExcluded = 'EL NUMERO DE CUENTA DEBE INICIAR CON CERO (0).';
			END
		END
		ELSE IF @BankAccount = 97 -- BANCO INMOBILIARIO
		BEGIN
			IF (LEN(@NumAccount) <> 11)
			BEGIN
				SET @FlagIsExcluded = 'TRUE';
				SET @ReasonExcluded = 'LA LONGITUD DEL NUMERO DE CUENTA NO ES CORRECTA.';
			END
			ELSE IF ((@TypeAccount = 1) AND (SUBSTRING(@NumAccount, 1, 2) NOT IN ('17', '18', '19', '20')))
			BEGIN
				SET @FlagIsExcluded = 'TRUE';
				SET @ReasonExcluded = 'EL NUMERO DE CUENTA DEBE INICIAR CON DIEZ Y SIETE (17), DIEZ Y OCHO (18), DIEZ Y NUEVE (19) O VEINTE (20).';
			END
			ELSE IF ((@TypeAccount = 2) AND (SUBSTRING(@NumAccount, 1, 2) NOT IN ('10', '11', '12', '13', '14')))
			BEGIN
				SET @FlagIsExcluded = 'TRUE';
				SET @ReasonExcluded = 'EL NUMERO DE CUENTA DEBE INICIAR CON DIEZ (10), ONCE (11), DOCE (12), TRECE (13) O CATORCE (14).';
			END
		END
		ELSE IF @BankAccount = 4 -- BANCO INTERNACIONAL
		BEGIN
			IF (LEN(@NumAccount) <> 10)
			BEGIN
				SET @FlagIsExcluded = 'TRUE';
				SET @ReasonExcluded = 'LA LONGITUD DEL NUMERO DE CUENTA NO ES CORRECTA.';
			END
		END
		ELSE IF @BankAccount = 1 -- BANCO AGROMERCANTIL DE GUATEMALA
		BEGIN
			IF (LEN(@NumAccount) <> 10)
			BEGIN
				SET @FlagIsExcluded = 'TRUE';
				SET @ReasonExcluded = 'LA LONGITUD DEL NUMERO DE CUENTA NO ES CORRECTA.';
			END
		END
		ELSE IF @BankAccount = 32 -- BANCO AZTECA
		BEGIN
			IF (LEN(@NumAccount) <> 14)
			BEGIN
				SET @FlagIsExcluded = 'TRUE';
				SET @ReasonExcluded = 'LA LONGITUD DEL NUMERO DE CUENTA NO ES CORRECTA.';
			END
			ELSE IF (@TypeAccount <> 1)
			BEGIN
				SET @FlagIsExcluded = 'TRUE';
				SET @ReasonExcluded = 'EL TIPO DE CUENTA NO ES CORRECTO, ESTE SOLO PUEDE SER MONETARIO.';
			END
			ELSE IF (SUBSTRING(@NumAccount, 6, 1) != '1')
			BEGIN
				SET @FlagIsExcluded = 'TRUE';
				SET @ReasonExcluded = 'EL NUMERO DE CUENTA DEBE INICIAR CON UNO (1).';
			END
		END
		ELSE IF @BankAccount = 96 -- CITIBANK NA GUATEMALA
		BEGIN
			IF (LEN(@NumAccount) <> 10)
			BEGIN
				SET @FlagIsExcluded = 'TRUE';
				SET @ReasonExcluded = 'LA LONGITUD DEL NUMERO DE CUENTA NO ES CORRECTA.';
			END
			ELSE IF (@TypeAccount <> 1)
			BEGIN
				SET @FlagIsExcluded = 'TRUE';
				SET @ReasonExcluded = 'EL TIPO DE CUENTA NO ES CORRECTO, ESTE SOLO PUEDE SER MONETARIO.';
			END
		END
		ELSE IF @BankAccount = 101 -- VIVIBANCO
		BEGIN
			IF (LEN(@NumAccount) <> 12)
			BEGIN
				SET @FlagIsExcluded = 'TRUE';
				SET @ReasonExcluded = 'LA LONGITUD DEL NUMERO DE CUENTA NO ES CORRECTA.';
			END
		END
		ELSE IF @BankAccount = 28 -- BANCO FICOHSA
		BEGIN
			IF (LEN(@NumAccount) <> 11)
			BEGIN
				SET @FlagIsExcluded = 'TRUE';
				SET @ReasonExcluded = 'LA LONGITUD DEL NUMERO DE CUENTA NO ES CORRECTA.';
			END
			ELSE IF (SUBSTRING(@NumAccount, 1, 1) != '5')
			BEGIN
				SET @FlagIsExcluded = 'TRUE';
				SET @ReasonExcluded = 'EL NUMERO DE CUENTA DEBE INICIAR CON CINCO (5).';
			END
		END
		ELSE IF @BankAccount = 93 -- BANCO PROMERICA
		BEGIN
			IF (LEN(@NumAccount) <> 14)
			BEGIN
				SET @FlagIsExcluded = 'TRUE';
				SET @ReasonExcluded = 'LA LONGITUD DEL NUMERO DE CUENTA NO ES CORRECTA.';
			END
		END
		ELSE IF @BankAccount = 103 -- BANCO DE ANTIGUA
		BEGIN
			IF (LEN(@NumAccount) <> 13)
			BEGIN
				SET @FlagIsExcluded = 'TRUE';
				SET @ReasonExcluded = 'LA LONGITUD DEL NUMERO DE CUENTA NO ES CORRECTA.';
			END
			ELSE IF (@TypeAccount <> 2)
			BEGIN
				SET @FlagIsExcluded = 'TRUE';
				SET @ReasonExcluded = 'EL TIPO DE CUENTA NO ES CORRECTO, ESTE SOLO PUEDE SER DE AHORRO.';
			END
			ELSE IF (SUBSTRING(@NumAccount, 1, 4) != '4127')
			BEGIN
				SET @FlagIsExcluded = 'TRUE';
				SET @ReasonExcluded = 'EL NUMERO DE CUENTA DEBE INICIAR CON CUATRO MIL CIENTO VEINTE Y SIETE (4127).';
			END
		END
	END

	/*SELECT CHARINDEX('-', @NumAccount) 'INDEX', 
		   LEN(@NumAccount) 'LENGTH',
		   IIF(@FlagIsExcluded = 'TRUE', 'TRUE', 'FALSE') 'EXCLUDED',
		   SUBSTRING(@NumAccount, 1, 4) 'SUBSTRING',
		   @NumAccount 'NUMACCOUNT',
		   IIF(@FlagIsExcluded = 'FALSE', NULL, @ReasonExcluded) 'REASON';

	SELECT IIF(@FlagIsExcluded = 'FALSE', 'FALSE', 'TRUE') 'EXCLUDED', 
		   IIF(@FlagIsExcluded = 'FALSE', NULL, @ReasonExcluded) 'REASON';*/

	RETURN IIF(@FlagIsExcluded = 'FALSE', NULL, @ReasonExcluded);
END
GO



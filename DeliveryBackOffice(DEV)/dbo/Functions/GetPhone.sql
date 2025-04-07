-- =============================================
-- Author:		<Brandon Pedroza>
-- Create date: <2024-11-20>
-- Description:	<Kiosko - Funcion para obtener numero de telefono o prefijo>
-- =============================================

CREATE FUNCTION [dbo].[GetPhone]
(
	@PhoneText NVARCHAR(50), 
	@IsNirphone BIT, 
	@IdCountry NVARCHAR(2)
)
RETURNS NVARCHAR(10)
AS
BEGIN
    DECLARE @Phone NVARCHAR(10);

    -- Normalizar: Eliminar caracteres no numéricos excepto '+'
    SET @PhoneText = LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@PhoneText, '+', ''), '(', ''), ')', ''), ' ', ''), '-', '')));

    -- Caso 1: obtengo nirphoe
    IF @IsNirphone = 1
    BEGIN
	IF LEN(@PhoneText) = 8 AND ISNUMERIC(@PhoneText) = 1
	BEGIN
		SET @Phone = (SELECT [Value] FROM DeliveryBackOffice.dbo.ConfigParams
					 WHERE [Name] = 'AreaCode' AND IdCountry = @IdCountry)
	END
		ELSE
		BEGIN 
		SET @Phone = LEFT(@PhoneText,3);
		END
	END
    -- Caso 2: obtengo numero de telefono
    ELSE
        SET @Phone = RIGHT(@PhoneText, 8);

    RETURN @Phone;
END;
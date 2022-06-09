
CREATE FUNCTION [dbo].[FnClearString](
    @String VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
    
    SET @String = (SELECT DeliveryBackOffice.dbo.fn_replace_special_characters(@String))
	SET @String = (SELECT @String COLLATE SQL_Latin1_General_CP1251_CS_AS)
	SET @String = RTRIM(@String)
	SET @String = LTRIM(@String)
    
    RETURN UPPER(@String)
 
END

USE [DeliveryBackOffice]
GO
/****** Object:  UserDefinedFunction [dbo].[FnClearString]    Script Date: 31/01/2022 08:23:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

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

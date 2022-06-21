/*
  Name: fnt_String_Escape   
Author: Marco Jiménez
  Date: 2021-03-17
*/

CREATE FUNCTION dbo.fnt_String_Escape(@StringToEscape nvarchar(max), @Encoding nvarchar(10))
RETURNS nvarchar(max)
BEGIN
  DECLARE @s nvarchar(max);
  SELECT @StringToEscape = REPLACE(@StringToEscape, StringToReplace, StringReplacement)
  FROM dbo.tb_StringEncoding
  WHERE EncodingType = @Encoding;
   RETURN @StringToEscape
END

GO



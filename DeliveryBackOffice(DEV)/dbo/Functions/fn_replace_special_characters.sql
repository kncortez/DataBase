
CREATE FUNCTION [dbo].[fn_replace_special_characters] (@Input NVARCHAR(MAX))
	RETURNS NVARCHAR(MAX)
BEGIN

  DECLARE @Output NVARCHAR(MAX);

  SET @Output = 
		REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
		REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
		REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
		REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
		REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
		REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
		REPLACE(REPLACE(REPLACE(
		@Input, 
		'!', ''), '"', ''), '#', ''), '$', ''), '%', ''),
		'&', 'y'), '''', ''), '*', ''), '+', ''), '/', ''),
		'<', ''), '=', ''), '>', ''), '?', ''), '@', ''),
		'[', ''), '\', ''), ']', ''), '^', ''), '_', ''),
		'`', ''), '{', ''), '|', ''), '}', ''), '~', ''),
		'¡', ''), '¿', ''), '°', ''), '¬', ''), '´', ''),
		'¨', ''), '&Quot;', ''), CHAR(255), '');
  
  RETURN @Output;

END

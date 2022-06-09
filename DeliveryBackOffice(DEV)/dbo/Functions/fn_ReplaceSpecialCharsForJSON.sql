
-- =============================================
-- Author:		<César,Sazo>
-- Create date: <2022-01-14>
-- Description:	<Función que quita caracteres especiales que alteran la estructura de un JSON>
-- =============================================


CREATE FUNCTION [dbo].[fn_ReplaceSpecialCharsForJSON] (@Input NVARCHAR(MAX))
	RETURNS NVARCHAR(MAX)
BEGIN

  DECLARE @Output NVARCHAR(MAX);

  SET @Output = 
		REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@Input,
		'~', ''), '"', ''), '#', ''),CHAR(10), ''), '\', '');
  
  RETURN @Output;

END
--Me permite separar cadenas mediante un delimitador(char), es equivalente
--a la función split de C#
CREATE FUNCTION [dbo].[splitstring] ( @stringToSplit VARCHAR(MAX), @Delimiter char(1) )
RETURNS
 @returnList TABLE ([Name] [nvarchar] (500))
AS
BEGIN

 DECLARE @name NVARCHAR(MAX)
 DECLARE @pos INT

 WHILE CHARINDEX(@Delimiter, @stringToSplit) > 0
 BEGIN
  SELECT @pos  = CHARINDEX(@Delimiter, @stringToSplit)  
  SELECT @name = SUBSTRING(@stringToSplit, 1, @pos-1)

  INSERT INTO @returnList 
  SELECT @name

  SELECT @stringToSplit = SUBSTRING(@stringToSplit, @pos+1, LEN(@stringToSplit)-@pos)
 END

 INSERT INTO @returnList
 SELECT @stringToSplit

 RETURN
END
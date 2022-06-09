/*
  Name: fnt_String_Escape   
Author: Marco Jiménez
  Date: 2021-03-17
*/

CREATE FUNCTION [dbo].[fnt_String_Escape_MK12052022](@StringToEscape nvarchar(max), @Encoding nvarchar(10))
RETURNS nvarchar(max)
BEGIN  
   RETURN @StringToEscape
END

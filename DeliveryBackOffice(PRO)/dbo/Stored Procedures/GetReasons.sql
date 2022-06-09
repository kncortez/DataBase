
create PROCEDURE [dbo].[GetReasons]
@Type AS VARCHAR(200) 
AS
BEGIN

	SELECT IdCatReason IdReason, Name FROM CatReason
	WHERE UPPER(Type) = @Type 

END



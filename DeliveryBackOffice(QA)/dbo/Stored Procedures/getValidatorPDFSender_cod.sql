CREATE PROCEDURE getValidatorPDFSender_cod
AS
BEGIN
	IF (((select cast(cast(Value as varchar(2)) as int) 
	   from ConfigParams where Name = 'DebugValidateHour_COD' and Status = 1)) = 1)
	   BEGIN
		SELECT 'TRUE' AS Result
	   END
	   ELSE
	   BEGIN
			IF ((SELECT cast(cast(convert(time(0),getDate()) as varchar(2)) as int)) 
			   = (select cast(cast(Value as varchar(2)) as int) 
			   from ConfigParams where Name = 'ValidateHour_COD' and Status = 1)) 
				BEGIN
					SELECT 'TRUE' AS Result
				END
				ELSE
				BEGIN
					SELECT 'FALSE' as Result
				END

	   END
	
END

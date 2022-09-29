-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-08-16>
-- Description:	<SP PARA ACTIVAR O DESACTIVAR HUB>
-- =============================================
CREATE PROCEDURE [dbo].[UpdateActivateHub] 
@HubName AS NVARCHAR (100),
@HubAbbrev as nvarchar(3)
AS
BEGIN
DECLARE @result INT =0;

	
   IF EXISTS(SELECT TOP 1 1 FROM [dbo].[HubLogistics] WHERE HubStatus = 1 AND HubName = @HubName AND HubAbbreviation = @HubAbbrev )
	BEGIN 
	UPDATE  [dbo].[HubLogistics] 
			SET HubStatus = 0
	   WHERE HubName = @HubName AND HubAbbreviation = @HubAbbrev
	 SET @result = 0;
	END
	ELSE
	BEGIN
	   UPDATE  [dbo].[HubLogistics] 
			SET HubStatus = 1
	   WHERE HubName = @HubName AND HubAbbreviation = @HubAbbrev
	 SET @result = 1;
	END

	SELECT @result AS Result

END
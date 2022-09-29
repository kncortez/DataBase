-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-08-16>
-- Description:	<SP PARA ACTIVAR O DESACTIVAR HUB>
-- =============================================
CREATE PROCEDURE [dbo].[ModifyHub] 
@HubName AS NVARCHAR (100),
@HubAbbrev as nvarchar(3),
@HubAbbrev2 as nvarchar(3)
AS
BEGIN
DECLARE @result INT = 0;


   IF EXISTS(SELECT TOP 1 1 FROM [dbo].[HubLogistics] WHERE    HubAbbreviation = @HubAbbrev2 )
	BEGIN
		BEGIN TRANSACTION
		BEGIN TRY
		UPDATE  [dbo].[HubLogistics] 
				SET HubName = @HubName,
					HubAbbreviation = @HubAbbrev
		   WHERE HubAbbreviation = @HubAbbrev2
		 SET @result = 1;

			COMMIT TRANSACTION
		 END TRY
			 BEGIN CATCH
				ROLLBACK TRANSACTION
			 END CATCH
	END
	ELSE
	BEGIN
	 SET @result = 0;
	END

	SELECT @result AS Result

END
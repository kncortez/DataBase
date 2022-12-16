-- =============================================
-- Author:		<Edelman>
-- Create date: <2022-12-13>
-- Description:	<SP agrega un nuevo hub de destino a una rta linehauls>
-- =============================================
CREATE PROCEDURE [dbo].[SPHD_UpdateCoverageRouteLinehauls]
@CatRouteId AS INT,
@HubOriginId AS INT,
@HubAbbreviation AS NVARCHAR(5),
@ReportEmail AS NVARCHAR(100)='',
@Token AS NVARCHAR(50)

AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @HubDestinyId AS INT = (SELECT IdHubLogistic FROM [dbo].[HubLogistics] WHERE HubAbbreviation = @HubAbbreviation)

	BEGIN TRANSACTION 
	BEGIN TRY
	
	   IF (NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[CatLinehaul] 
	                                 WHERE IdRoute= @CatRouteId  AND 
									       IdHubOrigin=@HubOriginId AND 
										   IdHubDestination=@HubDestinyId AND 
										   RowStatus =1))
        BEGIN


			 INSERT INTO [dbo].[CatLinehaul] VALUES (@CatRouteId ,@HubOriginId,@HubDestinyId,@ReportEmail,1,@Token ,GETDATE(),NULL,NULL)
			 SELECT Result=1
		END
			ELSE
				BEGIN
					SELECT Result=2
				END

		COMMIT TRANSACTION
       
   END TRY
   BEGIN CATCH
	ROLLBACK TRANSACTION
	SELECT Result=0, ERROR_MESSAGE() AS [ErrorMessage];
   END CATCH
END
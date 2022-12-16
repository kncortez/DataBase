-- =============================================
-- Author:		<Edelman>
-- Create date: <2022-12-13>
-- Description:	<SP agrega un nuevo hub de destino a una rta linehauls>
-- =============================================
CREATE PROCEDURE [dbo].[SPHD_DisableCoverageRouteLinehauls]
@CatRouteId AS INT,
@HubOriginId AS INT,
@HubAbbreviation AS NVARCHAR(5),
@Token AS NVARCHAR(50)

AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @HubDestinyId AS INT = (SELECT IdHubLogistic FROM [dbo].[HubLogistics] WHERE HubAbbreviation = @HubAbbreviation)

	BEGIN TRANSACTION 
	BEGIN TRY
	
	   IF (EXISTS(SELECT TOP 1 1 FROM [dbo].[CatLinehaul] 
	                                 WHERE IdRoute   = @CatRouteId  AND 
									       IdHubOrigin  = @HubOriginId AND 
										   IdHubDestination = @HubDestinyId ))
        BEGIN


			 UPDATE [dbo].[CatLinehaul] 
			        SET RowStatus    = 0,
					    TokenUpdated = @Token,	
						DateUpdated  = GETDATE()
			 WHERE IdHubOrigin  = @HubOriginId    AND 
			      IdHubDestination = @HubDestinyId   AND 
				   IdRoute  = @CatRouteId

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
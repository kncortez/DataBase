-- =============================================
-- Author:		<Edelman>
-- Create date: <2022-12-13>
-- Description:	<SP para agregar nueva ruta a covertura linehauls>
-- =============================================
CREATE PROCEDURE [dbo].[NewRouteCoverageLinehauls]
@HubOriginId AS INT,
@HubDestinyId AS INT,
@ReportEmail AS NVARCHAR(100),
@Token AS NVARCHAR(50),

@CodeRoute AS NVARCHAR(20),
@DescriptionRoute AS NVARCHAR(100),
@Township AS INT


AS
BEGIN

	SET NOCOUNT ON;
	DECLARE @IdRoutePreparation  INT
	BEGIN TRANSACTION 
	BEGIN TRY
	
		IF (NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[CatRoute] WHERE CodeRoute = @CodeRoute AND RowStatus=1))
		BEGIN
		/* Agregar nueva Ruta linehauls */
		INSERT INTO dbo.CatRoute VALUES (@CodeRoute,@DescriptionRoute,@Township,2,NULL,1,@Token,GETDATE(),NULL,NULL)
		SET @IdRoutePreparation = SCOPE_IDENTITY()

		/* Asociar nueva ruta linehauls con hub y estación   */
		     
				INSERT INTO [dbo].[CatLinehaul] 
				VALUES (@IdRoutePreparation ,@HubOriginId,@HubDestinyId,@ReportEmail,1,@Token,GETDATE(),NULL,NULL)
             
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
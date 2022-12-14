-- =============================================
-- Author:		<Edelman>
-- Create date: <2022-12-13>
-- Description:	<SP para agregar nueva ruta a covertura linehauls>
-- =============================================
CREATE PROCEDURE [dbo].[NewRouteCoverageLinehauls]
@CatRouteId AS INT,
@HubOriginId AS INT,
@HubDestinyId AS INT,
@ReportEmail AS NVARCHAR(100),
@Token AS NVARCHAR(50)

AS
BEGIN

	SET NOCOUNT ON;

	BEGIN TRANSACTION 
	BEGIN TRY
	
		INSERT INTO dbo.LinehaulCoverage VALUES (1749,55,4,'',1,'SYS-CVALDES',GETDATE(),NULL,NULL)
        
		COMMIT TRANSACTION
        SELECT Result=1

   END TRY
   BEGIN CATCH
	ROLLBACK TRANSACTION
	SELECT Result=0
   END CATCH
END
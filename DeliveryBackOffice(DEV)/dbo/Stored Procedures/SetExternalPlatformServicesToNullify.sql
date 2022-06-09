-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-02-16>
-- Description:	<Desactiva un listado de guías del proceso de simpliroute>
-- =============================================
CREATE PROCEDURE [dbo].[SetExternalPlatformServicesToNullify]
	-- Add the parameters for the stored procedure here
	@Guides TblGuides READONLY,
	@Token NVARCHAR(50) = 'SYS-HERMESROUTES'
AS
BEGIN
	DECLARE @RModified INT

	BEGIN TRANSACTION

	BEGIN TRY
		UPDATE epsrwg
			SET epsrwg.RowStatus = 0
			,epsrwg.TokenUpdated = @Token
			,epsrwg.DateUpdated = GETDATE()
		FROM ExtPlatServiceRelationshipWithGuide epsrwg
		JOIN @Guides g
			ON g.Guide_Serie = epsrwg.GuideSerie
			AND g.Guide_Number = epsrwg.GuideNumber
			AND CAST(epsrwg.DateCreated AS DATE) = CAST(GETDATE() AS DATE)

		SET @RModified = ISNULL(@@ROWCOUNT,0)

		UPDATE eps
			SET eps.RowStatus = 0
			,eps.TokenUpdated = @Token
			,eps.DateUpdated = GETDATE()
		FROM ExtPlatformService eps
		JOIN ExtPlatServiceRelationshipWithGuide epsrwg
			ON epsrwg.ExtPlatServiceId = eps.IdExtPlatformService
		JOIN @Guides g
			ON g.Guide_Serie = epsrwg.GuideSerie
			AND g.Guide_Number = epsrwg.GuideNumber
			AND CAST(epsrwg.DateCreated AS DATE) = CAST(GETDATE() AS DATE)

		SET @RModified = @RModified+ISNULL(@@ROWCOUNT,0)
	END TRY
	BEGIN CATCH
	SELECT 
			0 AS 'StatusCode', 
			ERROR_MESSAGE() AS 'Description', 
			CONVERT(BIGINT, 0) AS 'NumTransferID'
		ROLLBACK TRANSACTION
	END CATCH;

	IF @@TRANCOUNT > 0
	BEGIN
		IF (@RModified > 0)
			SELECT			  
				1 AS 'StatusCode',
				'Registros actualizados correctamente' AS 'Description', 
				@@TRANCOUNT AS 'NumTransferID'
		ELSE
			SELECT			  
				0 AS 'StatusCode',
				'Registros no actualizados' AS 'Description', 
				0 AS 'NumTransferID'

		COMMIT TRANSACTION;			
	END
	ELSE
		SELECT 
			0 AS 'StatusCode', 
			ERROR_MESSAGE() AS 'Description', 
			CONVERT(BIGINT, 0) AS 'NumTransferID'
END

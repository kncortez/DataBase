

-- =============================================
-- Author:		<Michael Espinoza>
-- Create date: <2022-04-05>
-- Description:	< Actualiza el registro de un manifiesto creado y asigna el url del documento creado en API>
-- =============================================

CREATE PROCEDURE [dbo].[SetCorporateManifestUrl]
  @IdManifest BIGINT,
  @Token NVARCHAR(50),
  @ManifestURL VARCHAR(MAX)
	
AS

BEGIN

BEGIN TRANSACTION

BEGIN TRY
	
	UPDATE cm
	SET cm.ManifestURL = @ManifestURL,
	cm.TokenUpdated = @Token,
	cm.DateUpdated = GETDATE()
  FROM [dbo].[CorporateManifest] cm
	WHERE cm.IdManifest = @IdManifest AND cm.RowStatus=1
	
END TRY

BEGIN CATCH

ROLLBACK TRANSACTION;

SELECT 0 AS 'State',ERROR_MESSAGE() AS 'Error'

END CATCH

IF @@TRANCOUNT > 0

BEGIN

COMMIT TRANSACTION;
								
SELECT 1 AS 'State'
				
END

END;

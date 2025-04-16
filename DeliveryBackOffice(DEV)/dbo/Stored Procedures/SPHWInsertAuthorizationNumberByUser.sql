-- =============================================
-- Author:		<Brandon Pedroza>
-- Create date: <2025-15-04>
-- Description:	<ZIGI - Guarda el numero de autorizacion de pago brindado por el usuario>
-- =============================================
CREATE PROCEDURE [dbo].[SPHWInsertAuthorizationNumberByUser]
	@GuideNumber INT,
	@GuideSerie NVARCHAR(50),
	@Reference NVARCHAR(100),
	@AuthorizationNumberByUser NVARCHAR(100)
AS
BEGIN
	BEGIN TRY
		UPDATE PaymentZigi
		SET 
			AuthorizationNumberByUser = @AuthorizationNumberByUser,
			DateUpdated = GETDATE(),
			TokenUpdated = 'SPHWInsertAuthorizationNumberByUser'
		WHERE GuideNumber = @GuideNumber
			AND GuideSerie = @GuideSerie
			AND ZigiReference = @Reference;

	IF @@ROWCOUNT > 0
	BEGIN
		SELECT 200 AS [IdResult],
		'Numero de autorizacion guardado' AS [Message]
	END
	ELSE
	BEGIN
		SELECT 400 AS [IdResult],
		'No se actualizo registro' AS [Message]
	END


	END TRY
	BEGIN CATCH
		SELECT 500 AS [IdResult],
		ERROR_MESSAGE() AS [Message]
	END CATCH
END;

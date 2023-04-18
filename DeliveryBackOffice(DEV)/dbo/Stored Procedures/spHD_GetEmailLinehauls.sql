-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2023-03-29>
-- Description:	<Obtiene los correos configurados para recibir notificaciones de actas Linehauls>
-- =============================================
CREATE PROCEDURE [dbo].[spHD_GetEmailLinehauls]
	@CatRouteId INT
AS
BEGIN
	BEGIN TRY

		DECLARE @tblEmail AS TABLE(Emails VARCHAR(MAX))

		DECLARE @Emails VARCHAR(MAX)

		SET @Emails = (SELECT
				STUFF((SELECT
						', ' + ReportEmails
					FROM LinehaulCoverage WITH (NOLOCK)
					WHERE CatRouteId = @CatRouteId
					FOR XML PATH (''))
				, 1, 2, ''))

		IF @Emails IS NOT NULL
		BEGIN

			INSERT INTO @tblEmail
			SELECT DISTINCT
				RTRIM(LTRIM(Item))
			FROM dbo.SplitUnlimited(@Emails, ',')

			SET @Emails = (SELECT
					STUFF((SELECT
							'; ' + Emails
						FROM @tblEmail
						FOR XML PATH (''))
					, 1, 2, ''))

			DELETE FROM @tblEmail

			INSERT INTO @tblEmail
			SELECT DISTINCT
				RTRIM(LTRIM(Item))
			FROM dbo.SplitUnlimited(@Emails, ';')

			SET @Emails = (SELECT
					STUFF((SELECT
							'/ ' + Emails
						FROM @tblEmail
						FOR XML PATH (''))
					, 1, 2, ''))

			DELETE FROM @tblEmail

			INSERT INTO @tblEmail
			SELECT DISTINCT
				RTRIM(LTRIM(Item))
			FROM dbo.SplitUnlimited(@Emails, '/')


			SELECT
				1 'StatusCode'
			   ,'Datos obtenidos correctamente.' 'Description'
			   ,STUFF((SELECT
						', ' + Emails
					FROM @tblEmail
					FOR XML PATH (''))
				, 1, 2, '') 'Email'
		END
		ELSE
		BEGIN
			SELECT
				-1 'StatusCode'
			   ,'No se encontraron registros.' 'Description'
			   ,'' 'Email'
		END
	END TRY
	BEGIN CATCH
		SELECT
			-1 'StatusCode'
		   ,ERROR_MESSAGE() 'Description'
		   ,'' 'Email'
	END CATCH
END
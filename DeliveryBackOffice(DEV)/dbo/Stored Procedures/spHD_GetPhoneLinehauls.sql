
-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2023-03-31>
-- Description:	<Obtiene los número sde teléfonos configurados para recibir notificaciones de actas Linehauls>
-- =============================================
CREATE PROCEDURE [dbo].[spHD_GetPhoneLinehauls]
	@CatRouteId INT
AS
BEGIN
	BEGIN TRY

		DECLARE @tblPhone AS TABLE(Phones VARCHAR(MAX))

		DECLARE @Phones VARCHAR(MAX)

		SET @Phones = (SELECT
				STUFF((SELECT
						', ' + ReportPhones
					FROM LinehaulCoverage WITH (NOLOCK)
					WHERE CatRouteId = @CatRouteId
					FOR XML PATH (''))
				, 1, 2, ''))

		IF @Phones IS NOT NULL
		BEGIN

			INSERT INTO @tblPhone
			SELECT DISTINCT
				REPLACE(REPLACE(RTRIM(LTRIM(Item)), ' ', ''), '-', '')
			FROM dbo.SplitUnlimited(@Phones, ',')

			SET @Phones = (SELECT
					STUFF((SELECT
							'; ' + Phones
						FROM @tblPhone
						FOR XML PATH (''))
					, 1, 2, ''))

			DELETE FROM @tblPhone

			INSERT INTO @tblPhone
			SELECT DISTINCT
				RTRIM(LTRIM(Item))
			FROM dbo.SplitUnlimited(@Phones, ';')

			SET @Phones = (SELECT
					STUFF((SELECT
							'/ ' + Phones
						FROM @tblPhone
						FOR XML PATH (''))
					, 1, 2, ''))

			DELETE FROM @tblPhone

			INSERT INTO @tblPhone
			SELECT DISTINCT
				RTRIM(LTRIM(Item))
			FROM dbo.SplitUnlimited(@Phones, '/')


			SELECT
				1 'StatusCode'
			   ,'Datos obtenidos correctamente.' 'Description'
			   ,STUFF((SELECT
						', ' + Phones
					FROM @tblPhone
					FOR XML PATH (''))
				, 1, 2, '') 'Phone'
		END
		ELSE
		BEGIN
			SELECT
				-1 'StatusCode'
			   ,'No se encontraron registros.' 'Description'
			   ,'' 'Phone'
		END
	END TRY
	BEGIN CATCH
		SELECT
			-1 'StatusCode'
		   ,ERROR_MESSAGE() 'Description'
		   ,'' 'Phone'
	END CATCH
END
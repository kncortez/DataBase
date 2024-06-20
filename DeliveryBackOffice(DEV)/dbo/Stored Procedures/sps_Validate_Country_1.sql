-- =============================================
-- Author:		<CRISTIAN SUAZO>
-- Create date: <2024-05-243>
-- Description:	<Valida que el pais origen sea el mismo al logueado>
-- =============================================
CREATE PROCEDURE [dbo].[sps_Validate_Country] 
		@GuideSerie NVARCHAR(2) = 'FD',
		@GuideNumber INT,
		@CountryId NVARCHAR(3) = 'GT'
AS
BEGIN
	BEGIN TRY

	SELECT  CASE WHEN IIF(SenderCountryId IS NULL, 'GT', SenderCountryId) = @CountryId 
				 THEN 1 ELSE 0 END AS 'StatusCode',
			CASE WHEN  IIF(SenderCountryId IS NULL, 'GT', SenderCountryId) = @CountryId 
				 THEN 'El pais Origen es correcto' 
				 ELSE 'El pais Origen no es igual al logueado' 
			END AS 'Description'
	FROM DeliveryOrder 
	WHERE Guide_Serie = @GuideSerie
			AND Guide_Number = @GuideNumber

	END TRY
	BEGIN CATCH
			SELECT
				0 AS 'StatusCode',
				ERROR_MESSAGE() AS 'Description'
	END CATCH
END
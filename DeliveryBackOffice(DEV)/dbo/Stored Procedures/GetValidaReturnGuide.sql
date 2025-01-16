-- =============================================
-- Author:		<Cristian Suazo>
-- Update date: <2025-01-16>
-- Description:	<Valida si la guia tiene activo el IsLastMileReturn>
-- =============================================
CREATE PROCEDURE GetValidaReturnGuide
				@GuideSerie NVARCHAR(2),
				@GuideNumber INT
AS
BEGIN
	BEGIN TRY
		DECLARE @Valid INT

		SELECT @Valid = IsLastMileReturn 
		FROM DeliveryOrder WITH(NOLOCK)
		WHERE Guide_Serie = @GuideSerie 
		AND Guide_Number = @GuideNumber

		IF @Valid = 1
		BEGIN
			SELECT 1 AS  StatusCode,
				   'La guÍa va para devolucion persona que recibe no obligatorio' AS Description
		END
		ELSE
		BEGIN
			SELECT 2 AS StatusCode,
				'La guÍas no es devolucion, perona que recibe obligatoria' AS Description
		END

	END TRY
	BEGIN CATCH
		SELECT 0 AS StatusCode,
			   ERROR_MESSAGE() AS ErrorMessage,
			   ERROR_LINE() AS ErrorLine
	END CATCH
END
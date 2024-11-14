-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2024-11-13>
-- Description:	<Delivery Tracking - Método para consultar si una guía cuenta con una calificación de servicio en tracking.>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_GetQueryQualifyService] 
@GuideSerie NVARCHAR(4),
@GuideNumber INT
AS
BEGIN
BEGIN TRY

	 -- Validar si la guía ya cuenta con calificación
	IF EXISTS(SELECT 1 FROM DeliveryBackOffice.dbo.ScoreServiceGuide WITH(NOLOCK)
				WHERE GuideSerie = @GuideSerie AND GuideNumber = @GuideNumber)
	BEGIN
		SELECT 400 as [IdResult]
		, 'La guía ya cuenta con una calificación.' AS [Message]
		, CAST(Score AS INT)  AS [Score]
		, ISNULL(Comment, '') AS [Comment]
		FROM DeliveryBackOffice.dbo.ScoreServiceGuide WITH(NOLOCK)
		WHERE GuideSerie = @GuideSerie AND GuideNumber = @GuideNumber
	END;
	ELSE
	BEGIN
		SELECT 200 as [IdResult]
		, 'La guía no cuenta con una calificación.' AS [Message];
	END;

END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
END;
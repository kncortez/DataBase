/* =================================================
   SP:        [dbo].[ValidateGuideIncidentToday]
   Propósito: Valida una única incidencia por guía, por día.
   Autor:     Keila Cortéz
   Historia:  FDAPI-6341
   Fecha:     2026-05-21
   === CHANGELOG ================================
   2026-05-21 | Historia/épica: FDAPI-6341 | Autor: Keila Cortéz 
   ============================================
*/
CREATE PROCEDURE [dbo].[ValidateGuideIncidentToday]
    @GuideSerie NVARCHAR(2),
    @GuideNumber INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentIncidentCount INT = 0;
    DECLARE @StartDate DATETIME = CAST(GETDATE() AS DATE);
    DECLARE @EndDate DATETIME = DATEADD(DAY, 1, @StartDate);

    SELECT @CurrentIncidentCount = COUNT(DA.ID)
    FROM [DeliveryBackOffice].[dbo].[DeliveryAttempt] DA WITH (NOLOCK)
        INNER JOIN [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence] COI WITH (NOLOCK)
            ON DA.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence
    WHERE DA.Guide_Serie = @GuideSerie
      AND DA.Guide_Number = @GuideNumber
      AND DA.Date_Created >= @StartDate
      AND DA.Date_Created < @EndDate
      AND COI.RowStatus = 1;

    IF (ISNULL(@CurrentIncidentCount, 0) > 0)
    BEGIN
        SELECT 
            0 AS StatusCode,
            1 AS HasIncidentToday,
            @CurrentIncidentCount AS IncidentCount;
    END
    ELSE
    BEGIN
        SELECT 
            1 AS StatusCode,
            0 AS HasIncidentToday,
            @CurrentIncidentCount AS IncidentCount;
    END
END;
GO
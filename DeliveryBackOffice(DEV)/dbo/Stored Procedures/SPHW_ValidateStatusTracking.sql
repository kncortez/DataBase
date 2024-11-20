-- =============================================
-- Author:		<Aylinne Recinos>
-- Create date: <2024-11-18>
-- Description:	<Delivery Tracking - Método para validar el estado de la orden para reimpresión>
-- =============================================

CREATE PROCEDURE [dbo].[SPHW_ValidateStatusTracking]
    @GuideSerie NVARCHAR(2),
    @GuideNumber INT
AS
BEGIN
    DECLARE @GuideStatusReprint BIT =
            (
                SELECT rot.IsPendingReprint
                FROM ReprintOrderTracking rot WITH (NOLOCK)
                WHERE rot.GuideSerie = @GuideSerie
                      AND rot.GuideNumber = @GuideNumber
            );
    IF @GuideStatusReprint = 1
        SELECT 2 StatusCode,
               'La guía necesita reimpresión.' Description;
    ELSE
        SELECT 0 StatusCode,
               'La guía se encuentra lista para asignarse' Description;
END
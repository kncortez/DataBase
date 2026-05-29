-- =============================================
-- Author:		<Bilkar Morataya>
-- Create date: <2026-01-07>
-- Description:	<Obtener información de PaymentZigi por serie y número de guía, incluyendo Búsqueda en grupos relacionados>
-- =============================================
CREATE PROCEDURE [dbo].[SPHWGetPaymentZigiByGuide]
(
    @GuideNumber INT,
    @GuideSerie NVARCHAR(50),
    @Token NVARCHAR(200) = 'SYS-SPHWGetPaymentZigiByGuide'
)
AS
BEGIN
    SET NOCOUNT ON;

    -- =============================================
    -- Búsqueda directa por serie y número de guía
    -- =============================================
    SELECT 
        PZ.ZigiPaymentId,
        PZ.GuideNumber,
        PZ.GuideSerie,
        PZ.ZigiLinkStatus,
        PZ.ZigiLink,
        PZ.ZigiTransactionId,
        PZ.ZigiReference,
        PZ.ZigiPaymentLinkId,
        PZ.PaymentId,
        PZ.RowStatus,
        PZ.DateCreated,
        PZ.IsGroup,
        PZ.GeneratedMethod
    FROM PaymentZigi PZ WITH(NOLOCK)
    WHERE PZ.RowStatus = 1
    AND PZ.GuideSerie = @GuideSerie 
    AND PZ.GuideNumber = @GuideNumber

    UNION

    -- =============================================
    -- Búsqueda por grupo: registros relacionados via PaymentZigiMulti
    -- =============================================
    SELECT 
        PZ.ZigiPaymentId,
        PZ.GuideNumber,
        PZ.GuideSerie,
        PZ.ZigiLinkStatus,
        PZ.ZigiLink,
        PZ.ZigiTransactionId,
        PZ.ZigiReference,
        PZ.ZigiPaymentLinkId,
        PZ.PaymentId,
        PZ.RowStatus,
        PZ.DateCreated,
        PZ.IsGroup,
        PZ.GeneratedMethod
    FROM PaymentZigi PZ WITH(NOLOCK)
    INNER JOIN PaymentZigiMulti PZM WITH(NOLOCK)
        ON PZ.ZigiPaymentId = PZM.Id_PaymentZigi
    WHERE PZ.RowStatus = 1
    AND PZM.RowStatus = 1
    AND PZM.GuideSerie = @GuideSerie
    AND PZM.GuideNumber = @GuideNumber
    
    ORDER BY DateCreated DESC;

END;
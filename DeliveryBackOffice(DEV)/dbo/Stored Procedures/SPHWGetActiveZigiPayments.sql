-- =============================================
-- Author:		Bilkar Morataya
-- Create date: 2025-11-14
-- Description:	Validador de estatus de pagos Zigi activos (Uniguías y multiguías, usado en EXC)
-- =============================================
CREATE PROCEDURE [dbo].[SPHWGetActiveZigiPayments]
(
    @GuideNumber INT,
    @GuideSerie NVARCHAR(10)
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Primera consulta: buscar por GuideNumber y GuideSerie exactos
    SELECT
        ZigiPaymentId,
        GuideNumber,
        GuideSerie,
        ZigiReference
    FROM PaymentZigi
    WHERE GuideSerie = @GuideSerie
        AND GuideNumber = @GuideNumber
        AND ZigiLinkStatus NOT IN ('PAID', 'CANCELLED')
        AND RowStatus != 0

    UNION

    -- Segunda consulta: buscar grupos MFD (Multiguía) donde ZigiPaymentId = GuideNumber
    SELECT
        ZigiPaymentId,
        GuideNumber,
        GuideSerie,
        ZigiReference
    FROM PaymentZigi
    WHERE ZigiPaymentId = @GuideNumber
        AND ZigiLinkStatus NOT IN ('PAID', 'CANCELLED')
        AND IsGroup = 1
        AND RowStatus != 0;
END
-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2026-05-14>
-- Description:	<Paggo. - Obtiene el estado del link de pago (ZigiLinkStatus)
--               filtrando por serie y número de guía>
-- =============================================
CREATE PROCEDURE [dbo].[SPHWGetLinkStatusByGuide]
(
    @GuideNumber INT,
    @GuideSerie  NVARCHAR(2)
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
         PZ.GuideSerie
        ,PZ.GuideNumber
        ,PZ.ZigiLinkStatus
    FROM [DeliveryBackOffice].[dbo].[PaymentZigi] PZ WITH (NOLOCK)
    WHERE PZ.GuideSerie  = @GuideSerie
      AND PZ.GuideNumber = @GuideNumber
      AND PZ.RowStatus   = 1;
END;
GO

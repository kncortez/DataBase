-- =============================================
-- System:		<API>
-- Author:		<Bilkar Morataya>
-- Create date: <2025-11-24>
-- Description:	<Validación de estatus de link para colocarlo en cola, modifica el teléfono si es necesario,
-- se mantiene null para mandarlo al mismo teléfono configurado al crear guía>
-- =============================================
CREATE PROCEDURE [dbo].[SPHWResendZigiPaymentLink]
(
  @GuideNumber INT
 ,@GuideSerie NVARCHAR(50)
 ,@Token NVARCHAR(200) = 'SYS-SPHWResendZigiPaymentLink'
 ,@PhoneNumber NVARCHAR(20) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    -- =============================================
    -- 1. Actualizar banderas y teléfono si aplica
    -- =============================================
    UPDATE DeliveryBackOffice.dbo.PaymentZigi
    SET LinkRequestSent = 0,
        DateUpdated = GETDATE(),
        TokenUpdated = @Token
    WHERE RowStatus = 1 
      AND LinkRequestSent = 1 
      AND PaymentConfirmSent = 0 
      AND ZigiLinkStatus = 'CREATED'
      AND GuideSerie = @GuideSerie
      AND GuideNumber = @GuideNumber;

    UPDATE DeliveryBackOffice.dbo.PaymentZigi
    SET PhoneNumber = @PhoneNumber
    WHERE RowStatus = 1
      AND PaymentConfirmSent = 0
      AND ZigiLinkStatus = 'CREATED'
      AND GuideSerie = @GuideSerie
      AND GuideNumber = @GuideNumber

END;
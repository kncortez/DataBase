/* =============================================
    SP:          [dbo].[SPPG_UpdatePaggoPaymentStatus]
    Propósito:   Actualizar el estado del link de pago generado por Paggo en la tabla PaymentZigi, cambiando ZigiLinkStatus de PENDING a PAID cuando se recibe confirmación exitosa desde el webhook de Paggo.
    Autor:       Marcelo del Aguila
    Historia:    FDAPI-6254
    Fecha:       2026-05-20

    === CHANGELOG ===================================
    2026-05-20 | Historia/épica: FDAPI-6254 | Autor: Marcelo del Aguila | Creación del procedimiento para actualizar el estado de pagos Paggo recibidos por webhook.

    ============================================== */

CREATE PROCEDURE [dbo].[SPPG_UpdatePaggoPaymentStatus]
    @ZigiPaymentLinkId VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE DeliveryBackOffice.dbo.PaymentZigi
    SET ZigiLinkStatus = 'PAID',
        DateUpdated = GETDATE(),
        TokenUpdated = 'PAGGO_WEBHOOK'
    WHERE ZigiPaymentLinkId = @ZigiPaymentLinkId
      AND ZigiLink LIKE '%paggoapp.com%'
      AND ZigiLinkStatus = 'PENDING';

    SELECT @@ROWCOUNT AS RowsAffected;
END;
/* =============================================
    SP:          [dbo].[SPFP_GetCustomerAndCODCollectByGuide]
    Propósito:   Obtener la serie, número de guía, IdCustomer y montos COD/Collect asociados a una guía para validar si aplica pago con tarjeta en Forza Pay.
    Autor:       Marcelo del Aguila
    Historia:    FDAPI-6259
    Fecha:       2026-05-11

    === CHANGELOG ===================================
    2026-05-11 | Historia/épica: FDAPI-6259 | Autor: Marcelo del Aguila | Creación del procedimiento.
    2026-05-13 | Historia/épica: FDAPI-6259 | Autor: Marcelo del Aguila | Se agrega GuideSerie como parámetro, resultado y filtro.

    ============================================== */
CREATE PROCEDURE [dbo].[SPFP_GetCustomerAndCODCollectByGuide]
(
    @GuideSerie VARCHAR(50),
    @GuideNumber VARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        GuideSerie = do.Guide_Serie,
        GuideNumber = do.Guide_Number,
        do.IdCustomer,
        COD = ISNULL(do.Collect_OnDelivery, 0),
        Colect = ISNULL(do.PriceShippment, 0),
        MontoAPagar = ISNULL(do.Collect_OnDelivery, 0) + ISNULL(do.PriceShippment, 0)
    FROM dbo.DeliveryOrder do WITH (NOLOCK)
    WHERE do.Guide_Serie = @GuideSerie
      AND do.Guide_Number = @GuideNumber;
END;

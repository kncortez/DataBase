
-- =============================================
-- Author:		<Oscar, Morales>
-- Create date: <2022-01-18>
-- Description:	<Válida si el estado que se le asignará a una guía es correcto.>
-- =============================================
CREATE PROCEDURE [dbo].[GetStatusOrderValid]
    @GuideSerie NVARCHAR(2),
    @GuideNumber INT,
    @StatusOrderId TINYINT
AS
BEGIN

    --Obtener el estado de la DeliveryOrder
    DECLARE @GuideStatusOrderId TINYINT =
            (
                SELECT do.StatusOrderId
                FROM DeliveryOrder do WITH (NOLOCK)
                WHERE do.Guide_Serie = @GuideSerie
                      AND do.Guide_Number = @GuideNumber
            );

    --Estados de finalización (Entregado, Entregado en Express center)
    IF @GuideStatusOrderId = 5
       OR @GuideStatusOrderId = 22
        --Solo pueden pasar a COD Liquidado o COD PAGADO
        IF @StatusOrderId = 24
           OR @StatusOrderId = 25
            SELECT 1 StatusCode,
                   'Estado válido.' Description;
        ELSE
            SELECT 0 StatusCode,
                   'La guía se encuentra en estado Entregada.' Description;
    --COD Liquidado
    ELSE IF @GuideStatusOrderId = 24
        --Solo puede pasar a COD pagado
        IF @StatusOrderId = 25
            SELECT 1 StatusCode,
                   'Estado válido.' Description;
        ELSE
            SELECT 0 StatusCode,
                   'La guía se encuentra en estado COD Liquidado.' Description;
    --COD Pagado
    ELSE IF @GuideStatusOrderId = 25
        --Solo puede pasar a COD Liquidado
        IF @StatusOrderId = 24
            SELECT 1 StatusCode,
                   'Estado válido.' Description;
        ELSE
            SELECT 0 StatusCode,
                   'La guía se encuentra en estado COD Pagado.' Description;
    --ANULADO
    ELSE IF @GuideStatusOrderId = 7
        SELECT 0 StatusCode,
               'La guía se encuentra en estado Anulado.' Description;
    --Devuelto en Express Center
    ELSE IF @GuideStatusOrderId = 23
        SELECT 0 StatusCode,
               'La guía se encuentra en estado Devuelto en Express Center.' Description;
    --Devuelto
    ELSE IF @GuideStatusOrderId = 14
        SELECT 0 StatusCode,
               'La guía se encuentra en estado Devuelto.' Description;

    ELSE --De momento no se valida nada más
        SELECT 1 StatusCode,
               'Estado válido.' Description;

END;
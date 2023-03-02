
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

	DECLARE @StatusDelivery TINYINT = (SELECT so.StatusOrderId FROM StatusOrder so WHERE so.OrderDescription = 'Entregado')
	DECLARE @StatusDeliveryExpress TINYINT = (SELECT so.StatusOrderId FROM StatusOrder so WHERE so.OrderDescription = 'Entregado en Express center')
	DECLARE @StatusCODSettlement TINYINT = (SELECT so.StatusOrderId FROM StatusOrder so WHERE so.OrderDescription = 'COD Liquidado')
	DECLARE @StatusCODPaid TINYINT = (SELECT so.StatusOrderId FROM StatusOrder so WHERE so.OrderDescription = 'COD Pagado')
	DECLARE @StatusReturn TINYINT = (SELECT so.StatusOrderId FROM StatusOrder so WHERE so.OrderDescription = 'Devuelto')
	DECLARE @StatusReturnExpress TINYINT = (SELECT so.StatusOrderId FROM StatusOrder so WHERE so.OrderDescription = 'Devuelto en Express center')
	DECLARE @StatusCancelled TINYINT = (SELECT so.StatusOrderId FROM StatusOrder so WHERE so.OrderDescription = 'Anulado')

    --Estados de finalización (Entregado, Entregado en Express center)
    IF @GuideStatusOrderId = @StatusDelivery
       OR @GuideStatusOrderId = @StatusDeliveryExpress
        --Solo pueden pasar a COD Liquidado o COD PAGADO
        IF @StatusOrderId = @StatusCODSettlement
           OR @StatusOrderId = @StatusCODPaid
            SELECT 1 StatusCode,
                   'Estado válido.' Description;
        ELSE
            SELECT 0 StatusCode,
                   'La guía se encuentra en estado Entregada.' Description;
    --COD Liquidado
    ELSE IF @GuideStatusOrderId = @StatusCODSettlement
        --Solo puede pasar a COD pagado
        IF @StatusOrderId = @StatusCODPaid
            SELECT 1 StatusCode,
                   'Estado válido.' Description;
        ELSE
            SELECT 0 StatusCode,
                   'La guía se encuentra en estado COD Liquidado.' Description;
    --COD Pagado
    ELSE IF @GuideStatusOrderId = @StatusCODPaid
        --Solo puede pasar a COD Liquidado
        IF @StatusOrderId = @StatusCODSettlement
            SELECT 1 StatusCode,
                   'Estado válido.' Description;
        ELSE
            SELECT 0 StatusCode,
                   'La guía se encuentra en estado COD Pagado.' Description;
    --ANULADO
    ELSE IF @GuideStatusOrderId = @StatusCancelled
        SELECT 0 StatusCode,
               'La guía se encuentra en estado Anulado.' Description;
    --Devuelto en Express Center
    ELSE IF @GuideStatusOrderId = @StatusReturnExpress
        SELECT 0 StatusCode,
               'La guía se encuentra en estado Devuelto en Express Center.' Description;
    --Devuelto
    ELSE IF @GuideStatusOrderId = @StatusReturn
        SELECT 0 StatusCode,
               'La guía se encuentra en estado Devuelto.' Description;

    ELSE --De momento no se valida nada más
        SELECT 1 StatusCode,
               'Estado válido.' Description;

END;
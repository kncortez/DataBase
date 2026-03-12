/* =================================================
   SP:        CheckStatusForWorkflow
   Propósito: Se verifica si el estado de la guia es parte de los estados del flujo de trabajo
   Autor:     Erick Hernandez
   Historia:  FDAPI-5684
   Fecha:     2026-03-11

=== CHANGELOG ============================
=========================================== */
CREATE PROCEDURE [dbo].[CheckStatusForWorkflow]
	@WorkflowID BIGINT,
	@GuideSeries NVARCHAR(2),
    @GuideNumber INT
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @GuideStatusOrderID TINYINT = 0;
	
	SELECT @GuideStatusOrderID = DO.StatusOrderId
	FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH (NOLOCK)
	WHERE DO.Guide_Serie = @GuideSeries
	AND DO.Guide_Number = @GuideNumber;
	
	IF @GuideStatusOrderID IS NULL
    BEGIN
        SELECT -1 AS RESULT;
        RETURN;
    END
	IF EXISTS
    (
        SELECT 1
        FROM WorkflowStatusMap WITH (NOLOCK)
        WHERE StatusOrderId = @GuideStatusOrderID
        AND WorkflowId = @WorkflowID
        AND RowStatus = 1
    )
    BEGIN
        SELECT 1 AS RESULT;
    END
    ELSE
    BEGIN
        SELECT 0 AS RESULT;
    END
END;
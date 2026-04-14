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
	
	DECLARE @GuideStatusOrderID INT = 0;
	DECLARE @CurrentStatus NVARCHAR(50);
	
	SELECT @GuideStatusOrderID = DO.StatusOrderId, @CurrentStatus = S.OrderDescription
	FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH (NOLOCK)
	INNER JOIN DeliveryBackOffice.dbo.StatusOrder S WITH (NOLOCK)
		ON S.StatusOrderId = DO.StatusOrderId
	WHERE DO.Guide_Serie = @GuideSeries
	AND DO.Guide_Number = @GuideNumber;
	
	IF @GuideStatusOrderID IS NULL
    BEGIN
        SELECT 0 AS IsAllowed, NULL AS CurrentStatus;
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
        SELECT 1 AS IsAllowed, @CurrentStatus AS CurrentStatus;
    END
    ELSE
    BEGIN
        SELECT 0 AS IsAllowed, @CurrentStatus AS CurrentStatus;
    END
END;
/* =================================================
   SP:        GetWorkflowStatuses
   Propósito: Se obtienen todos los estados disponibles y asignados al flujo de trabajo
   Autor:     Erick Hernandez
   Historia:  FDAPI-5689
   Fecha:     2026-03-06

=== CHANGELOG ============================
=========================================== */
CREATE PROCEDURE [dbo].[GetWorkflowStatuses]
	@WorkflowID BIGINT
AS
BEGIN
	SELECT
		SO.StatusOrderId,
		SO.OrderDescription AS StatusName,
		CASE 
			WHEN WSM.WorkflowId IS NULL THEN 0
			ELSE 1
		END AS IsAssigned
	FROM DeliveryBackOffice.dbo.StatusOrder SO WITH (NOLOCK)
	LEFT JOIN DeliveryBackOffice.dbo.WorkflowStatusMap WSM WITH (NOLOCK)
		ON SO.StatusOrderId = WSM.StatusOrderId
		AND WSM.WorkflowId = @WorkflowID
		AND WSM.RowStatus = 1
	WHERE SO.RowStatus = 1
	ORDER BY SO.StatusOrderId;
END;
/* =================================================
   SP:        GetAllWorkflows
   Propósito: Se obtienen todos los flujos de trabajo activos
   Autor:     Erick Hernandez
   Historia:  FDAPI-5686
   Fecha:     2026-03-05

=== CHANGELOG ============================
=========================================== */
CREATE PROCEDURE [dbo].[GetAllWorkflows]
AS
BEGIN
	SELECT 
    W.WorkflowId,
    W.Name AS Workflow,
	ISNULL(
		'(' + CAST(
				(
					SELECT COUNT(*)
					FROM WorkflowStatusMap WSM WITH (NOLOCK)
					WHERE WSM.WorkflowId = W.WorkflowId
					AND WSM.RowStatus = 1
				) AS NVARCHAR(10)
			) + 
		') ' +
		STUFF(
			(
				SELECT ', ' + SO.OrderDescription
				FROM DeliveryBackOffice.dbo.WorkflowStatusMap WSM WITH (NOLOCK)
				INNER JOIN DeliveryBackOffice.dbo.StatusOrder SO WITH (NOLOCK)
					ON SO.StatusOrderId = WSM.StatusOrderId
				WHERE WSM.WorkflowId = W.WorkflowId
				AND WSM.RowStatus = 1
				FOR XML PATH(''), TYPE
			).value('.', 'NVARCHAR(MAX)')
		,1,2,''), '(0)') AS Statuses
	FROM DeliveryBackOffice.dbo.Workflow W WITH(NOLOCK)
	WHERE W.RowStatus = 1
	ORDER BY ISNULL(W.DateUpdated, W.DateCreated) DESC;
END;

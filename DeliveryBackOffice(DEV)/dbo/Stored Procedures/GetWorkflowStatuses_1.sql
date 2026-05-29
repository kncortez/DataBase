/* =================================================
   SP:        GetWorkflowStatuses
   Propósito: Se obtienen todos los estados disponibles y asignados al flujo de trabajo
   Autor:     Erick Hernandez
   Historia:  FDAPI-5689
   Fecha:     2026-03-06

=== CHANGELOG ============================
2026-04-23 | Historia/épica: FDAPI-6128 | Autor: Erick Hernandez | Se agrega parámetro de código del país
=========================================== */
CREATE PROCEDURE [dbo].[GetWorkflowStatuses]
	@WorkflowID BIGINT,
	@CountryId VARCHAR(2)
AS
BEGIN
	DECLARE @RowStatus_Active INT = 1;

	IF EXISTS (SELECT 1 FROM DeliveryBackOffice.dbo.CatCountry WITH (NOLOCK) WHERE IdCountry = @CountryId AND CountryRowStatus = @RowStatus_Active)
	BEGIN
		SELECT ISNULL(W.Name, '') AS WorkflowName
		FROM DeliveryBackOffice.dbo.Workflow W WITH (NOLOCK)
		WHERE W.WorkflowId = @WorkflowID
		AND W.RowStatus = @RowStatus_Active;

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
			AND WSM.CountryId = @CountryId
			AND WSM.WorkflowId = @WorkflowID
			AND WSM.RowStatus = @RowStatus_Active
		WHERE SO.RowStatus = @RowStatus_Active
		ORDER BY SO.StatusOrderId;
	END
END;
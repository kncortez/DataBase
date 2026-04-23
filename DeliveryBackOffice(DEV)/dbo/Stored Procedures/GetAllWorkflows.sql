/* =================================================
   SP:        GetAllWorkflows
   Propósito: Se obtienen todos los flujos de trabajo activos
   Autor:     Erick Hernandez
   Historia:  FDAPI-5686
   Fecha:     2026-03-05

=== CHANGELOG ============================
2026-04-22 | Historia/épica: FDAPI-6127 | Autor: Erick Hernandez | Se agrega parámetro de código del país
=========================================== */
CREATE PROCEDURE [dbo].[GetAllWorkflows]
	@CountryId VARCHAR(2)
AS
BEGIN
	DECLARE @RowStatus_Active INT = 1;

	IF EXISTS (SELECT 1 FROM DeliveryBackOffice.dbo.CatCountry WITH (NOLOCK) WHERE IdCountry = @CountryId AND CountryRowStatus = @RowStatus_Active)
	BEGIN
		SELECT W.WorkflowId, W.Name AS Workflow, 
			CONCAT('(', COUNT(WSM.StatusOrderId), ') ', STRING_AGG(SO.OrderDescription, ', ')) AS Statuses
		FROM DeliveryBackOffice.dbo.Workflow W WITH(NOLOCK)
		LEFT JOIN DeliveryBackOffice.dbo.WorkflowStatusMap WSM WITH (NOLOCK)
			ON WSM.WorkflowId = W.WorkflowId 
			AND WSM.RowStatus = @RowStatus_Active AND WSM.CountryId = @CountryId
		LEFT JOIN DeliveryBackOffice.dbo.StatusOrder SO WITH (NOLOCK)
			ON SO.StatusOrderId = WSM.StatusOrderId 
			AND SO.RowStatus = @RowStatus_Active
		WHERE W.RowStatus = @RowStatus_Active
		GROUP BY W.WorkflowId, W.Name, W.DateUpdated, W.DateCreated
		ORDER BY ISNULL(W.DateUpdated, W.DateCreated) DESC;
	END
END;

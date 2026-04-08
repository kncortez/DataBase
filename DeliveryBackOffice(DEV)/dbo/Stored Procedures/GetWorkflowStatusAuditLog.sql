/* =================================================
   SP:        GetWorkflowStatusAuditLog
   Propósito: Se obtiene un historico de los estatus asignados/eliminados sobre el flujo de trabajo.
   Autor:     Erick Hernandez
   Historia:  FDAPI-5705
   Fecha:     2026-03-10

=== CHANGELOG ============================
=========================================== */
CREATE PROCEDURE [dbo].[GetWorkflowStatusAuditLog]
	@WorkflowID BIGINT
AS
BEGIN
	SELECT 
		ISNULL(IU.Username, '') AS UserName,
		CONVERT(VARCHAR(16), L.DateCreated, 120) AS Date, W.Name AS Workflow, SO.OrderDescription AS StatusName, 
		CASE
			WHEN L.OperationType = 1 THEN 'Agregó'
			ELSE 'Quitó'
		END AS Operation  
	FROM DeliveryBackOffice.dbo.WorkflowStatusMapLog L WITH (NOLOCK)
	INNER JOIN DeliveryBackOffice.dbo.StatusOrder SO WITH (NOLOCK)
		ON SO.StatusOrderId = L.StatusOrderId
	INNER JOIN DeliveryBackOffice.dbo.Workflow W WITH (NOLOCK)
		ON W.WorkflowId = L.WorkflowId
	INNER JOIN DeliveryBackOffice.dbo.TokenLog TL WITH (NOLOCK)
		ON TL.TknIdToken = L.TokenCreated --AND TL.TknRowStatus = 1
	INNER JOIN DeliveryBackOffice.dbo.RegisterUser RU WITH (NOLOCK)
		ON RU.UsrIdUser = TL.TknIdUser AND RU.UsrRowStatus = 1
	INNER JOIN DeliveryBackOffice.dbo.InternalUser IU WITH (NOLOCK)
		ON IU.RegisterUserID = RU.UsrIdUser AND IU.RowStatus = 1
	WHERE W.WorkflowId = @WorkflowId
	ORDER BY L.DateCreated ASC;
END;
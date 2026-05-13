/* =================================================
   SP:        GetWorkflowStatusAuditLog
   Propósito: Se obtiene un historico de los estatus asignados/eliminados sobre el flujo de trabajo.
   Autor:     Erick Hernandez
   Historia:  FDAPI-5705
   Fecha:     2026-03-10

=== CHANGELOG ============================
2026-04-24 | Historia/épica: FDAPI-6131 | Autor: Erick Hernandez | Se agrega parámetro de código del país
=========================================== */
CREATE PROCEDURE [dbo].[GetWorkflowStatusAuditLog]
	@WorkflowID BIGINT,
	@CountryId VARCHAR(2)
AS
BEGIN
	DECLARE @RowStatus_Active INT = 1;

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
		ON TL.TknIdToken = L.TokenCreated
	INNER JOIN DeliveryBackOffice.dbo.RegisterUser RU WITH (NOLOCK)
		ON RU.UsrIdUser = TL.TknIdUser
	INNER JOIN DeliveryBackOffice.dbo.InternalUser IU WITH (NOLOCK)
		ON IU.RegisterUserID = RU.UsrIdUser
	WHERE W.WorkflowId = @WorkflowId
	AND L.CountryId = @CountryId
	AND RU.UsrRowStatus = @RowStatus_Active
	AND IU.RowStatus = @RowStatus_Active
	ORDER BY L.DateCreated ASC;
END;
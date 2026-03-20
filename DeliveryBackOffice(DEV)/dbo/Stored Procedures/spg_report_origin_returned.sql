
/* =================================================
   SP:        [dbo].[spg_report_origin_returned]
   Propósito: Reporte de producto retornado al origen
   Autor:     Carlos Cano
   Historia:  
   Fecha:     2020-09-02
============================================
=== CHANGELOG ================================
2026-03-19 | Historia/épica: FDAPI-5801 | Autor: Brenda Echeverria | reemplazo de JOIN implicito por explicito, operador + por funcion CONCAT, aritmetica de fechas por DATEADD, uso de alias segun lineamientos
=========================================== */
CREATE PROCEDURE [dbo].[spg_report_origin_returned]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @Yesterday DATETIME;
	SET  @Yesterday= DATEADD(DAY, -1, GETDATE());

    SELECT DISTINCT
		CONCAT(WH.Guide_Serie , WH.Guide_Number) AS guide,
		CONCAT(ORD.Receiver_FirstName, ' ' , ORD.Receiver_LastName) AS receiver,
		(
			SELECT DeliveryBackOffice.dbo.fn_get_rackposition(WH.Guide_Serie, WH.Guide_Number)
		) AS [Ubicacion_Bodega],
		DATEDIFF(DAY, det.Date_Created, GETDATE()) AS Days_Overdue
	FROM DeliveryBackOffice.dbo.Warehouse AS WH
	INNER JOIN
	(
		SELECT
			DOD.Guide_Serie,
			DOD.Guide_Number,
			MAX(DOD.DateCreated) AS Date_Created
		FROM DeliveryBackOffice.dbo.DeliveryOrderDetail AS DOD WITH (NOLOCK)
		WHERE DOD.StatusOrderId = 6
		GROUP BY
			DOD.Guide_Serie,
			DOD.Guide_Number
	) AS DET
		ON DET.Guide_Serie = WH.Guide_Serie
	AND DET.Guide_Number = WH.Guide_Number
	INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder AS ORD WITH (NOLOCK)
		ON ORD.Guide_Serie = DET.Guide_Serie
	AND ORD.Guide_Number = DET.Guide_Number
	WHERE WH.Active = 1
	AND DET.Date_Created <= @Yesterday
	ORDER BY Days_Overdue;

END

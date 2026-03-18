/* =================================================
   SP:        [dbo].[spg_report_orphan_product]
   Propósito: Reporte de productos huerfanos
   Autor:     Carlos Cano
   Historia:  
   Fecha:     2020-09-02
============================================
=== CHANGELOG ================================
2024-11-19 | Historia/épica: FDAPI-5802 | Autor: Brenda Echeverria |
-----
2024-06-13 | Historia/épica: FDAPI-2420 | Autor: Cristian Suazo |
=========================================== */
ALTER PROCEDURE [dbo].[spg_report_orphan_product]
				 @IdCountry NVARCHAR(2) = 'GT'
AS
BEGIN

	SET NOCOUNT ON;

	SELECT DISTINCT
		CONCAT(WH.Guide_Serie , WH.Guide_Number) AS guide,
		CONCAT(DO.Receiver_FirstName , ' ' , DO.Receiver_LastName) AS receiver,
		DeliveryBackOffice.dbo.fn_get_rackposition(WH.Guide_Serie, WH.Guide_Number) AS [Ubicacion_Bodega],
		DATEDIFF(DAY, GUIDES.Date_Created, GETDATE()) AS Days_Overdue
	FROM DeliveryBackOffice.dbo.Warehouse WH  WITH (NOLOCK)
	INNER JOIN (
		SELECT 
			DOD.Guide_Serie, 
			DOD.Guide_Number,
			MAX(dod.DateCreated) AS Date_Created
		FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD WITH (NOLOCK)
		WHERE DOD.StatusOrderId = 5
		GROUP BY DOD.Guide_Serie, DOD.Guide_Number
	) AS GUIDES
		ON GUIDES.Guide_Serie = WH.Guide_Serie 
	   AND GUIDES.Guide_Number = WH.Guide_Number
	INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder DO WITH (NOLOCK)
		ON DO.Guide_Serie = GUIDES.Guide_Serie 
	   AND DO.Guide_Number = GUIDES.Guide_Number
	WHERE 
		WH.Active = 1
		AND GUIDES.Date_Created <= DATEADD(DAY, -1, GETDATE())
		AND ISNULL(do.SenderCountryId , 'GT') = @IdCountry
	ORDER BY Days_Overdue;

END

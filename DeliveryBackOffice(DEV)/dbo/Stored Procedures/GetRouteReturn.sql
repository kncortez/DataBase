
-- =============================================
-- Author:		<Oscar, Morales>
-- Create date: <2022-02-21>
-- Description:	<Obtiene información del despacho de devolución en base a una ruta y una fecha.>
-- =============================================

CREATE PROCEDURE [dbo].[GetRouteReturn]
	@IdRoute INT,
	@Date DATE
AS
BEGIN

	--TABLE 0 Información de la ruta de devolución
	SELECT
		ra.IdRouteAssigment
	   ,(SELECT
				COUNT(1)
			FROM RouteAssigment ra
			JOIN ServiceManagement sm
				ON ra.IdRouteAssigment = sm.IdPuRouteAssigment
			JOIN PieceByService pbs
				ON pbs.ServiceManagmentId = sm.IdServiceManagement
			JOIN DeliveryOrderPiece dop
				ON dop.GuidePiece = pbs.GuidePieceId
			WHERE ra.IdRoute = @IdRoute
			AND ra.DateOfRoute = @Date
			AND (dop.IsDry IS NULL
			OR dop.IsDry = 1))
		PiecesDry
	   ,(SELECT
				COUNT(1)
			FROM RouteAssigment ra
			JOIN ServiceManagement sm
				ON ra.IdRouteAssigment = sm.IdPuRouteAssigment
			JOIN PieceByService pbs
				ON pbs.ServiceManagmentId = sm.IdServiceManagement
			JOIN DeliveryOrderPiece dop
				ON dop.GuidePiece = pbs.GuidePieceId
			WHERE ra.IdRoute = @IdRoute
			AND ra.DateOfRoute = @Date
			AND (dop.IsDry = 0))
		PiecesCold
	   ,sr.CUI
	   ,ra.IdVehicle VehicleId
	   ,sbp.SequenceCode IdManifest
	FROM RouteAssigment ra
	LEFT JOIN SenderReceiver sr
		ON ra.IdCurrierMan = sr.ID
	LEFT JOIN SettlementByPickup sbp
		ON sbp.RouteAssigmentId = ra.IdRouteAssigment
	WHERE ra.IdRoute = @IdRoute
	AND ra.DateOfRoute = @Date
	AND ra.RowStatus = 1

	--TABLE 1 Información de las guías en despacho de devolución
	SELECT
		CONCAT(do.Guide_Serie, do.Guide_Number) NUMGUIA
	   ,CONCAT(do.Guide_Serie, do.Guide_Number,'-', X.Pieces) GUIA
	   ,ISNULL(do.Ticket_Number, ' ') AS Ticket_Number
	   ,CONCAT(ISNULL(do.Sender_FirstName, ''), CASE
			WHEN do.Sender_FirstName IS NULL THEN ''
			ELSE CASE
					WHEN do.Sender_LastName IS NULL THEN ''
					ELSE ' '
				END
		END, ISNULL(do.Sender_LastName, '')) NAME
	   ,do.Sender_Address AS HUB_ORIGEN
	   ,do.Sender_Address AS HUB_DESTINO
	   ,X.Pieces PIEZAS_PROCESADAS
	   ,CASE
			WHEN X.Pieces = (ISNULL(do.Pieces_Dry, 0) + ISNULL(do.Pieces_Cold, 0)) THEN 1
			ELSE 0
		END CANT_PIEZAS_TOTAL
	   ,CONCAT(X.Pieces, ' de ', ISNULL(do.Pieces_Dry, 0) + ISNULL(do.Pieces_Cold, 0)) PIEZAS_PENDIENTES
	FROM DeliveryOrder do WITH (NOLOCK)
	JOIN (SELECT
			dop.GuideSerie
		   ,dop.GuideNumber
		   ,COUNT(1) Pieces
		FROM RouteAssigment ra
		JOIN ServiceManagement sm
			ON ra.IdRouteAssigment = sm.IdPuRouteAssigment
		JOIN PieceByService pbs
			ON pbs.ServiceManagmentId = sm.IdServiceManagement
		JOIN DeliveryOrderPiece dop
			ON dop.GuidePiece = pbs.GuidePieceId
		WHERE ra.IdRoute = @IdRoute
		AND ra.DateOfRoute = @date
		GROUP BY dop.GuideSerie
				,dop.GuideNumber) X
		ON X.GuideSerie = do.Guide_Serie
			AND X.GuideNumber = do.Guide_Number
END
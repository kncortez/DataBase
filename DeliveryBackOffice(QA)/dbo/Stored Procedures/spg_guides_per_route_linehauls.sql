--EXEC spg_guides_per_route_linehauls 58
CREATE PROCEDURE [dbo].[spg_guides_per_route_linehauls]
		@IdRoute INT,
		@DateOfRoute DATE
AS
BEGIN

SELECT  
					CONCAT(dop.GuideSerie, CAST(dop.GuideNumber AS VARCHAR)) AS NUMGUIA
				   ,CONCAT(dop.GuideSerie, CAST(dop.GuideNumber AS VARCHAR), '-1'/*, CAST(dop.NoPiece AS VARCHAR)*/) GUIA
				   ,ISNULL(serv.Ticket_Number, '') AS Ticket_Number
				   ,ISNULL(serv.Receiver_FirstName, '') + ' ' + ISNULL(serv.Receiver_LastName, '') NAME
				   ,hl_origen.HubAbbreviation AS HUB_ORIGEN
				   ,hl_destino.HubAbbreviation AS HUB_DESTINO
				   ,(SELECT
							ISNULL(COUNT(1),0)
					FROM dbo.PieceByService pbs
					INNER JOIN DeliveryOrderPiece pci WITH (NOLOCK)
						ON pci.GuidePiece = pbs.GuidePieceId
					WHERE pci.GuideSerie = dop.GuideSerie
					AND pci.GuideNumber = dop.GuideNumber					
					AND pbs.ServiceManagmentId = sm.IdServiceManagement) PIEZAS_PROCESADAS
				   ,	CASE WHEN	(CAST((SELECT
							ISNULL(COUNT(1),0)
					FROM dbo.PieceByService pbs
					INNER JOIN DeliveryOrderPiece pci WITH (NOLOCK)
						ON pci.GuidePiece = pbs.GuidePieceId
					WHERE 
					pci.GuideSerie = dop.GuideSerie
					AND pci.GuideNumber = dop.GuideNumber
					AND pbs.ServiceManagmentId = sm.IdServiceManagement)
					AS VARCHAR(50)) = CAST(serv.Pieces_Dry + serv.Pieces_Cold AS VARCHAR(50))) THEN
					1
					ELSE 
					0
					END  AS CANT_PIEZAS_TOTAL
				   ,CAST((SELECT
							ISNULL(COUNT(1),0)
					FROM dbo.PieceByService pbs
					INNER JOIN DeliveryOrderPiece pci WITH (NOLOCK)
						ON pci.GuidePiece = pbs.GuidePieceId
					WHERE 
					pci.GuideSerie = dop.GuideSerie
					AND pci.GuideNumber = dop.GuideNumber
					AND pbs.ServiceManagmentId = sm.IdServiceManagement)
					AS VARCHAR(50)) + ' de ' + CAST(serv.Pieces_Dry + serv.Pieces_Cold AS VARCHAR(50)) AS PIEZAS_PENDIENTES
					,0 PiecesDry
					,0 PiecesCold
				-- ,1 as RUTA
				-- ,getdate() as FechaRuta
				--,200 as StatusCode
				FROM 	ServiceManagement sm 
	INNER JOIN RouteAssigment ra WITH (NOLOCK) ON sm.IdPuRouteAssigment = ra.IdRouteAssigment and ra.RowStatus = 1
	INNER JOIN PieceByService pbs WITH (NOLOCK) ON sm.IdServiceManagement = pbs.ServiceManagmentId and pbs.RowStatus = 1
	INNER JOIN DeliveryOrderPiece dop  WITH (NOLOCK) ON pbs.GuidePieceId = dop.GuidePiece 
			 LEFT   JOIN	DeliveryBackOffice.dbo.DeliveryOrder serv WITH (NOLOCK) on dop.GuideSerie = serv.Guide_Serie and dop.GuideNumber = serv.Guide_Number 
			 LEFT 	JOIN DeliveryBackOffice.dbo.TownshipByHubLogistic tbh_origen WITH (NOLOCK)
					ON serv.SenderIdTownship = tbh_origen.IdTownship
						AND tbh_origen.StatusTownshipHub = 1
			 LEFT	JOIN DeliveryBackOffice.dbo.TownshipByHubLogistic tbh_destino WITH (NOLOCK)
					ON serv.ReceiverIdTownship = tbh_destino.IdTownship
						AND tbh_destino.StatusTownshipHub = 1
			 LEFT	JOIN DeliveryBackOffice.dbo.HubLogistics hl_origen WITH (NOLOCK)
					ON tbh_origen.IdHublogistic = hl_origen.IdHublogistic
			 LEFT	JOIN DeliveryBackOffice.dbo.HubLogistics hl_destino WITH (NOLOCK)
					ON tbh_destino.IdHublogistic = hl_destino.IdHublogistic
	WHERE ra.IdRoute =  @IdRoute and ra.DateOfRoute = @DateOfRoute
	AND serv.HubDestinationId IS NULL AND serv.HubOriginId IS NULL
	GROUP BY 	dop.GuideSerie,dop.GuideNumber,serv.Ticket_Number,serv.Receiver_FirstName,serv.Receiver_LastName,
	hl_origen.HubAbbreviation ,hl_destino.HubAbbreviation,serv.Pieces_Dry , serv.Pieces_Cold,
	sm.IdServiceManagement,serv.HubDestinationId ,serv.HubOriginId
	UNION 
		
SELECT  
					CONCAT(dop.GuideSerie, CAST(dop.GuideNumber AS VARCHAR)) AS NUMGUIA
				   ,CONCAT(dop.GuideSerie, CAST(dop.GuideNumber AS VARCHAR), '-1'/*, CAST(dop.NoPiece AS VARCHAR)*/) GUIA
				   ,ISNULL(serv.Ticket_Number, '') AS Ticket_Number
				   ,ISNULL(serv.Receiver_FirstName, '') + ' ' + ISNULL(serv.Receiver_LastName, '') NAME
				   ,hl_origen.HubAbbreviation AS HUB_ORIGEN
				   ,hl_destino.HubAbbreviation AS HUB_DESTINO
				   ,(SELECT
							ISNULL(COUNT(1),0)
					FROM dbo.PieceByService pbs
					INNER JOIN DeliveryOrderPiece pci WITH (NOLOCK)
						ON pci.GuidePiece = pbs.GuidePieceId
					WHERE pci.GuideSerie = dop.GuideSerie
					AND pci.GuideNumber = dop.GuideNumber					
					AND pbs.ServiceManagmentId = sm.IdServiceManagement) PIEZAS_PROCESADAS
				   ,	CASE WHEN	(CAST((SELECT
							ISNULL(COUNT(1),0)
					FROM dbo.PieceByService pbs
					INNER JOIN DeliveryOrderPiece pci WITH (NOLOCK)
						ON pci.GuidePiece = pbs.GuidePieceId
					WHERE 
					pci.GuideSerie = dop.GuideSerie
					AND pci.GuideNumber = dop.GuideNumber
					AND pbs.ServiceManagmentId = sm.IdServiceManagement)
					AS VARCHAR(50)) = CAST(serv.Pieces_Dry + serv.Pieces_Cold AS VARCHAR(50))) THEN
					1
					ELSE 
					0
					END  AS CANT_PIEZAS_TOTAL
				   ,CAST((SELECT
							ISNULL(COUNT(1),0)
					FROM dbo.PieceByService pbs
					INNER JOIN DeliveryOrderPiece pci WITH (NOLOCK)
						ON pci.GuidePiece = pbs.GuidePieceId 
					WHERE 
					pci.GuideSerie = dop.GuideSerie
					AND pci.GuideNumber = dop.GuideNumber
					AND pbs.ServiceManagmentId = sm.IdServiceManagement)
					AS VARCHAR(50)) + ' de ' + CAST(serv.Pieces_Dry + serv.Pieces_Cold AS VARCHAR(50)) AS PIEZAS_PENDIENTES
					,0 PiecesDry
					,0 PiecesCold
				-- ,1 as RUTA
				-- ,getdate() as FechaRuta
				--,200 as StatusCode
				FROM 	ServiceManagement sm  WITH (NOLOCK)
	INNER JOIN RouteAssigment ra WITH (NOLOCK) ON sm.IdPuRouteAssigment = ra.IdRouteAssigment and ra.RowStatus = 1
	INNER JOIN PieceByService pbs WITH (NOLOCK) ON sm.IdServiceManagement = pbs.ServiceManagmentId and pbs.RowStatus = 1
	INNER JOIN DeliveryOrderPiece dop WITH (NOLOCK) ON pbs.GuidePieceId = dop.GuidePiece 
			 INNER   JOIN	DeliveryBackOffice.dbo.DeliveryOrder serv WITH (NOLOCK) on dop.GuideSerie = serv.Guide_Serie and dop.GuideNumber = serv.Guide_Number 
			 INNER	JOIN DeliveryBackOffice.dbo.HubLogistics hl_origen WITH (NOLOCK)
					ON serv.HubOriginId = hl_origen.IdHublogistic
			 INNER	JOIN DeliveryBackOffice.dbo.HubLogistics hl_destino WITH (NOLOCK)
					ON serv.HubDestinationId = hl_destino.IdHublogistic
	WHERE ra.IdRoute =  @IdRoute and ra.DateOfRoute = @DateOfRoute
	GROUP BY 	dop.GuideSerie,dop.GuideNumber,serv.Ticket_Number,serv.Receiver_FirstName,serv.Receiver_LastName,
	hl_origen.HubAbbreviation ,hl_destino.HubAbbreviation,serv.Pieces_Dry , serv.Pieces_Cold,
	sm.IdServiceManagement,serv.HubDestinationId,serv.HubOriginId
	

END

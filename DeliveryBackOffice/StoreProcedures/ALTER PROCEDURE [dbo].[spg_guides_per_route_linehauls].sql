USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spg_guides_per_route_linehauls]    Script Date: 5/08/2021 04:45:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[spg_guides_per_route_linehauls]
		@IdRoute INT
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
					INNER JOIN DeliveryOrderPiece pci
						ON pci.GuidePiece = pbs.GuidePieceId
					WHERE pci.GuideSerie = dop.GuideSerie
					AND pci.GuideNumber = dop.GuideNumber					
					AND pbs.ServiceManagmentId = sm.IdServiceManagement) PIEZAS_PROCESADAS
				   ,	CASE WHEN	(CAST((SELECT
							ISNULL(COUNT(1),0)
					FROM dbo.PieceByService pbs
					INNER JOIN DeliveryOrderPiece pci
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
					INNER JOIN DeliveryOrderPiece pci
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
	INNER JOIN RouteAssigment ra ON sm.IdPuRouteAssigment = ra.IdRouteAssigment and ra.RowStatus = 1
	INNER JOIN PieceByService pbs ON sm.IdServiceManagement = pbs.ServiceManagmentId and pbs.RowStatus = 1
	INNER JOIN DeliveryOrderPiece dop ON pbs.GuidePieceId = dop.GuidePiece 
			    JOIN	DeliveryBackOffice.dbo.DeliveryOrder serv on dop.GuideSerie = serv.Guide_Serie and dop.GuideNumber = serv.Guide_Number 
				JOIN DeliveryBackOffice.dbo.TownshipByHubLogistic tbh_origen
					ON serv.SenderIdTownship = tbh_origen.IdTownship
						AND tbh_origen.StatusTownshipHub = 1
				JOIN DeliveryBackOffice.dbo.TownshipByHubLogistic tbh_destino
					ON serv.ReceiverIdTownship = tbh_destino.IdTownship
						AND tbh_destino.StatusTownshipHub = 1
				JOIN DeliveryBackOffice.dbo.HubLogistics hl_origen
					ON tbh_origen.IdHublogistic = hl_origen.IdHublogistic
				JOIN DeliveryBackOffice.dbo.HubLogistics hl_destino
					ON tbh_destino.IdHublogistic = hl_destino.IdHublogistic
	WHERE ra.IdRoute = @IdRoute and ra.DateOfRoute = CONVERT(CHAR(10), GETDATE(), 126)
	GROUP BY 	dop.GuideSerie,dop.GuideNumber,serv.Ticket_Number,serv.Receiver_FirstName,serv.Receiver_LastName,
	hl_origen.HubAbbreviation ,hl_destino.HubAbbreviation,serv.Pieces_Dry , serv.Pieces_Cold,
	sm.IdServiceManagement



END

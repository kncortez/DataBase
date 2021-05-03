USE [DeliveryBackOffice]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- ============================================================================================
-- Author:		<Marco Jiménez>
-- Create date: <2021-04-22>
-- Description:	<Carga las piezas previamente ya escaneadas>
-- ============================================================================================

IF EXISTS (SELECT
			*
		FROM sysobjects
		WHERE ID = OBJECT_ID(N'[dbo].[sps_get_linehauls_by_route]')
		AND OBJECTPROPERTY(ID, N'IsProcedure') = 1)
BEGIN
	DROP PROCEDURE [dbo].[sps_get_linehauls_by_route]
END

GO

CREATE PROCEDURE [dbo].[sps_get_linehauls_by_route] 
@IdRoute AS NVARCHAR(50) = 99999


AS
BEGIN
	DECLARE @ValidateOperation BIGINT = 0
	DECLARE @RowUpdated INT
	DECLARE @ExisteRuta INT
	DECLARE @HUB_Destino INT
	DECLARE @IdRouteASG INT
	DECLARE @ExisteServicio INT
	DECLARE @IdServiceManagement INT
	DECLARE @ExistePiezaPorServicio INT
	DECLARE @ItemsTable AS TABLE (
		Guide_Number INT
	)

	
	BEGIN
		

			DECLARE @RouteValidator AS INT = (SELECT
					COUNT(cl.IdHubDestination) AS CANT
				FROM CatLinehaul cl
				WHERE cl.IdRoute = @IdRoute)

			IF (@RouteValidator > 0)
			BEGIN

				SELECT
					CONCAT(pc.GuideSerie, CAST(pc.GuideNumber AS VARCHAR)) AS NUMGUIA
				   ,CONCAT(pc.GuideSerie, CAST(pc.GuideNumber AS VARCHAR), '-', CAST(pc.NoPiece AS VARCHAR)) GUIA
				   ,ISNULL(serv.Ticket_Number, '') AS Ticket_Number
				   ,ISNULL(serv.Receiver_FirstName, '') + ' ' + ISNULL(serv.Receiver_LastName, '') NAME
				   ,hl_origen.HubAbbreviation AS HUB_ORIGEN
				   ,hl_destino.HubAbbreviation AS HUB_DESTINO
				   ,(SELECT
							ISNULL(COUNT(1),0)
						FROM PieceByService pbs											
							WHERE pbs.ServiceManagmentId = @IdServiceManagement) PIEZAS_PROCESADAS
				   ,serv.Pieces_Dry + serv.Pieces_Cold AS CANT_PIEZAS_TOTAL
				   ,CAST((SELECT
							ISNULL(COUNT(1),0)
						FROM PieceByService pbs											
							WHERE pbs.ServiceManagmentId = @IdServiceManagement)
					AS VARCHAR(50)) + ' de ' + CAST(serv.Pieces_Dry + serv.Pieces_Cold AS VARCHAR(50)) AS PIEZAS_PENDIENTES
				-- ,1 as RUTA
				-- ,getdate() as FechaRuta
				--,200 as StatusCode
				FROM DeliveryBackOffice.dbo.DeliveryOrder serv
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
				JOIN DeliveryOrderPiece pc
					ON serv.Guide_Number = pc.GuideNumber
						AND serv.Guide_Serie = pc.GuideSerie
				WHERE CONCAT(pc.GuideSerie, CAST(pc.GuideNumber AS VARCHAR), '-', CAST(pc.NoPiece AS VARCHAR)) = @Guide_Number
				AND hl_destino.IdHublogistic IN (SELECT
						cl.IdHubDestination
					FROM CatLinehaul cl
					WHERE cl.IdRoute = @IdRoute)

			END
	END
END

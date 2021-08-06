USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spg_manifest_linehauls_email]    Script Date: 3/08/2021 17:05:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[spg_manifest_linehauls_email] @IdManifest INT
AS
BEGIN

SELECT 	  ISNULL(hl_destino.HubAbbreviation, 'HUB') AS ID_HUB_DESTINO	   ,
		cl.Emails	AS Emails
	FROM [DeliveryBackOffice].[dbo].SettlementByPickup dobs
	INNER JOIN [DeliveryBackOffice].[dbo].ServiceManagement sm
		ON sm.IdServiceManagement = dobs.ServiceManagmentId
	LEFT JOIN DeliveryBackOffice.dbo.HubLogistics hl_destino
		ON hl_destino.IdHubLogistic = sm.IdHubDestination
	INNER JOIN CatLinehaul cl ON cl.IdHubDestination = sm.IdHubDestination
	LEFT JOIN DeliveryBackOffice.dbo.SenderReceiver sr
		ON sr.ID = dobs.IdCourier	
	LEFT JOIN DeliveryBackOffice.dbo.RouteAssigment ra ON ra.IdRouteAssigment = sm.IdPuRouteAssigment
	WHERE dobs.SequenceCode = @IdManifest AND cl.IdRoute = ra.IdRoute
	GROUP BY hl_destino.HubAbbreviation, cl.Emails


END

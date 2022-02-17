USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[get_RouteReturn]    Script Date: 14/04/2021 11:20:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- ============================================================================================
-- Author:		<Marco Jiménez>
-- Create date: <2021-04-14>
-- Description:	<Retorna los Hubs configurados para determinada ruta>
-- ============================================================================================


IF EXISTS (SELECT
			1
		FROM sysobjects
		WHERE ID = OBJECT_ID(N'[dbo].[GetHubsbyLinehauls]')
		AND OBJECTPROPERTY(ID, N'IsProcedure') = 1)
BEGIN
	DROP PROCEDURE [dbo].[GetHubsbyLinehauls]
END

GO

CREATE PROCEDURE [dbo].[GetHubsbyLinehauls] @IdRoute AS INT
AS
BEGIN

	SELECT
		hl_destino.HubAbbreviation AS HUB_DESTINO
	FROM DeliveryBackOffice.dbo.HubLogistics hl_destino
	JOIN CatLinehaul cl
		ON hl_destino.IdHublogistic = cl.IdHubDestination
	WHERE cl.IdRoute = @IdRoute


END




USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[GetManifestByRouteLinehauls]    Script Date: 23/06/2021 17:18:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Oscar,Morales>
-- Create date: <2021-06-23>
-- Description:	<>
-- =============================================

CREATE PROCEDURE [dbo].[GetManifestByRouteLinehauls] 
-- Add the parameters for the stored procedure here
	@IdRoute INT
AS
BEGIN
	SET NOCOUNT ON
	
	SELECT sr.CUI, ra.IdVehicle, sbpu.StartingKilometers, sbpu.PiecesDry, sbpu.PiecesCold
	FROM ServiceManagement sm
	INNER JOIN RouteAssigment ra 
		ON sm.IdPuRouteAssigment = ra.IdRouteAssigment and ra.RowStatus = 1
	INNER JOIN SettlementByPickup sbpu 
		ON sm.IdServiceManagement = sbpu.ServiceManagmentId
	INNER JOIN SenderReceiver sr
		ON sbpu.IdCourier = sr.ID
	WHERE ra.IdRoute = @IdRoute 
		AND ra.DateOfRoute = CONVERT(CHAR(10), GETDATE(), 126)

	SET NOCOUNT OFF
END
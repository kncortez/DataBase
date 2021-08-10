USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[GetManifestByRouteLinehauls]    Script Date: 9/08/2021 09:47:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Oscar,Morales>
-- Create date: <2021-06-23>
-- Description:	<>
-- =============================================

ALTER PROCEDURE [dbo].[GetManifestByRouteLinehauls] 
-- Add the parameters for the stored procedure here
	@IdRoute INT,
	@DateofRoute DATE
AS
BEGIN
	SET NOCOUNT ON
	
	SELECT SUM(sbpu.PiecesDry) PiecesDry, SUM(sbpu.PiecesCold) PiecesCold, 
	STUFF(
         (SELECT ', ' + CAST(sbpu.SequenceCode AS VARCHAR)
          FROM ServiceManagement sm
	INNER JOIN RouteAssigment ra 
		ON sm.IdPuRouteAssigment = ra.IdRouteAssigment and ra.RowStatus = 1
	INNER JOIN SettlementByPickup sbpu 
		ON sm.IdServiceManagement = sbpu.ServiceManagmentId
	WHERE ra.IdRoute = @IdRoute
		AND ra.DateOfRoute = @DateofRoute
		AND sm.SubTypeServiceManagmentId = 4
         
          FOR XML PATH (''))
          , 1, 1, '')  AS SequenceCode 
	FROM ServiceManagement sm
	INNER JOIN RouteAssigment ra 
		ON sm.IdPuRouteAssigment = ra.IdRouteAssigment and ra.RowStatus = 1
	INNER JOIN SettlementByPickup sbpu 
		ON sm.IdServiceManagement = sbpu.ServiceManagmentId
	WHERE ra.IdRoute = @IdRoute
		AND ra.DateOfRoute = @DateofRoute
		AND sm.SubTypeServiceManagmentId = 4
	GROUP BY ra.DateOfRoute

	SET NOCOUNT OFF
END
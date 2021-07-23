USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[GetManifestByRouteLinehauls]    Script Date: 23/07/2021 08:23:31 ******/
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
	@IdRoute INT
AS
BEGIN
	SET NOCOUNT ON
	
	SELECT TOP 1 sbpu.PiecesDry, sbpu.PiecesCold
	FROM ServiceManagement sm
	INNER JOIN RouteAssigment ra 
		ON sm.IdPuRouteAssigment = ra.IdRouteAssigment and ra.RowStatus = 1
	INNER JOIN SettlementByPickup sbpu 
		ON sm.IdServiceManagement = sbpu.ServiceManagmentId
	WHERE ra.IdRoute = @IdRoute 
		AND ra.DateOfRoute = CONVERT(CHAR(10), GETDATE(), 126)
	ORDER BY sbpu.DateCreated DESC

	SET NOCOUNT OFF
END
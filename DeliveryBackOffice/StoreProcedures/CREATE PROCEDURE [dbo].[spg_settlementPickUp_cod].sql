USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spg_settlementPickUp_cod]    Script Date: 8/09/2021 01:03:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Morales,Oscar>
-- Create date: <2021-09-07>
-- Description:	<Obtiene información para generar manifiesto de liquidación rutas recolectoras (COD)>
-- =============================================
CREATE PROCEDURE [dbo].[spg_settlementPickUp_cod]
	-- Add the parameters for the stored procedure here
	@IdManifest INT
AS
BEGIN
	DECLARE @GuideCount INT
	DECLARE @Token NVARCHAR(150)
	DECLARE @Username_Received NVARCHAR(200)  = ''

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET @GuideCount = COALESCE ((
			SELECT SUM(co.Guide) 
			FROM (SELECT 1 Guide
					FROM SettlementByPickupDetail
					WHERE SettlementByPickupId = @IdManifest 
						AND IsPieceLiquidaded = 1 -- Pieza de la guia liquidada en recolección
						AND IsCODSettlement = 1 -- Pieza no liquidada en COD
					GROUP BY GuideSerie, GuideNumber) co
		),0)

	SET @Token = (
		SELECT TOP 1 TokenUpdated
		FROM SettlementByPickupDetail
		WHERE SettlementByPickupId = @IdManifest 
			AND IsPieceLiquidaded = 1 -- Pieza de la guia liquidada en recolección
			AND IsCODSettlement = 1 -- Pieza no liquidada en COD
	)

	IF @Token IS NOT NULL 
		AND @Token <> ''
	BEGIN
		SET @Username_Received = COALESCE((
			SELECT CONVERT(NVARCHAR,SSN_IdUser) + ' - ' + SSN_Username as IdUser_Username_Received
			FROM DenariusUser_Dev.dbo.LGN_LogByToken
			WHERE SSN_IdToken = @Token
		), '')
	END

	SELECT sbp.Id ID
		, sbp.DateCreated Date_Received
		, @GuideCount Guides
		, CONCAT(sr.First_Name, ' ', sr.Last_Name) Courier
		, @Username_Received User_Received
		, rou.CodeRoute CodeRoute
	FROM SettlementByPickup sbp
	LEFT JOIN RouteAssigment ra
		ON sbp.RouteAssigmentId = ra.IdRouteAssigment
	LEFT JOIN SenderReceiver sr 
		ON sbp.IdCourier = sr.ID
	LEFT JOIN CatRoute rou
		ON ra.IdRoute = rou.IdRoute
	WHERE sbp.Id = @IdManifest
    
END

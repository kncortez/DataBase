-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-02-23>
-- Description:	<Obtiene información para generar manifiesto de liquidación rutas de devolución (COD)>
-- =============================================
CREATE PROCEDURE [dbo].[spg_settlementReturns_cod]
	-- Add the parameters for the stored procedure here
	@IdManifest INT
AS
BEGIN
	DECLARE @GuideCount INT
	DECLARE @Token NVARCHAR(150)
	DECLARE @Username_Received NVARCHAR(200)  = ''
	DECLARE @Date DATETIME

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET @GuideCount = COALESCE ((
			SELECT SUM(co.Guide) 
			FROM (SELECT 1 Guide
					FROM SettlementByPickupDetail sbpd
					JOIN SettlementByPickup sbp
						ON sbp.Id = sbpd.SettlementByPickupId
					WHERE sbp.SequenceCode = @IdManifest 
						AND sbp.SubTypeServiceManagmentId = 3
						AND IsPieceLiquidaded = 1 -- Pieza de la guia liquidada en devolución
						AND IsCODSettlement = 1 -- Pieza liquidada en COD
					GROUP BY GuideSerie, GuideNumber) co
		),0)

	SELECT TOP 1 
		@Token = CODSettlement_TokenCreated,
		@Date = CODSettlement_DateCreated
	FROM SettlementByPickupDetail sbpd
	JOIN SettlementByPickup sbp
		ON sbp.Id = sbpd.SettlementByPickupId
	WHERE sbp.SequenceCode = @IdManifest 
		AND sbp.SubTypeServiceManagmentId = 3
		AND sbpd.IsPieceLiquidaded = 1 -- Pieza de la guia liquidada en recolección
		AND sbpd.IsCODSettlement = 1 -- Pieza liquidada en COD


	IF @Token IS NOT NULL 
		AND @Token <> ''
	BEGIN
		SET @Username_Received = COALESCE((
			SELECT CONVERT(NVARCHAR,SSN_IdUser) + ' - ' + SSN_Username as IdUser_Username_Received
			FROM DenariusUser_Dev.dbo.LGN_LogByToken
			WHERE SSN_IdToken = @Token
		), '')
	END

	SELECT sbp.SequenceCode ID
		, @Date Date_Received
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
	WHERE sbp.SequenceCode = @IdManifest
		AND sbp.SubTypeServiceManagmentId = 3
    
END

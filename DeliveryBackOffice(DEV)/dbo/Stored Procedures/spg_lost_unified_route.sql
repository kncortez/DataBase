-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-10-17>
-- Description:	<Obtiene información de la paquetes perdidos de rutas unificadas>
-- =============================================
CREATE PROCEDURE [dbo].[spg_lost_unified_route]
	-- Add the parameters for the stored procedure here
	@ManifestId VARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @UnifiedRouteSettlementId TABLE(
		Id INT
	)

	DECLARE @Routes NVARCHAR(MAX)
	DECLARE @TotalGuidesSettlement INT
	DECLARE @TotalPiecesSettlement INT
	DECLARE @TotalPiecesMissing INT

	INSERT INTO @UnifiedRouteSettlementId
		SELECT
			su.Item
		FROM dbo.SplitUnlimited(@ManifestId, ',') su

	SET @Routes = (
	SELECT ', ' + cr.CodeRoute
	FROM UnifiedRouteSettlement urs WITH (NOLOCK)
	INNER JOIN RouteAssigment ra WITH (NOLOCK)
		ON urs.RouteAssignmentId = ra.IdRouteAssigment
	INNER JOIN CatRoute cr WITH (NOLOCK)
		ON ra.IdRoute = cr.IdRoute
	WHERE urs.RowStatus = 1 AND urs.IdUnifiedRouteSettlement IN (SELECT
			Id
		FROM @UnifiedRouteSettlementId)
	FOR XML PATH (''))

	SELECT
		@TotalGuidesSettlement = SUM(urs.TotalGuidesSettled)
	   ,@TotalPiecesSettlement = SUM(urs.TotalPiecesSettled)
	   ,@TotalPiecesMissing = SUM(urs.TotalPiecesMissing)
	FROM UnifiedRouteSettlement urs WITH (NOLOCK)
	WHERE urs.RowStatus = 1
	AND urs.IdUnifiedRouteSettlement IN (SELECT
			Id
		FROM @UnifiedRouteSettlementId)

	SELECT TOP 1
		(CASE
			WHEN p.PerIdPerson IS NOT NULL THEN CONCAT(p.PerFirstName, ' ', p.PerLastName)
			WHEN lbt.SSN_IdUser IS NOT NULL THEN CONCAT(lbt.SSN_IdUser, ' - ', lbt.SSN_Username)
			ELSE 'N/A'
		END) SettlementPerson
	   ,urs.DateSettlement SettlementDate
	   ,IIF(sr.Id IS NOT NULL, CONCAT(sr.First_Name, ' ', sr.Last_Name), 'N/A') CourierName
	   ,IIF(cv.IdVehicle IS NOT NULL, cv.UnitNumber, 'N/A') VechicleUnitNumber
	   ,IIF(cv.IdVehicle IS NOT NULL, cv.Plate, 'N/A') VechiclePlate
	   ,STUFF(@Routes, 1, 2, '') [Routes]
	   ,@TotalGuidesSettlement TotalGuidesSettlement
	   ,@TotalPiecesSettlement TotalPiecesSettlement
	   ,@TotalPiecesMissing TotalPiecesMissing
	FROM UnifiedRouteSettlement urs WITH (NOLOCK)
	LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken lbt WITH (NOLOCK)
		ON urs.UserCODSettlement = lbt.SSN_IdToken
	LEFT JOIN TokenLog tl WITH (NOLOCK)
		ON urs.UserSettlement = tl.TknIdToken
	LEFT JOIN RegisterUser ru WITH (NOLOCK)
		ON tl.TknIdUser = ru.UsrIdUser
	LEFT JOIN Person p WITH (NOLOCK)
		ON ru.UsrIdPerson = p.PerIdPerson
	LEFT JOIN RouteAssigment ra WITH (NOLOCK)
		ON urs.RouteAssignmentId = ra.IdRouteAssigment
	LEFT JOIN SenderReceiver sr WITH (NOLOCK)
		ON ra.IdCurrierMan = sr.Id
	LEFT JOIN CatVehicle cv WITH (NOLOCK)
		ON ra.IdVehicle = cv.IdVehicle
	WHERE urs.RowStatus = 1
	AND urs.UserSettlement IS NOT NULL
	AND urs.IdUnifiedRouteSettlement IN (SELECT
			Id
		FROM @UnifiedRouteSettlementId)
	ORDER BY urs.DateSettlement DESC

END
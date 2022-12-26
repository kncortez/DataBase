-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-10-25>
-- Description:	<Obtiene información de la liquidación COD de rutas unificadas>
-- =============================================
CREATE PROCEDURE [dbo].[spg_settlement_COD_unified_route]
	-- Add the parameters for the stored procedure here
	@CUI NVARCHAR(25)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @RouteAssigment TABLE(
		IdRouteAssigment INT,
		IdRoute INT,
		IdCourier INT,
		IdVehicle INT
	)

	DECLARE @Routes NVARCHAR(MAX)
	DECLARE @TotalGuidesSettlementCOD INT

	INSERT INTO @RouteAssigment
		SELECT
			ra.IdRouteAssigment
		   ,ra.IdRoute
		   ,ra.IdCurrierMan
		   ,ra.IdVehicle
		FROM RouteAssigment ra WITH (NOLOCK)
		INNER JOIN SenderReceiver sr WITH (NOLOCK)
			ON ra.IdCurrierMan = sr.ID
				AND sr.CUI = @CUI
		WHERE ra.RowStatus = 1
		AND ra.DateOfRoute = CAST(GETDATE() AS DATE)

	SET @Routes = (SELECT
			', ' + cr.CodeRoute
		FROM UnifiedRouteSettlement urs WITH (NOLOCK)
		INNER JOIN @RouteAssigment ra
			ON urs.RouteAssignmentId = ra.IdRouteAssigment
		INNER JOIN CatRoute cr WITH (NOLOCK)
			ON ra.IdRoute = cr.IdRoute
		WHERE urs.RowStatus = 1
		AND urs.UserCODSettlement IS NOT NULL
		FOR XML PATH (''))

	SELECT
		@TotalGuidesSettlementCOD = SUM(urs.TotalCODGuidesSettled)
	FROM UnifiedRouteSettlement urs WITH (NOLOCK)
	INNER JOIN @RouteAssigment ra
		ON urs.RouteAssignmentId = ra.IdRouteAssigment
	WHERE urs.RowStatus = 1

	SELECT TOP 1
		(CASE
			WHEN p.PerIdPerson IS NOT NULL THEN CONCAT(p.PerFirstName, ' ', p.PerLastName)
			WHEN lbt.SSN_IdUser IS NOT NULL THEN CONCAT(lbt.SSN_IdUser, ' - ', lbt.SSN_Username)
			ELSE 'N/A'
		END) SettlementPerson
	   ,urs.DateCODSettlement SettlementDate
	   ,IIF(sr.Id IS NOT NULL, CONCAT(sr.First_Name, ' ', sr.Last_Name), 'N/A') CourierName
	   ,IIF(cv.IdVehicle IS NOT NULL, cv.UnitNumber, 'N/A') VechicleUnitNumber
	   ,IIF(cv.IdVehicle IS NOT NULL, cv.Plate, 'N/A') VechiclePlate
	   ,STUFF(@Routes, 1, 2, '') [Routes]
	   ,@TotalGuidesSettlementCOD TotalGuidesSettlementCOD
	FROM UnifiedRouteSettlement urs WITH (NOLOCK)
	INNER JOIN @RouteAssigment ra
		ON urs.RouteAssignmentId = ra.IdRouteAssigment
	LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken lbt WITH (NOLOCK)
		ON urs.UserCODSettlement = lbt.SSN_IdToken
	LEFT JOIN TokenLog tl WITH (NOLOCK)
		ON urs.UserCODSettlement = tl.TknIdToken
	LEFT JOIN RegisterUser ru WITH (NOLOCK)
		ON tl.TknIdUser = ru.UsrIdUser
	LEFT JOIN Person p WITH (NOLOCK)
		ON ru.UsrIdPerson = p.PerIdPerson
	LEFT JOIN SenderReceiver sr WITH (NOLOCK)
		ON ra.IdCourier = sr.Id
	LEFT JOIN CatVehicle cv WITH (NOLOCK)
		ON ra.IdVehicle = cv.IdVehicle
	WHERE urs.RowStatus = 1
	AND urs.UserCODSettlement IS NOT NULL
	ORDER BY urs.DateCODSettlement DESC

END
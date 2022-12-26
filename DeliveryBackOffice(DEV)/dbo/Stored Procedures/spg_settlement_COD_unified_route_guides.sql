-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-10-25>
-- Description:	<Obtiene información de las guías de la liquidación COD de rutas unificadas>
-- =============================================
CREATE PROCEDURE [dbo].[spg_settlement_COD_unified_route_guides] 
	-- Add the parameters for the stored procedure here
	@CUI NVARCHAR(25)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @RouteAssigment TABLE(
		IdRouteAssigment INT
	)

	INSERT INTO @RouteAssigment
		SELECT
			ra.IdRouteAssigment
		FROM RouteAssigment ra WITH (NOLOCK)
		INNER JOIN SenderReceiver sr WITH (NOLOCK)
			ON ra.IdCurrierMan = sr.ID
				AND sr.CUI = @CUI
		WHERE ra.RowStatus = 1
		AND ra.DateOfRoute = CAST(GETDATE() AS DATE)

	SELECT
		CONCAT(ursd.GuideSerie, ursd.GuideNumber) Guide
	   ,ursd.PiecesSettled Pieces
	   ,(CASE
			WHEN do.IsLastMileReturn IS NULL OR
				do.IsLastMileReturn = 0 THEN CONCAT(do.Receiver_FirstName, ' ', do.Receiver_LastName)
			ELSE CONCAT(do.Sender_FirstName, ' ', do.Sender_LastName)
		END) ReceiverName
	   ,(CASE
			WHEN do.IsLastMileReturn IS NULL OR
				do.IsLastMileReturn = 0 THEN do.Receiver_Address
			ELSE do.Sender_Address
		END) ReceiverAddress
	   ,ursd.ServiceSettlementAmount + ursd.ServiceCODSettlementAmount Amount
	FROM UnifiedRouteSettlement urs WITH (NOLOCK)
	INNER JOIN @RouteAssigment ra
		ON urs.RouteAssignmentId = ra.IdRouteAssigment
	INNER JOIN UnifiedRouteSettlementDetail ursd WITH (NOLOCK)
		ON urs.IdUnifiedRouteSettlement = ursd.UnifiedRouteSettlementId
			AND ursd.RowStatus = 1
	INNER JOIN DeliveryOrder do WITH (NOLOCK)
		ON ursd.GuideSerie = do.Guide_Serie
			AND ursd.GuideNumber = do.Guide_Number
	WHERE urs.RowStatus = 1
	AND ursd.UserCODSettlement IS NOT NULL
END
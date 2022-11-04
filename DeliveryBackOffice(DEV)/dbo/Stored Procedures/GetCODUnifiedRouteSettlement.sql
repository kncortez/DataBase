-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-10-24>
-- Description:	<Obtiene información para la liquidación de rutas unificadas COD en desktop>
-- =============================================
CREATE PROCEDURE [dbo].[GetCODUnifiedRouteSettlement]
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
		IdCourier INT
	)

	DECLARE @Routes NVARCHAR(MAX)
	DECLARE @TotalGuides INT
	DECLARE @TotalPieces INT

	INSERT INTO @RouteAssigment
		SELECT
			ra.IdRouteAssigment
		   ,ra.IdRoute
		   ,ra.IdCurrierMan
		FROM RouteAssigment ra WITH (NOLOCK)
		INNER JOIN SenderReceiver sr WITH (NOLOCK)
			ON ra.IdCurrierMan = sr.ID
				AND sr.CUI = @CUI
		WHERE ra.RowStatus = 1
		AND ra.DateOfRoute = CAST(GETDATE() AS DATE)

	IF (SELECT COUNT(1) FROM @RouteAssigment) > 0
	BEGIN

		SET @Routes = (SELECT
				', ' + cr.CodeRoute
			FROM UnifiedRouteSettlement urs WITH (NOLOCK)
			INNER JOIN @RouteAssigment ra
				ON urs.RouteAssignmentId = ra.IdRouteAssigment
			INNER JOIN CatRoute cr WITH (NOLOCK)
				ON ra.IdRoute = cr.IdRoute
			WHERE urs.RowStatus = 1
			AND urs.UserSettlement IS NOT NULL
			FOR XML PATH (''))

		SELECT
			@TotalGuides = COUNT(1)
		   ,@TotalPieces = ISNULL(SUM(ursd.PiecesSettled),0)
		FROM UnifiedRouteSettlement urs WITH (NOLOCK)
		INNER JOIN @RouteAssigment ra
			ON urs.RouteAssignmentId = ra.IdRouteAssigment
		INNER JOIN UnifiedRouteSettlementDetail ursd WITH (NOLOCK)
			ON urs.IdUnifiedRouteSettlement = ursd.UnifiedRouteSettlementId
				AND ursd.RowStatus = 1
		WHERE urs.RowStatus = 1
		AND ursd.UserSettlement IS NOT NULL
		AND ursd.UserCODSettlement IS NULL
		AND ursd.ServiceSettlementAmount + ursd.ServiceCODSettlementAmount > 0

		SELECT
			(SELECT
					CONCAT(sr.First_Name, ' ', sr.Last_Name)
				FROM SenderReceiver sr WITH (NOLOCK)
				WHERE sr.ID = (SELECT TOP 1
						IdCourier
					FROM @RouteAssigment))
			CourierName
		   ,@TotalGuides TotalGuides
		   ,@TotalPieces TotalPieces
		   ,MAX(urs.DateSettlement) DateSettlement
		   ,STUFF(@Routes, 1, 2, '') [Routes]
		   ,SUM(urs.TotalCODGuidesSettled) TotalGuidesSettlement
		FROM UnifiedRouteSettlement urs WITH (NOLOCK)
		INNER JOIN @RouteAssigment ra
			ON urs.RouteAssignmentId = ra.IdRouteAssigment
		WHERE urs.RowStatus = 1
		AND urs.UserSettlement  IS NOT NULL


		SELECT
			ursd.IdUnifiedRouteSettlementDetail IdUnifiedRouteSettlementDetail
		   ,CONCAT(ursd.GuideSerie, ursd.GuideNumber) Guide
		   ,(ursd.ServiceSettlementAmount + ursd.ServiceCODSettlementAmount) Amount
		   ,c.[Name] CustomerName
		   ,CASE
				WHEN invh.inv_serieFEL IS NULL OR
					invh.inv_serieFEL = '' THEN NULL
				ELSE CONCAT(invh.inv_serieFEL, '-', invh.inv_numberFEL)
			END FEL
		   ,c.IdCustomer IdCustomer
		FROM UnifiedRouteSettlementDetail ursd
		INNER JOIN UnifiedRouteSettlement urs
			ON ursd.UnifiedRouteSettlementId = urs.IdUnifiedRouteSettlement
				AND urs.RowStatus = 1
		INNER JOIN @RouteAssigment ra
			ON urs.RouteAssignmentId = ra.IdRouteAssigment
		INNER JOIN DeliveryOrder do WITH (NOLOCK)
			ON ursd.GuideSerie = do.Guide_Serie
				AND ursd.GuideNumber = do.Guide_Number
		LEFT JOIN VisitPointClient vpc WITH (NOLOCK)
			ON do.Sender_ID = vpc.CodeOfReference
		INNER JOIN Customer c WITH (NOLOCK)
			ON ISNULL(do.IdCustomer, vpc.CustomerID) = c.IdCustomer
		LEFT JOIN (SELECT
				MAX(invh1.inv_serieFEL) inv_serieFEL
			   ,MAX(invh1.inv_numberFEL) inv_numberFEL
			   ,invd.dti_fk_orderSerie dti_fk_orderSerie
			   ,invd.dti_fk_orderNumber dti_fk_orderNumber
			FROM invoiceDetail invd WITH (NOLOCK)
			INNER JOIN invoiceHeader invh1 WITH (NOLOCK)
				ON invh1.inv_pk_id = invd.dti_fk_header
				AND invh1.inv_descriptionFEL = 'PROCESO REALIZADO'
				AND invh1.inv_invoiceOfCreditNote IS NULL
			GROUP BY invd.dti_fk_orderSerie
					,invd.dti_fk_orderNumber) invh
			ON invh.dti_fk_orderSerie = do.Guide_Serie
				AND invh.dti_fk_orderNumber = do.Guide_Number
		WHERE ursd.RowStatus = 1
		AND ursd.UserSettlement IS NOT NULL
		AND ursd.UserCODSettlement IS NULL
		AND ursd.ServiceSettlementAmount + ursd.ServiceCODSettlementAmount > 0
	END
END
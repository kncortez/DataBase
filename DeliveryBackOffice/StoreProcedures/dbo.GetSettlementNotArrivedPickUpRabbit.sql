USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[GetSettlementNotArrivedPickUpRabbit]    Script Date: 21/03/2022 09:52:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-03-17>
-- Description:	<Obtiene encabezado para manifiesto de no ingreso recolección Rabbit>
-- =============================================
ALTER PROCEDURE [dbo].[GetSettlementNotArrivedPickUpRabbit]
	-- Add the parameters for the stored procedure here
	@SettlementSequence BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @CourierName NVARCHAR(201)
	DECLARE @SettlementPickupStationId INT
	DECLARE @Guides INT
	DECLARE @Station NVARCHAR(100)
	DECLARE @TokenSettlement VARCHAR(50)

	SELECT TOP 1
		@CourierName = ISNULL(sr.First_Name, '') + ' ' + ISNULL(sr.Last_Name, '')
	   ,@SettlementPickupStationId = IdSettlementPickupStation
	   ,@Station = ISNULL(vp.DescriptionOfClient,'')
	   ,@TokenSettlement = spsd.TokenSettlement
	FROM SettlementPickupStation sps WITH(NOLOCK)
	JOIN SenderReceiver sr WITH(NOLOCK)
		ON sr.ID = sps.CouriermanId
	JOIN SettlementPickupStationDetail spsd WITH(NOLOCK)
		ON spsd.SettlementPickupStationId = sps.IdSettlementPickupStation
	LEFT JOIN VisitPointClient vp WITH(NOLOCK)
		ON vp.CodeOfReference = spsd.SettlementStationId
	WHERE spsd.SettlementSequence = @SettlementSequence
		AND sps.RowStatus = 'TRUE'

	IF @SettlementPickupStationId IS NOT NULL
	BEGIN
	
		SET @Guides = (SELECT
				COUNT(1)
			FROM SettlementPickupStationDetail spsd WITH(NOLOCK)
			JOIN ServiceManagement sm WITH(NOLOCK)
				ON sm.IdServiceManagement = spsd.ServiceManagementId
			JOIN SchedulePickup sp WITH(NOLOCK)
				ON sp.SchedulePickupId = sm.IdSchedulePickup
			JOIN DeliveryOrderPaymentDetail dopd WITH(NOLOCK)
				ON dopd.IdHeaderRecolection = sp.SchedulePickupId
			WHERE spsd.SettlementPickupStationId = @SettlementPickupStationId
				AND spsd.RowStatus = 'TRUE'
				AND spsd.TokenSettlement IS NULL) --No liquidado

		SELECT
			@SettlementSequence Id
		   ,sps.TransactionDate DateRoute
		   ,@CourierName CourierName
		   ,cr.CodeRoute CodeRoute
		   ,(SELECT
					CONVERT(NVARCHAR, lbt.SSN_IdUser) + ' - ' + lbt.SSN_Username
				FROM DenariusUser_Dev.dbo.LGN_LogByToken lbt WITH(NOLOCK)
				WHERE lbt.SSN_IdToken = @TokenSettlement)
			IdUser_Username_Received
		   ,GETDATE() DatePrinted
		   ,@Guides Guides
		   ,ISNULL(@Station, '') Station
		FROM SettlementPickupStation sps WITH(NOLOCK)
		JOIN CatRoute cr WITH(NOLOCK)
			ON cr.IdRoute = sps.RouteId
		WHERE sps.IdSettlementPickupStation = @SettlementPickupStationId

	END
END

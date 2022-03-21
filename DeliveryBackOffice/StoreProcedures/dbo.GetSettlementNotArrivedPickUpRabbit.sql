USE [DeliveryBackOffice]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-03-17>
-- Description:	<Obtiene encabezado para manifiesto de no ingreso recolección Rabbit>
-- =============================================
CREATE PROCEDURE [dbo].[GetSettlementNotArrivedPickUpRabbit]
	-- Add the parameters for the stored procedure here
	@Phone NVARCHAR(50),
	@StationId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @CourierName NVARCHAR(201)
	DECLARE @SettlementPickupStationId INT
	DECLARE @Guides INT
	DECLARE @Station NVARCHAR(100)

	SELECT
		@CourierName = ISNULL(sr.First_Name, '') + ' ' + ISNULL(sr.Last_Name, '')
	   ,@SettlementPickupStationId = IdSettlementPickupStation
	FROM SenderReceiver sr
	JOIN SettlementPickupStation sps
		ON sps.CouriermanId = sr.ID
	WHERE sr.Phone LIKE '%'+@Phone+'%'
		AND sps.TransactionDate = CAST(GETDATE() AS DATE)
		AND sps.RowStatus = 'TRUE'

	IF @SettlementPickupStationId IS NOT NULL
	BEGIN
	
		SET @Guides = (SELECT
				COUNT(1)
			FROM SettlementPickupStationDetail spsd
			JOIN ServiceManagement sm
				ON sm.IdServiceManagement = spsd.ServiceManagementId
			JOIN SchedulePickup sp
				ON sp.SchedulePickupId = sm.IdSchedulePickup
			JOIN DeliveryOrderPaymentDetail dopd
				ON dopd.IdHeaderRecolection = sp.SchedulePickupId
			WHERE spsd.SettlementPickupStationId = @SettlementPickupStationId
				AND spsd.RowStatus = 'TRUE'
				AND spsd.TokenSettlement IS NULL) --No liquidado

		SET @Station = (SELECT TOP 1
				vp.DescriptionOfClient
		FROM CatStation cs
		JOIN VisitPointClient vp
			ON vp.CodeOfReference = cs.CodeOfReference
		WHERE cs.IdStation = @StationId)

		SELECT 
			sps.IdSettlementPickupStation Id
			,sps.TransactionDate DateRoute
			,@CourierName CourierName
			,cr.CodeRoute CodeRoute
			,CONVERT(NVARCHAR,lbt.SSN_IdUser) + ' - ' + lbt.SSN_Username as IdUser_Username_Received
			,GETDATE() DatePrinted
			,@Guides Guides
			,ISNULL(@Station,'') Station
		FROM SettlementPickupStation sps
		JOIN DenariusUser_Dev.dbo.LGN_LogByToken lbt ON lbt.SSN_IdToken = sps.TokenCreated
		JOIN CatRoute cr ON cr.IdRoute = sps.RouteId
		WHERE sps.IdSettlementPickupStation = @SettlementPickupStationId

	END
END
GO

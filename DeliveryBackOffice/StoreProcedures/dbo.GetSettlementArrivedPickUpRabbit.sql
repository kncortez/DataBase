USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[GetSettlementArrivedPickUpRabbit]    Script Date: 21/03/2022 09:27:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-03-17>
-- Description:	<Obtiene encabezado para manifiesto de recolección Rabbit>
-- =============================================
ALTER PROCEDURE [dbo].[GetSettlementArrivedPickUpRabbit]
	-- Add the parameters for the stored procedure here
	@Phone NVARCHAR(50),
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
			JOIN DeliveryOrder do
				ON do.Guide_Serie = dopd.GuideSerie
				AND do.Guide_Number = dopd.GuideNumber
			WHERE spsd.SettlementPickupStationId = @SettlementPickupStationId
				AND spsd.RowStatus = 'TRUE'
				AND spsd.SettlementSequence = @SettlementSequence
				AND spsd.TokenSettlement IS NOT NULL --Liquidado
				AND do.StatusOrderId = 20)
				
		
		SET @Station = (SELECT TOP 1
				vp.DescriptionOfClient
			FROM SettlementPickupStationDetail spsd
			JOIN VisitPointClient vp
				ON vp.CodeOfReference = spsd.SettlementStationId
			WHERE spsd.SettlementSequence = @SettlementSequence)

		SELECT 
			@SettlementSequence Id
			,sps.TransactionDate DateRoute
			,@CourierName CourierName
			,cr.CodeRoute CodeRoute
			,CONVERT(NVARCHAR,lbt.SSN_IdUser) + ' - ' + lbt.SSN_Username as IdUser_Username_Received
			,GETDATE() DatePrinted
			,ISNULL(@Guides,0) Guides
			,ISNULL(@Station,'') Station
		FROM SettlementPickupStation sps
		JOIN DenariusUser_Dev.dbo.LGN_LogByToken lbt ON lbt.SSN_IdToken = sps.TokenCreated
		JOIN CatRoute cr ON cr.IdRoute = sps.RouteId
		WHERE sps.IdSettlementPickupStation = @SettlementPickupStationId

	END
END
GO

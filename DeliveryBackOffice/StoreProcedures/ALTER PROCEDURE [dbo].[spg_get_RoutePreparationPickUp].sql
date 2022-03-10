USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spg_get_RoutePreparationPickUp]    Script Date: 10/03/2022 09:43:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Abner, Juarez>
-- Create date: <2020-02-10>
-- Description:	<Devuelve información para preparación de ruta>
-- =============================================
ALTER PROCEDURE [dbo].[spg_get_RoutePreparationPickUp]
		@datePickUp AS date = ''
AS
BEGIN
	DECLARE @TempPrice TABLE(	
		GuideSerie			NVARCHAR (25) NULL,
		GuideNumber			NVARCHAR (25) NULL,
		IsCollect			NVARCHAR (25) NULL,
		Price				DECIMAL (14,2) NULL,
		COD					DECIMAL (14,2) NULL,
		AmountPaid			DECIMAL (14,2) NULL,
		CODPaid				DECIMAL (14,2) NULL,
		CODIsPaid			DECIMAL (14,2) NULL,
		PaymentTime			INT NULL,
		TimeSequence		INT NULL,
		FelNumber			NVARCHAR (50) NULL,
		IsPaid				INT NULL,
		IsCustomer			INT NULL,
		ConditionPayment	NVARCHAR(200) NULL,
		HaveCredit			NVARCHAR (50) NULL,
		CollectCOD			NVARCHAR (50) NULL,
		ReturnRate			DECIMAL (14,2) NULL,
		AmountToPay			DECIMAL (14,2) NULL,
		CODAmount			DECIMAL (14,2) NULL,
		ReturnRates			DECIMAL (14,2) NULL
	)

	DECLARE @tbl TABLE (	
		Periodicy NVARCHAR(50) NULL,
		idSchedulePickUp INT NULL,
		Name VARCHAR(200) NULL,
		Address VARCHAR(500) NULL,
		Phone VARCHAR(50) NULL,
		StartDate DATETIME NULL,
		EndDate DATETIME NULL,
		datePickUp VARCHAR(10) NULL,
		hourPickUp VARCHAR(10) NULL,
		rangeHour VARCHAR(23) NULL,
		QuantityRegularPackages INT NULL,
		QuantityOverDimensionedPackage INT NULL,
		EstimatedWeight DECIMAL NULL,
		IdHubLogistics INT NULL,
		HubAbbreviation VARCHAR(5) NULL,
		NameTownship NVARCHAR(100) NULL,
		NameProvince NVARCHAR(100) NULL,
		TypeService VARCHAR(3) NULL,
		SchedulePickupStatus BIT NULL,
		GuideSerie NVARCHAR(2) NULL,
		GuideNumber INT NULL
	)

	INSERT INTO @tbl
	SELECT
		'Demanda' Periodicy
	   ,SchedulePickupId 'idSchedulePickUp'
	   ,SenderName 'Name'
	   ,AddressPickup 'Address'
	   ,SenderPhone 'Phone'
	   ,shp.StartDate
	   ,shp.EndDate
	   ,CONVERT(VARCHAR(10), shp.StartDate, 105) AS datePickUp
	   ,CONVERT(VARCHAR(10), shp.StartDate, 108) AS hourPickUp
	   ,CONCAT(CONVERT(VARCHAR(10), shp.StartDate, 108), '   ', CONVERT(VARCHAR(10), shp.EndDate, 108)) AS rangeHour
	   ,QuantityRegularPackages
	   ,QuantityOverDimensionedPackage
	   ,EstimatedWeight
	   ,IdHubLogistics
	   ,hub.HubAbbreviation
	   ,(CASE
			WHEN dro.Sender_Town IS NOT NULL THEN dro.Sender_Town
			WHEN shp.TownshipId IS NOT NULL THEN twnT.TownshipName
			ELSE ''
		END) AS NameTownship
	   ,(CASE
			WHEN dro.Sender_Department IS NOT NULL THEN dro.Sender_Department
			WHEN shp.TownshipId IS NOT NULL THEN prv.ProvinceName
			ELSE ''
		END) AS NameProvince
	   ,(CASE
			WHEN dro.TypeService IS NOT NULL THEN dro.TypeService
			ELSE ''
		END) AS TypeService
	   ,ISNULL(SchedulePickupStatus, 'True') SchedulePickupStatus
	   ,dop.GuideSerie
	   ,dop.GuideNumber
	FROM DeliveryBackOffice.dbo.SchedulePickup AS shp
	LEFT JOIN [DeliveryBackOffice].[dbo].[HubLogistics] AS hub
		ON IdHubLogistics = hub.IdHubLogistic
	LEFT JOIN [DeliveryBackOffice].[dbo].[Township] twnT
		ON shp.TownshipId = twnT.IdTownship
	LEFT JOIN [DeliveryBackOffice].[dbo].[Province] prv
		ON prv.IdProvince = twnT.IdProvince
	LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] dop
		ON dop.IdHeaderRecolection = shp.SchedulePickupId
	LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrder AS dro
		ON dro.Guide_Number = dop.GuideNumber
			AND dro.Guide_Serie = dop.GuideSerie
	WHERE ((@datePickUp >= CONVERT(DATE, shp.startDate)
	AND CONVERT(DATE, shp.EndDate) >= @datePickUp)
	OR (@datePickUp = ''))
	AND ((AssigmentStatus = 0)
	OR (AssigmentStatus IS NULL))
	AND RowStatus = 1
	
	DECLARE @guides nvarchar (MAX) = ( SELECT
			STUFF((SELECT DISTINCT
					',' + CONCAT(GuideSerie, GuideNumber)
				FROM @tbl
				GROUP BY GuideSerie
						,GuideNumber
				FOR XML PATH (''))
			, 1, 1, ''))

	INSERT INTO @TempPrice (GuideSerie, GuideNumber, IsCollect, Price, COD, AmountPaid, CODPaid
	, CODIsPaid, PaymentTime, TimeSequence, FelNumber, IsPaid, IsCustomer
	, ConditionPayment, HaveCredit, CollectCOD, ReturnRate, AmountToPay, CODAmount, ReturnRates)
	EXEC [dbo].[spws_get_guide_pending_payment] @InGuides = @guides
											   ,@InTime = 2
											   ,@IsReturn = 'FALSE'
											   ,@CodeApp = 'SIFDCECOM300720201459'
											   ,@IdModule = 1
											   ,@Token = 'SYSTEM'

	SELECT
		tb.Periodicy
		,tb.idSchedulePickUp
		,tb.Name
		,tb.Address
		,tb.Phone
		,tb.StartDate
		,tb.EndDate
		,tb.datePickUp
		,tb.hourPickUp
		,tb.rangeHour
		,tb.QuantityRegularPackages
		,tb.QuantityOverDimensionedPackage
		,tb.EstimatedWeight
		,tb.IdHubLogistics
		,tb.HubAbbreviation
		,tb.NameTownship
		,tb.NameProvince
		,tb.TypeService
		,tb.SchedulePickupStatus
		,ISNULL(tp.AmountToPay,0) Amount
	FROM @tbl tb
	LEFT JOIN @TempPrice tp
		ON tp.GuideSerie = tb.GuideSerie
		AND tp.GuideNumber = tb.GuideNumber
	ORDER BY StartDate ASC
END
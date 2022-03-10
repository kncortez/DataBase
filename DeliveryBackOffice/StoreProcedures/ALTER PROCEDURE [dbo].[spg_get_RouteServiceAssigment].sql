USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spg_get_RouteServiceAssigment]    Script Date: 10/03/2022 11:40:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Abner, Juarez>
-- Create date: <2020-02-13>
-- Description:	<Obtiene las rutas con servicios ya asignados>
-- =============================================
ALTER PROCEDURE [dbo].[spg_get_RouteServiceAssigment]
		@idRoute AS int,
		@dateRoute AS date
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

	DECLARE @tbl TABLE(
		SchedulePickupId BIGINT NULL,
		Name VARCHAR(200) NULL,
		Address VARCHAR(500) NULL,
		Phone VARCHAR(50) NULL,
		rangeHour VARCHAR(23) NULL,
		QuantityRegularPackages INT NULL,
		QuantityOverDimensionedPackage INT NULL,
		NameCourrier NVARCHAR(201) NULL,
		NameStatus NVARCHAR(100) NULL,
		GuideSerie NVARCHAR(2) NULL,
		GuideNumber INT NULL
	)

	INSERT INTO @tbl
	SELECT
		spu.SchedulePickupId
		,spu.SenderName [Name]
		,spu.AddressPickup [Address]
		,spu.SenderPhone [Phone]
		,CONCAT(CONVERT(VARCHAR(10), spu.StartDate, 108), '   ', CONVERT(VARCHAR(10), spu.EndDate, 108)) AS rangeHour
		,spu.QuantityRegularPackages
		,spu.QuantityOverDimensionedPackage
		,CONCAT(snr.First_Name, ' ', snr.Last_Name) AS NameCourrier
		,css.Name AS NameStatus
		,dopd.GuideSerie
		,dopd.GuideNumber
	FROM SchedulePickup AS spu
	JOIN ServiceManagement AS smt
		ON spu.SchedulePickupId = smt.IdSchedulePickup
	JOIN RouteAssigment AS rat
		ON smt.IdPuRouteAssigment = rat.IdRouteAssigment
	LEFT JOIN SenderReceiver AS snr
		ON rat.IdCurrierMan = snr.ID
	LEFT JOIN CatServiceStatus AS css
		ON css.IdServiceStatus = smt.ServiceStatusId
	LEFT JOIN DeliveryOrderPaymentDetail dopd
		ON dopd.IdHeaderRecolection = spu.SchedulePickupId
	WHERE rat.IdRoute = @idRoute
	AND rat.DateOfRoute = @dateRoute
	AND spu.AssigmentStatus = '1'

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
		tb.SchedulePickupId
	   ,tb.Name
	   ,tb.Address
	   ,tb.Phone
	   ,tb.rangeHour
	   ,tb.QuantityRegularPackages
	   ,tb.QuantityOverDimensionedPackage
	   ,tb.NameCourrier
	   ,tb.NameStatus
	   ,SUM(ISNULL(tp.AmountToPay, 0)) Amount
	FROM @tbl tb
	LEFT JOIN @TempPrice tp
		ON tp.GuideSerie = tb.GuideSerie
			AND tp.GuideNumber = tb.GuideNumber
	GROUP BY tb.SchedulePickupId
			,tb.Name
			,tb.Address
			,tb.Phone
			,tb.rangeHour
			,tb.QuantityRegularPackages
			,tb.QuantityOverDimensionedPackage
			,tb.NameCourrier
			,tb.NameStatus
END
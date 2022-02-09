USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spg_get_RoutePreparationPickUp]    Script Date: 8/02/2022 15:38:31 ******/
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

		SELECT  'Demanda' Periodicy
			,SchedulePickupId 'idSchedulePickUp'
			,SenderName 'Name'
			,AddressPickup 'Address'
			,SenderPhone 'Phone'
			,shp.StartDate
			,shp.EndDate
			,CONVERT(varchar(10), shp.StartDate, 105) as datePickUp
			,CONVERT(varchar(10), shp.StartDate, 108) as hourPickUp
			,CONCAT(CONVERT(varchar(10), shp.StartDate, 108), '   ', CONVERT(varchar(10), shp.EndDate, 108)) as rangeHour
			,QuantityRegularPackages
			,QuantityOverDimensionedPackage
			,EstimatedWeight
			,IdHubLogistics
			,hub.HubAbbreviation
			,(case when dro.Sender_Town is not null then dro.Sender_Town when shp.TownshipId is not null then twnT.TownshipName else ''  end ) as NameTownship
			,(case when dro.Sender_Department is not null then dro.Sender_Department when shp.TownshipId is not null then prv.ProvinceName else ''  end ) as NameProvince
			,(case when dro.TypeService is not null then dro.TypeService else ''end ) as TypeService
            ,ISNULL(SchedulePickupStatus, 'True') SchedulePickupStatus
		FROM DeliveryBackOffice.dbo.SchedulePickup as shp
		LEFT JOIN [DeliveryBackOffice].[dbo].[HubLogistics] as hub on IdHubLogistics = hub.IdHubLogistic
		LEFT JOIN [DeliveryBackOffice].[dbo].[Township] twnT ON shp.TownshipId=twnT.IdTownship
		LEFT JOIN [DeliveryBackOffice].[dbo].[Province] prv ON prv.IdProvince=twnT.IdProvince
		LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] dop on dop.IdHeaderRecolection=shp.SchedulePickupId
		LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrder as dro ON dro.Guide_Number = dop.GuideNumber and dro.Guide_Serie=dop.GuideSerie
		WHERE ((@datePickUp >= Convert(DATE, shp.startDate) AND Convert(DATE,shp.EndDate) >= @datePickUp) OR (@datePickUp = '')) AND ((AssigmentStatus = 0) OR (AssigmentStatus IS NULL)) AND RowStatus = 1
		order by StartDate asc
END

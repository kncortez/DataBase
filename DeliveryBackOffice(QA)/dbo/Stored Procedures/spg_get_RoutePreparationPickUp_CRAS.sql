
-- =============================================
-- Author:		<Abner, Juarez>
-- Create date: <2020-02-10>
-- Description:	<Devuelve información para preparación de ruta>
-- =============================================
-- =============================================
-- Author:		<Andres, Ruiz>
-- Update date: <2020-03-21>
-- Description:	< Adición de WITH(NOLOCK) para evitar bloqueos >
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_RoutePreparationPickUp_CRAS] @datePickUp AS DATE = ''
AS
BEGIN


	DECLARE @datePickUp_internal DATE =@datePickUp
    SELECT 'Demanda' Periodicy,
           SchedulePickupId 'idSchedulePickUp',
           SenderName 'Name',
           AddressPickup 'Address',
           ISNULL(Sender_Zone, '0') Zone,
           SenderPhone 'Phone',
           shp.StartDate,
           shp.EndDate,
           CONVERT(VARCHAR(10), shp.StartDate, 105) AS datePickUp,
           CONVERT(VARCHAR(10), shp.StartDate, 108) AS hourPickUp,
           CONCAT(CONVERT(VARCHAR(10), shp.StartDate, 108), '   ', CONVERT(VARCHAR(10), shp.EndDate, 108)) AS rangeHour,
           QuantityRegularPackages,
           QuantityOverDimensionedPackage,
           EstimatedWeight,
           IdHubLogistics,
           hub.HubAbbreviation,
           (CASE
                WHEN dro.Sender_Town IS NOT NULL THEN
                    dro.Sender_Town
                WHEN shp.TownshipId IS NOT NULL THEN
                    twnT.TownshipName
                ELSE
                    ''
            END
           ) AS NameTownship,
           (CASE
                WHEN dro.Sender_Department IS NOT NULL THEN
                    dro.Sender_Department
                WHEN shp.TownshipId IS NOT NULL THEN
                    prv.ProvinceName
                ELSE
                    ''
            END
           ) AS NameProvince,
           (CASE
                WHEN dro.TypeService IS NOT NULL THEN
                    dro.TypeService
                ELSE
                    ''
            END
           ) AS TypeService,
           ISNULL(SchedulePickupStatus, 'True') SchedulePickupStatus,
           dop.GuideSerie,
           dop.GuideNumber,
           ISNULL(ctv.Name, '') ServiceVehicle
    FROM DeliveryBackOffice.dbo.SchedulePickup AS shp WITH (NOLOCK)
        LEFT JOIN [DeliveryBackOffice].[dbo].[HubLogistics] AS hub WITH (NOLOCK)
            ON IdHubLogistics = hub.IdHubLogistic
        LEFT JOIN [DeliveryBackOffice].[dbo].[Township] twnT WITH (NOLOCK)
            ON shp.TownshipId = twnT.IdTownship
        LEFT JOIN [DeliveryBackOffice].[dbo].[Province] prv WITH (NOLOCK)
            ON prv.IdProvince = twnT.IdProvince
        LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] dop WITH (NOLOCK)
            ON dop.IdHeaderRecolection = shp.SchedulePickupId
        LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrder AS dro WITH (NOLOCK)
            ON dro.Guide_Number = dop.GuideNumber
               AND dro.Guide_Serie = dop.GuideSerie
        LEFT JOIN [DeliveryBackOffice].[dbo].[CatTypeVehicle] ctv WITH (NOLOCK)
            ON shp.TypeVehicleId = ctv.IdTypeVehicle
	
    WHERE 
	@datePickUp_internal BETWEEN CONVERT(DATE, shp.StartDate) AND CONVERT( DATE, shp.EndDate)
	AND shp.AssigmentStatus IS NULL
          AND shp.RowStatus = 1

	--OPTION (OPTIMIZE FOR UNKNOWN)

END;
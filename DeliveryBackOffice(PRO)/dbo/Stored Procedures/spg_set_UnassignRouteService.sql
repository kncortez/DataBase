
-- =============================================
-- Author:		<Abner, Juarez>
-- Create date: <2020-02-15>
-- Description:	<Desasignación de un servicio a una ruta>
-- =============================================
-- =============================================
-- Author:		<Andres,Ruiz>
-- Update date: <2022-02-21>
-- Description:	< Adición de WITH(NOLOCK) para evitar posibles bloqueos >
-- =============================================
CREATE PROCEDURE [dbo].[spg_set_UnassignRouteService]
    @idSchedulePickup AS INT,
    @token AS VARCHAR(50),
    @IdRoute INT,
    @DateRoute DATE
AS
BEGIN

    BEGIN TRANSACTION;
    BEGIN TRY

        DECLARE @ServiceManagementId INT =
                (
                    SELECT IdServiceManagement
                    FROM ServiceManagement
                    WHERE IdSchedulePickup = @idSchedulePickup
                );

        IF @ServiceManagementId IS NOT NULL
        BEGIN

            UPDATE [DeliveryBackOffice].[dbo].[ServiceManagement]
            SET IdPuCourrier = NULL,
                IdPuRouteAssigment = NULL,
                ServiceStatusId = 1,
                Amount = 0
            WHERE IdSchedulePickup = @idSchedulePickup;
            UPDATE [DeliveryBackOffice].[dbo].[SchedulePickup]
            SET AssigmentStatus = 0
            WHERE SchedulePickupId = @idSchedulePickup;

            INSERT INTO [DeliveryBackOffice].[dbo].[EventService]
            (
                ServiceManagementId,
                ServiceStatusId,
                RowStauts,
                TokenCreated,
                DateCreated
            )
            VALUES
            (@ServiceManagementId, 1, 1, @token, GETDATE());

            --Desactivar el servicio si es una ruta de Rabbit
            IF
            (
                SELECT CodeRoute FROM CatRoute WHERE IdRoute = @IdRoute
            ) LIKE '%RABBIT%'
            BEGIN
                UPDATE spsd
                SET spsd.RowStatus = 'FALSE',
                    spsd.TokenUpdated = @token,
                    spsd.DateUpdated = GETDATE()
                FROM SettlementPickupStationDetail spsd
                    JOIN SettlementPickupStation sps
                        ON sps.IdSettlementPickupStation = spsd.SettlementPickupStationId
                WHERE sps.RouteId = @IdRoute
                      AND sps.TransactionDate = @DateRoute
                      AND spsd.ServiceManagementId = @ServiceManagementId
                      AND sps.RowStatus = 'TRUE'
                      AND spsd.RowStatus = 'TRUE';
            END;
        END;

        IF (@@TRANCOUNT > 0) COMMIT TRANSACTION;

        SELECT 1 [blnResult],
               'Datos registrados correctamente' 'Description';

        --Datos del schedulepickup
        SELECT 'Demanda' Periodicy,
               SchedulePickupId idSchedulePickUp,
               SenderName 'Name',
               AddressPickup 'Address',
               ISNULL(dop_group.Sender_Zone, '0') Zone,
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
                    WHEN dop_group.Sender_Town IS NOT NULL THEN
                        dop_group.Sender_Town
                    WHEN shp.TownshipId IS NOT NULL THEN
                        twnT.TownshipName
                    ELSE
                        ''
                END
               ) AS NameTownship,
               (CASE
                    WHEN dop_group.Sender_Department IS NOT NULL THEN
                        dop_group.Sender_Department
                    WHEN shp.TownshipId IS NOT NULL THEN
                        prv.ProvinceName
                    ELSE
                        ''
                END
               ) AS NameProvince,
               (CASE
                    WHEN dop_group.TypeService IS NOT NULL THEN
                        dop_group.TypeService
                    ELSE
                        ''
                END
               ) AS TypeService,
               ISNULL(SchedulePickupStatus, 'True') SchedulePickupStatus,
               ISNULL(ctv.Name, '') ServiceVehicle,
               --, ISNULL(srv.Amount,0)
               dop_group.TimePlaId ServiceVehicle,
               --,css.[Name] StatusName
               srv.IdServiceManagement
        FROM DeliveryBackOffice.dbo.SchedulePickup AS shp WITH (NOLOCK)
            LEFT JOIN [DeliveryBackOffice].[dbo].[HubLogistics] AS hub WITH (NOLOCK)
                ON IdHubLogistics = hub.IdHubLogistic
            LEFT JOIN [DeliveryBackOffice].[dbo].[Township] twnT WITH (NOLOCK)
                ON shp.TownshipId = twnT.IdTownship
            LEFT JOIN [DeliveryBackOffice].[dbo].[Province] prv WITH (NOLOCK)
                ON prv.IdProvince = twnT.IdProvince
            LEFT JOIN
            (
                SELECT TimePlaId,
                       IdHeaderRecolection,
                       drosub.Sender_Town,
                       drosub.Sender_Department,
                       drosub.TypeService,
                       drosub.Sender_Zone
                FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] dopsub
                    LEFT JOIN dbo.DeliveryOrder drosub
                        ON drosub.Guide_Number = dopsub.GuideNumber
                WHERE IdHeaderRecolection = @idSchedulePickup
                GROUP BY TimePlaId,
                         IdHeaderRecolection,
                         drosub.Sender_Town,
                         drosub.Sender_Department,
                         drosub.TypeService,
                         drosub.Sender_Zone
            ) dop_group
                ON dop_group.IdHeaderRecolection = shp.SchedulePickupId
            --LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrder AS dro WITH (NOLOCK)
            --ON dro.Guide_Number = dop.GuideNumber
            --AND dro.Guide_Serie = dop.GuideSerie
            LEFT JOIN [DeliveryBackOffice].[dbo].[CatTypeVehicle] ctv WITH (NOLOCK)
                ON shp.TypeVehicleId = ctv.IdTypeVehicle
            LEFT JOIN dbo.ServiceManagement srv
                ON srv.IdSchedulePickup = shp.SchedulePickupId
            LEFT JOIN [DeliveryBackOffice].[dbo].[CatServiceStatus] AS css WITH (NOLOCK)
                ON css.IdServiceStatus = srv.ServiceStatusId
        WHERE SchedulePickupId = @idSchedulePickup;

    END TRY
    BEGIN CATCH

        SELECT 0 [blnResult],
               ERROR_NUMBER() AS [ErrorNumber],
               ERROR_SEVERITY() AS [ErrorSeverity],
               ERROR_STATE() AS [ErrorState],
               ERROR_PROCEDURE() AS [ErrorProcedure],
               ERROR_LINE() AS [ErrorLine],
               ERROR_MESSAGE() AS [ErrorMessage];

        ROLLBACK TRANSACTION;
    END CATCH;
END;
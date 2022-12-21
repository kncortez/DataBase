
-- =============================================
-- Author:		<Alberto Ixchop>
-- Create date: <22-09-2022>
-- Description:	<Método para carga de servicios pendientes de procesar filtrado por hubs y rango de fechas>
-- =============================================
CREATE PROCEDURE [dbo].[sphw_GetPendingRecollectionServices]
    @HubId INT = -1,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL,
    @IdUser INT = -1
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @RefClientId INT =
            (
                SELECT TOP 1
                       Cu.IdCustomer
                FROM [DeliveryBackOffice].[dbo].[Account] Acc WITH (NOLOCK)
                    INNER JOIN [DeliveryBackOffice].[dbo].[Customer] Cu WITH (NOLOCK)
                        ON Acc.IdCustomer = Cu.IdCustomer
                WHERE Cu.[Name] = 'Cliente Referenciado' COLLATE Latin1_General_CI_AI
            );

    IF OBJECT_ID('tempdb.dbo.#ServiceAlert', 'U') IS NOT NULL
        DROP TABLE #ServiceAlert;

    CREATE TABLE #ServiceAlert
    (
        IdServiceManagement INT,
        IsAlerted BIT
    );
    CREATE NONCLUSTERED INDEX TMPINDX_ServiceAlert_Service
    ON #ServiceAlert (IdServiceManagement);

    BEGIN TRY
        IF @StartDate IS NULL
            SET @StartDate = GETDATE();
        IF @EndDate IS NULL
            SET @EndDate = GETDATE();

        INSERT INTO #ServiceAlert
        (
            IdServiceManagement,
            IsAlerted
        )
        SELECT DISTINCT
               DOA.ServiceManagementId,
               1
        FROM [DeliveryBackOffice].[dbo].[DeliveryOrderAlert] DOA WITH (NOLOCK)
        WHERE DOA.ServiceManagementId IS NOT NULL
              AND DOA.RowStatus = 1;

        SELECT 1 AS 'StatusCode',
               'Registros obtenidos' AS 'Description';

        SELECT DISTINCT
               ISNULL(shp.ServiceRate, 0) 'Qualification',
               srv.IdServiceManagement 'IdServiceManagement',
               CONCAT(CONVERT(VARCHAR(10), shp.DateCreated, 105), ' ', CONVERT(VARCHAR(10), shp.DateCreated, 108)) 'datecreated',
               CONVERT(VARCHAR(10), shp.StartDate, 105) 'datePickUp',
               CONVERT(VARCHAR(10), shp.StartDate, 108) 'hourPickUp',
               ISNULL(ctv.Name, '') 'ServiceVehicle',
               ISNULL(shp.IsScheduled, 1) 'IsScheduled',
               ISNULL(shp.QuantityRegularPackages, 0) 'QuantityRegularPackages',
               ISNULL(shp.QuantityOverDimensionedPackage, 0) 'QuantityOverDimensionedPackage',
               css.[Name] StatusName,
               ISNULL(shp.AddressPickup, vpc.Address) 'OriginAddress',
               vpc.DescriptionOfClient 'OriginAddressName',
               vpc.Department 'OriginAddressProvince',
               vpc.Town 'OriginAddressTown',
               CONCAT(CONVERT(VARCHAR(10), shp.StartDate, 108), '   ', CONVERT(VARCHAR(10), shp.EndDate, 108)) 'rangeHour',
               ISNULL(SPHUB.IdHubLogistic, hub.IdHubLogistic) 'IdHubLogistic',
               ISNULL(SPHUB.HubAbbreviation, hub.HubAbbreviation) 'HubAbbreviation',
               (CASE
                    WHEN Cu.IdCustomer = @RefClientId THEN
                        vpc.DescriptionOfClient
                    ELSE
                        ISNULL(Cu.[Name], shp.SenderName)
                END
               ) 'FirstName',
               '' 'LastName',
               ISNULL(shp.IsScheduled, 1) 'Scheduled',
               RA.IdCurrierMan 'CurrierManId',
               ISNULL(RA.IdRoute, -1) 'IdRoute',
               RA.IdRouteAssigment 'IdRouteAssigment',
               SNR.First_Name 'CurrierFirstName',
               SNR.Last_Name 'Last_Name',
               vpc.Latitude 'Latitude',
               vpc.Longitude 'Longitude',
               ISNULL(SA.IsAlerted, 0) 'IsAlerted'
        FROM DeliveryBackOffice.dbo.SchedulePickup AS shp WITH (NOLOCK)
            LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpc WITH (NOLOCK)
                ON shp.SenderId = vpc.CodeOfReference
                   AND shp.SenderId != 0
            LEFT JOIN [DeliveryBackOffice].[dbo].[Township] TwnTvpc WITH (NOLOCK)
                ON vpc.IdTownship = TwnTvpc.IdTownship
            LEFT JOIN [DeliveryBackOffice].[dbo].[Township] twnT WITH (NOLOCK)
                ON shp.TownshipId = twnT.IdTownship
            LEFT JOIN
            (
                SELECT DSCAux.HeaderCode,
                       HL.IdHubLogistic,
                       MAX(DSCAux.Hub) 'HubAbbreviation'
                FROM [DeliveryBackOffice].[dbo].[DumpServiceCoverage] DSCAux WITH (NOLOCK)
                    INNER JOIN dbo.HubLogistics HL WITH (NOLOCK)
                        ON HL.HubAbbreviation = DSCAux.Hub
                WHERE DSCAux.RowStatus = 1
                      AND HL.HubStatus = 1
                GROUP BY DSCAux.HeaderCode,
                         HL.IdHubLogistic
            ) hub
                ON ISNULL(twnT.HeaderCode, TwnTvpc.HeaderCode) = hub.HeaderCode
            LEFT JOIN [DeliveryBackOffice].[dbo].[CatTypeVehicle] ctv WITH (NOLOCK)
                ON shp.TypeVehicleId = ctv.IdTypeVehicle
            LEFT JOIN dbo.ServiceManagement srv
                ON srv.IdSchedulePickup = shp.SchedulePickupId
            LEFT JOIN [DeliveryBackOffice].[dbo].[CatServiceStatus] AS css WITH (NOLOCK)
                ON css.IdServiceStatus = srv.ServiceStatusId
            ------------------------------------------------------------------------
            --FOR CLIENT DATA 
            LEFT JOIN [DeliveryBackOffice].[dbo].[Customer] Cu WITH (NOLOCK)
                ON Cu.IdCustomer = vpc.CustomerID
            ------------------------------------------------------------------------------------
            --COURIER ASIGNADO
            LEFT JOIN [DeliveryBackOffice].[dbo].RouteAssigment RA WITH (NOLOCK)
                ON RA.IdRouteAssigment = srv.IdPuRouteAssigment
            LEFT JOIN [DeliveryBackOffice].[dbo].SenderReceiver SNR WITH (NOLOCK)
                ON SNR.ID = RA.IdCurrierMan
            ------------------------------------------------------------------------------------
            --USUARIO POR HUB ASIGNADO
            INNER JOIN [DeliveryBackOffice].[dbo].HubLogisticByUser HLBU WITH (NOLOCK)
                ON HLBU.HubLogisticId = ISNULL(shp.IdHubLogistics, hub.IdHubLogistic)
            ------------------------------------------------------------------------------------
            LEFT JOIN dbo.HubLogistics SPHUB WITH (NOLOCK)
                ON shp.IdHubLogistics = SPHUB.IdHubLogistic
            ------------------------------------------------------------------------------------
            --INCIDENCIA
            LEFT JOIN
            (
                SELECT INSRV.ServiceManagementId
                FROM [DeliveryBackOffice].[dbo].IncidenceServices INSRV WITH (NOLOCK)
                GROUP BY ServiceManagementId
            ) INSRV
                ON INSRV.ServiceManagementId = srv.IdServiceManagement
            LEFT JOIN #ServiceAlert SA
                ON srv.IdServiceManagement = SA.IdServiceManagement
        WHERE CONVERT(DATE, shp.StartDate) >= @StartDate
              AND CONVERT(DATE, shp.StartDate) <= @EndDate
              AND shp.RowStatus = 1
              --AND (
              --	@HubId = -1 
              --	OR (SPHUB.IdHubLogistic IS NOT NULL AND SPHUB.IdHubLogistic= @HubId)
              --	OR (HUB.IdHubLogistic IS NULL AND HUB.IdHubLogistic = @HubId)
              --)
              AND
              (
                  @IdUser = -1
                  OR HLBU.UserId = @IdUser
              )
              AND
            ------------------------------------------------------------------------
            --FILTRO DE SERVICIO PENDINETE (ESTADO VALIDO Y SIN INCIDENCIA)
            srv.ServiceStatusId IN
            (
                SELECT IdServiceStatus
                FROM dbo.CatServiceStatus
                WHERE Name IN ( 'Creado', 'Asignado a Ruta', 'Reprogramado' )
            )
              AND INSRV.ServiceManagementId IS NULL --No posee ninguna incidencia registrada
        ------------------------------------------------------------------------
        ORDER BY ISNULL(SA.IsAlerted, 0) DESC,
                 CONCAT(CONVERT(VARCHAR(10), shp.DateCreated, 105), ' ', CONVERT(VARCHAR(10), shp.DateCreated, 108)) DESC;

    END TRY
    BEGIN CATCH

        SELECT 0 AS 'StatusCode',
               ERROR_MESSAGE() AS 'Description';
    END CATCH;

    IF OBJECT_ID('tempdb.dbo.#ServiceAlert', 'U') IS NOT NULL
        DROP TABLE #ServiceAlert;

END;
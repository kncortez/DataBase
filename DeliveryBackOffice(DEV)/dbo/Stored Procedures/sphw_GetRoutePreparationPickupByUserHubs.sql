

-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-10-21>
-- Description:	<Devuelve todas las recolecciones de un usuario interno filtradas por fecha, y posiblemente identificador de courier>
-- =============================================
CREATE PROCEDURE [dbo].[sphw_GetRoutePreparationPickupByUserHubs]
	@TargetDate AS DATE = NULL, --Fecha inicio de filtro
	@userId BIGINT = NULL,
	@CourierId INT = NULL

AS
BEGIN
    SET ARITHABORT ON;
	----------------------------------------------------------------------------
	IF @TargetDate IS NULL --COMPRUEBA FECHA DE INICIO DE FILTRO Ó SI LA FECHA DE INICIO NO FUÉ ESPECIFICADO
	BEGIN
		SET @TargetDate = CAST(GETDATE() AS DATE);
	END
	----------------------------------------------------------------------------

	SELECT 1 'StatusCode', 
			'Registros obtenidos'	'Description';
	--INSERT INTO @tbl
	SELECT 
		shp.ServiceRate 'Qualification',
		srv.IdServiceManagement 'IdServiceManagement',
		CONCAT(CONVERT(VARCHAR(10), shp.StartDate, 103), ' ', CONVERT(VARCHAR(10), shp.StartDate, 108)) 'datecreated',
		hl.HubAbbreviation 'hub',
		RTRIM(LTRIM(CONCAT(sr.First_Name, ' ', sr.Last_Name))) 'courier',
		CONVERT(   VARCHAR(10),
		(
			SELECT TOP 1
					ES.DateCreated
			FROM [DeliveryBackOffice].[dbo].[EventService] ES WITH (NOLOCK)
			WHERE ES.ServiceManagementId = srv.IdServiceManagement
					AND ES.ServiceStatusId = 1
					AND ES.RowStauts = 3
			ORDER BY ES.DateCreated DESC
		),
					103
				) 'datePickUp',
		CONVERT(   VARCHAR(10),
		(
			SELECT TOP 1
					ES.DateCreated
			FROM [DeliveryBackOffice].[dbo].[EventService] ES WITH (NOLOCK)
			WHERE ES.ServiceManagementId = srv.IdServiceManagement
					AND ES.ServiceStatusId = 1
					AND ES.RowStauts = 3
			ORDER BY ES.DateCreated DESC
		),
					108
				) 'hourPickUp',
		ISNULL(ctv.Name, '') 'ServiceVehicle',
		shp.IsScheduled 'IsScheduled',
		ISNULL(QuantityRegularPackages, 0) 'QuantityRegularPackages',
		ISNULL(QuantityOverDimensionedPackage, 0) 'QuantityOverDimensionedPackage',
		css.[Name] StatusName,
		ISNULL(shp.AddressPickup, vpc.Address) 'OriginAddress',
		ISNULL(vpc.DescriptionOfClient, shp.SenderName) 'OriginAddressName',
		vpc.Department 'OriginAddressProvince',
		vpc.Town 'OriginAddressTown',
		CONCAT(CONVERT(VARCHAR(10), shp.StartDate, 108), '   ', CONVERT(VARCHAR(10), shp.EndDate, 108)) 'rangeHour'
	FROM dbo.RouteAssigment ra WITH(NOLOCK)
		INNER JOIN dbo.SenderReceiver sr WITH(NOLOCK)
			ON sr.ID = ra.IdCurrierMan
		INNER JOIN dbo.HubLogisticByUser hlbu WITH(NOLOCK)
			ON sr.HubLogisticId = hlbu.HubLogisticId
				AND hlbu.UserId = @userId
		INNER JOIN dbo.ServiceManagement srv WITH(NOLOCK)
			ON srv.IdPuRouteAssigment = ra.IdRouteAssigment
			   AND srv.RowStatus = 1
		INNER JOIN dbo.SchedulePickup shp WITH(NOLOCK)
			ON shp.SchedulePickupId = srv.IdSchedulePickup
		LEFT JOIN dbo.HubLogistics hl WITH(NOLOCK)
			ON hl.IdHubLogistic = shp.IdHubLogistics
		LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpc WITH (NOLOCK)
			ON shp.SenderId = vpc.CodeOfReference
				AND shp.SenderId != 0
		LEFT JOIN [DeliveryBackOffice].[dbo].[CatTypeVehicle] ctv WITH (NOLOCK)
			ON shp.TypeVehicleId = ctv.IdTypeVehicle
		LEFT JOIN [DeliveryBackOffice].[dbo].[CatServiceStatus] AS css WITH (NOLOCK)
			ON css.IdServiceStatus = srv.ServiceStatusId
	WHERE 
		RA.DateOfRoute = @TargetDate
		AND
		(ISNULL(@CourierId, -1) = -1 OR RA.IdCurrierMan = @CourierId);

END;
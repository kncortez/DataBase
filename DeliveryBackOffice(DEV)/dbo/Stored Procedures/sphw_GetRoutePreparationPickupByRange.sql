/* =================================================
   SP:        [dbo].[sphw_GetRoutePreparationPickupByRange]
   Propósito: Devuelve todas las recolecciones de un usuario individual filtradas por un rango de fechas, siendo máximo 30 días atras.
   Autor:     Alberto Ixchop
   Historia:  
   Fecha:     2022-09-13
============================================
=== CHANGELOG ================================
2024-08-20	|	Épica: 	|	Autor: Brandon Pedroza    |   Se agrega parametro para filtrar servicios de recoleccion por pais de hub asignado.
=========================================== 
2026-03-26	|	Épica: FDAPI-5958	|	Autor: Erick Guerra    |   Se realizan ajustes en consultas para optimizar resultados.
=========================================== */

CREATE PROCEDURE [dbo].[sphw_GetRoutePreparationPickupByRange]
	@startDate AS DATE = NULL, --Fecha inicio de filtro
	@endDate AS DATE = NULL, --Fecha fin de filtro

	@accountId BIGINT = NULL,
	@userId BIGINT = NULL,
	@serviceManagementId INT = NULL,
	@IdCountry AS NVARCHAR(2) = 'GT'

AS
BEGIN
    SET ARITHABORT ON;
	----------------------------------------------------------------------------
	--INICIO DE VALIDACIÓN DE FECHA PARA FILTRO DE BÚSQUEDA
	DECLARE @DAYSAGO INT = 30; --NÚMERO MÁXIMO DE DÍAS A FILTRAR
	DECLARE @DEFAULDAYSAGO INT = 7; --NÚMERO MAXIMO POR DEFECTO
	DECLARE @MAXDAYTOFILTER DATE = (select DATEADD(dd, DATEDIFF(dd, 0, getdate()), - @DAYSAGO));--OBTENIENDO FECHA MÁXIMA HISTÓRICA DE CONSULTA		
	 
	IF @startDate IS NULL --COMPRUEBA FECHA DE INICIO DE FILTRO Ó SI LA FECHA DE INICIO NO FUÉ ESPECIFICADO
	BEGIN
		SET @startDate = (select DATEADD(dd, DATEDIFF(dd, 0, getdate()), - @DEFAULDAYSAGO));
	END
	ELSE IF @startDate < @MAXDAYTOFILTER 
	BEGIN
		SET @startDate =@MAXDAYTOFILTER;
	END
	
	IF @endDate>getdate() or @endDate IS NULL
	BEGIN 
		SET @endDate = getdate();
	END	 
	--FIN
	----------------------------------------------------------------------------
	DECLARE @ServicePickupStatus INT = (SELECT TOP 1 CSS.IdServiceStatus FROM [DeliveryBackOffice].[dbo].[CatServiceStatus] CSS WITH(NOLOCK) WHERE CSS.Name LIKE 'Recolectado' COLLATE Latin1_General_CI_AI)


	IF (@accountId IS NOT NULL AND ISNULL(@userId,0) = 0)
	BEGIN

		SELECT 1 'StatusCode', 
				'Registros obtenidos'	'Description';
		--INSERT INTO @tbl
		SELECT shp.ServiceRate 'Qualification',
				srv.IdServiceManagement 'IdServiceManagement' , 
			   CONVERT(VARCHAR(10), shp.StartDate, 103) + ' ' + CONVERT(VARCHAR(10), shp.StartDate, 108) AS datecreated,
			   ISNULL(CAST(RA.IdCurrierMan AS NVARCHAR), '') AS courier,
			   CONVERT(VARCHAR(10), es.DateCreated, 103) AS datePickUp,
			   CONVERT(VARCHAR(10), es.DateCreated, 108) AS hourPickUp,
			   ISNULL(ctv.Name, '') 'ServiceVehicle',
			   shp.IsScheduled 'IsScheduled',
			   ISNULL(QuantityRegularPackages,0) 'QuantityRegularPackages',
			   ISNULL(QuantityOverDimensionedPackage,0)'QuantityOverDimensionedPackage',
			   css.[Name] StatusName,
			   ISNULL(vpc.Address, shp.AddressPickup) 'OriginAddress',
			   vpc.DescriptionOfClient 'OriginAddressName',		   
			   vpc.Department 'OriginAddressProvince',
			   vpc.Town 'OriginAddressTown',           
			   CONVERT(VARCHAR(8), shp.StartDate, 108) + '   ' + CONVERT(VARCHAR(10), shp.EndDate, 108) AS rangeHour,
			   hl.HubAbbreviation 'Hub'
		FROM DeliveryBackOffice.dbo.SchedulePickup AS shp WITH (NOLOCK)
			LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpc WITH (NOLOCK)
				ON shp.SenderId = vpc.CodeOfReference
			LEFT JOIN [DeliveryBackOffice].[dbo].[Township] TwnTvpc WITH (NOLOCK)
				ON vpc.IdTownship = TwnTvpc.IdTownship
			INNER JOIN [DeliveryBackOffice].[dbo].[Township] TwnSph  WITH (NOLOCK) -----
				ON TwnSph.IdTownship = shp.TownshipId -------
			INNER JOIN [DeliveryBackOffice].[dbo].[Province] PrvTvpc WITH (NOLOCK)
				ON TwnSph.IdProvince = PrvTvpc.IdProvince 
			LEFT JOIN [DeliveryBackOffice].[dbo].[CatTypeVehicle] ctv WITH (NOLOCK)
				ON shp.TypeVehicleId = ctv.IdTypeVehicle
			LEFT JOIN dbo.ServiceManagement srv WITH (NOLOCK)
				ON srv.IdSchedulePickup = shp.SchedulePickupId
			LEFT JOIN [DeliveryBackOffice].[dbo].[CatServiceStatus] AS css WITH (NOLOCK)
				ON css.IdServiceStatus = srv.ServiceStatusId
			LEFT JOIN [DeliveryBackOffice].[dbo].[HubLogistics] hl WITH (NOLOCK)
			    ON shp.IdHubLogistics = hl.IdHubLogistic
			LEFT JOIN [DeliveryBackOffice].[dbo].[RouteAssigment] as ra WITH (NOLOCK)
				ON srv.IdPuRouteAssigment = ra.IdRouteAssigment
			OUTER APPLY (
				SELECT TOP 1 ES.DateCreated
				FROM DeliveryBackOffice.dbo.EventService ES with(nolock)
				WHERE ES.ServiceManagementId = srv.IdServiceManagement
					AND ES.ServiceStatusId = @ServicePickupStatus
					AND ES.RowStauts = 1
				ORDER BY ES.DateCreated DESC
			) es
		WHERE
			shp.AccountId = @accountId
			AND shp.RowStatus = 1
			AND shp.StartDate >= @startDate
			AND shp.StartDate < DATEADD(DAY, 1, @endDate)
			AND (ISNULL(hl.IdCountry,'GT') = @IdCountry OR ISNULL(PrvTvpc.IdCountry, 'GT') = @IdCountry)
		ORDER BY shp.DateCreated desc
		OPTION (RECOMPILE)
	END
	ELSE IF (@userId IS NOT NULL AND ISNULL(@accountId,0) = 0)
	BEGIN
	
		SELECT 2 'StatusCode', 
				'Registros obtenidos'	'Description';
		--INSERT INTO @tbl
		select 
			shp.ServiceRate 'Qualification',
			srv.IdServiceManagement 'IdServiceManagement' , 
			CONVERT(VARCHAR(10), shp.StartDate, 103) + ' ' + CONVERT(VARCHAR(10), shp.StartDate, 108) AS datecreated,
			ISNULL(CAST(RA.IdCurrierMan AS NVARCHAR), '') AS courier,
			CONVERT(VARCHAR(10), es.DateCreated, 103) AS datePickUp,
			CONVERT(VARCHAR(10), es.DateCreated, 108) AS hourPickUp,
			ISNULL(ctv.Name, '') 'ServiceVehicle',
			shp.IsScheduled 'IsScheduled',
			ISNULL(QuantityRegularPackages,0) 'QuantityRegularPackages',
			ISNULL(QuantityOverDimensionedPackage,0)'QuantityOverDimensionedPackage',
			css.[Name] StatusName,
			ISNULL(vpc.Address, shp.AddressPickup) 'OriginAddress',
			vpc.DescriptionOfClient 'OriginAddressName',		   
			vpc.Department 'OriginAddressProvince',
			vpc.Town 'OriginAddressTown',           
			CONVERT(VARCHAR(8), shp.StartDate, 108) + '   ' + CONVERT(VARCHAR(10), shp.EndDate, 108) AS rangeHour,
			hl.HubAbbreviation 'Hub'
			from SchedulePickup shp with(nolock)
			LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpc WITH (NOLOCK)
				ON shp.SenderId = vpc.CodeOfReference
			LEFT JOIN [DeliveryBackOffice].[dbo].[Township] TwnTvpc WITH (NOLOCK)
				ON vpc.IdTownship = TwnTvpc.IdTownship
			INNER JOIN [DeliveryBackOffice].[dbo].[Township] TwnSph  WITH (NOLOCK) -----
				ON TwnSph.IdTownship = shp.TownshipId
			INNER JOIN [DeliveryBackOffice].[dbo].[Province] PrvTvpc WITH (NOLOCK)
				ON TwnSph.IdProvince = PrvTvpc.IdProvince 
			LEFT JOIN (
				SELECT
					DSC.HeaderCode,
					MAX(DSC.Hub) 'hub'
				FROM
					[DeliveryBackOffice].[dbo].[DumpServiceCoverage] DSC WITH (NOLOCK)
				WHERE
					DSC.RowStatus = 1
				GROUP BY
					DSC.HeaderCode
			) AS dsc
				ON TwnTvpc.HeaderCode = dsc.HeaderCode
			LEFT JOIN [DeliveryBackOffice].[dbo].[HubLogistics] as hl WITH (NOLOCK)
				ON hl.HubAbbreviation = dsc.hub COLLATE Latin1_General_CI_AI
			LEFT JOIN [DeliveryBackOffice].[dbo].[CatTypeVehicle] ctv WITH (NOLOCK)
				ON shp.TypeVehicleId = ctv.IdTypeVehicle
			LEFT JOIN dbo.ServiceManagement srv with(nolock)
				ON srv.IdSchedulePickup = shp.SchedulePickupId
			LEFT JOIN [DeliveryBackOffice].[dbo].[CatServiceStatus] AS css WITH (NOLOCK)
				ON css.IdServiceStatus = srv.ServiceStatusId
			INNER JOIN [DeliveryBackOffice].[dbo].[HubLogisticByUser] AS hlbu WITH (NOLOCK)
				ON ISNULL(shp.IdHubLogistics, hl.IdHubLogistic) = hlbu.HubLogisticId
			INNER JOIN [DeliveryBackOffice].[dbo].[HubLogistics] as hlf WITH (NOLOCK)
				ON shp.IdHubLogistics = hlf.IdHubLogistic
			LEFT JOIN [DeliveryBackOffice].[dbo].[RouteAssigment] as ra WITH (NOLOCK)
				ON srv.IdPuRouteAssigment = ra.IdRouteAssigment
			OUTER APPLY (
				SELECT TOP 1 ES.DateCreated
				FROM DeliveryBackOffice.dbo.EventService ES with(nolock)
				WHERE ES.ServiceManagementId = srv.IdServiceManagement
					AND ES.ServiceStatusId = @ServicePickupStatus
					AND ES.RowStauts = 1
				ORDER BY ES.DateCreated DESC
			) es
			where hlbu.userId = @userId and 
				shp.RowStatus = 1 and 
				shp.StartDate >= @startDate and 
				shp.StartDate < DATEADD(DAY, 1, @endDate)
				AND (ISNULL(@serviceManagementId,0) = 0 OR srv.IdServiceManagement = @serviceManagementId)
				AND (ISNULL(hlf.IdCountry,'GT') = @IdCountry OR ISNULL(PrvTvpc.IdCountry, 'GT') = @IdCountry)
			ORDER BY shp.DateCreated desc
			OPTION (RECOMPILE)

	END
	ELSE
	BEGIN

		SELECT 0 'StatusCode', 
				'Sin registros'	'Description';

	END
	   
END;
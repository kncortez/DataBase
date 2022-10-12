
-- =============================================
-- Author:		<Alberto, Ixchop>
-- Create date: <2022-09-13>
-- Description:	<Devuelve todas las recolecciones de un usuario individual filtradas por un rango de fechas, siendo máximo 30 días atras>
-- =============================================
CREATE PROCEDURE [dbo].[sphw_GetRoutePreparationPickupByRange]
	@startDate AS DATE = NULL, --Fecha inicio de filtro
	@endDate AS DATE = NULL, --Fecha fin de filtro

	@accountId BIGINT = NULL,
	@userId BIGINT = NULL,
	@serviceManagementId INT = NULL

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
	   	 
	IF (@accountId IS NOT NULL AND ISNULL(@userId,0) = 0)
	BEGIN

		SELECT 1 'StatusCode', 
				'Registros obtenidos'	'Description';
		--INSERT INTO @tbl
		SELECT shp.ServiceRate 'Qualification',
				srv.IdServiceManagement 'IdServiceManagement' , 
			   CONCAT(CONVERT(VARCHAR(10), shp.DateCreated, 103),' ',CONVERT(VARCHAR(10), shp.DateCreated, 108))  'datecreated',
			   CONVERT(VARCHAR(10), shp.StartDate, 103) 'datePickUp',
			   CONVERT(VARCHAR(10), shp.StartDate, 108) 'hourPickUp',
			   ISNULL(ctv.Name, '') 'ServiceVehicle',
			   shp.IsScheduled 'IsScheduled',
			   ISNULL(QuantityRegularPackages,0) 'QuantityRegularPackages',
			   ISNULL(QuantityOverDimensionedPackage,0)'QuantityOverDimensionedPackage',
			   css.[Name] StatusName,
			   ISNULL(vpc.Address, shp.AddressPickup) 'OriginAddress',
			   vpc.DescriptionOfClient 'OriginAddressName',		   
			   vpc.Department 'OriginAddressProvince',
			   vpc.Town 'OriginAddressTown',           
			   CONCAT(CONVERT(VARCHAR(10), shp.StartDate, 108), '   ', CONVERT(VARCHAR(10), shp.EndDate, 108)) 'rangeHour',
			   hl.HubAbbreviation 'Hub'
           
		FROM DeliveryBackOffice.dbo.SchedulePickup AS shp WITH (NOLOCK)
			LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpc WITH (NOLOCK)
				ON shp.SenderId = vpc.CodeOfReference
			LEFT JOIN [DeliveryBackOffice].[dbo].[Township] TwnTvpc WITH (NOLOCK)
				ON vpc.IdTownship = TwnTvpc.IdTownship
			LEFT JOIN [DeliveryBackOffice].[dbo].[CatTypeVehicle] ctv WITH (NOLOCK)
				ON shp.TypeVehicleId = ctv.IdTypeVehicle
			LEFT JOIN dbo.ServiceManagement srv
				ON srv.IdSchedulePickup = shp.SchedulePickupId
			LEFT JOIN [DeliveryBackOffice].[dbo].[CatServiceStatus] AS css WITH (NOLOCK)
				ON css.IdServiceStatus = srv.ServiceStatusId
			LEFT JOIN [DeliveryBackOffice].[dbo].[HubLogistics] hl WITH (NOLOCK)
			    ON shp.IdHubLogistics = hl.IdHubLogistic
		WHERE
			CONVERT(date, shp.DateCreated) >= @startDate
			AND
			CONVERT(date, shp.DateCreated) <= @endDate
			AND shp.RowStatus = 1
			AND shp.AccountId = @accountId
		ORDER BY shp.DateCreated desc
		
	END
	ELSE IF (@userId IS NOT NULL AND ISNULL(@accountId,0) = 0)
	BEGIN
	
		SELECT 2 'StatusCode', 
				'Registros obtenidos'	'Description';
		--INSERT INTO @tbl
		SELECT shp.ServiceRate 'Qualification',
				srv.IdServiceManagement 'IdServiceManagement' , 
			   CONCAT(CONVERT(VARCHAR(10), shp.DateCreated, 103),' ',CONVERT(VARCHAR(10), shp.DateCreated, 108))  'datecreated',
			   hlf.HubAbbreviation 'hub',
			   RTRIM(LTRIM(CONCAT(sr.First_Name,' ', sr.Last_Name))) 'courier',
			   CONVERT(VARCHAR(10), shp.StartDate, 103) 'datePickUp',
			   CONVERT(VARCHAR(10), shp.StartDate, 108) 'hourPickUp',
			   ISNULL(ctv.Name, '') 'ServiceVehicle',
			   shp.IsScheduled 'IsScheduled',
			   ISNULL(QuantityRegularPackages,0) 'QuantityRegularPackages',
			   ISNULL(QuantityOverDimensionedPackage,0)'QuantityOverDimensionedPackage',
			   css.[Name] StatusName,
			   ISNULL(vpc.Address, shp.AddressPickup) 'OriginAddress',
			   vpc.DescriptionOfClient 'OriginAddressName',		   
			   vpc.Department 'OriginAddressProvince',
			   vpc.Town 'OriginAddressTown',           
			   CONCAT(CONVERT(VARCHAR(10), shp.StartDate, 108), '   ', CONVERT(VARCHAR(10), shp.EndDate, 108)) 'rangeHour'           
		FROM DeliveryBackOffice.dbo.SchedulePickup AS shp WITH (NOLOCK)
			LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpc WITH (NOLOCK)
				ON shp.SenderId = vpc.CodeOfReference
			LEFT JOIN [DeliveryBackOffice].[dbo].[Township] TwnTvpc WITH (NOLOCK)
				ON vpc.IdTownship = TwnTvpc.IdTownship
			LEFT JOIN (
				SELECT
					DSC.HeaderCode,
					MAX(DSC.Hub) 'hub'
				FROM
					[DeliveryBackOffice].[dbo].[DumpServiceCoverage] DSC
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
			LEFT JOIN dbo.ServiceManagement srv
				ON srv.IdSchedulePickup = shp.SchedulePickupId
			LEFT JOIN [DeliveryBackOffice].[dbo].[CatServiceStatus] AS css WITH (NOLOCK)
				ON css.IdServiceStatus = srv.ServiceStatusId
			INNER JOIN [DeliveryBackOffice].[dbo].[HubLogisticByUser] AS hlbu WITH (NOLOCK)
				ON ISNULL(shp.IdHubLogistics, hl.IdHubLogistic) = hlbu.HubLogisticId
				AND hlbu.UserId = @userId
			INNER JOIN [DeliveryBackOffice].[dbo].[HubLogistics] as hlf WITH (NOLOCK)
				ON hlbu.IdHubLogisticByUser = hlf.IdHubLogistic
			LEFT JOIN [DeliveryBackOffice].[dbo].[RouteAssigment] as ra WITH (NOLOCK)
				ON srv.IdPuRouteAssigment = ra.IdRouteAssigment
			LEFT JOIN [DeliveryBackOffice].[dbo].[SenderReceiver] as sr WITH (NOLOCK)
				ON ra.IdCurrierMan = sr.ID
		WHERE
			CONVERT(date, shp.DateCreated) >= @startDate
			AND
			CONVERT(date, shp.DateCreated) <= @endDate
			AND shp.RowStatus = 1
			AND (ISNULL(@serviceManagementId,0) = 0 OR srv.IdServiceManagement = @serviceManagementId)
		ORDER BY shp.DateCreated desc

	END
	ELSE
	BEGIN

		SELECT 0 'StatusCode', 
				'Sin registros'	'Description';

	END
	   
END;
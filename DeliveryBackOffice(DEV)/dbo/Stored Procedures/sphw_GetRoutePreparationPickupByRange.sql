
-- =============================================
-- Author:		<Alberto, Ixchop>
-- Create date: <2022-09-13>
-- Description:	<Devuelve todas las recolecciones de un usuario individual filtradas por un rango de fechas, siendo máximo 30 días atras>
-- =============================================

CREATE PROCEDURE [dbo].[sphw_GetRoutePreparationPickupByRange]
	@startDate AS DATE = NULL, --Fecha inicio de filtro
	@endDate AS DATE = NULL, --Fecha fin de filtro
	@accountId BIGINT 

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
	   	 
	SELECT 1 'StatusCode', 
			'Registros obtenidos'	'Description';
    --INSERT INTO @tbl
    SELECT shp.ServiceRate 'Qualification',
			srv.IdServiceManagement 'IdServiceManagement' , 
		   CONVERT(VARCHAR(10), shp.DateCreated, 105) 'datecreated',
           CONVERT(VARCHAR(10), shp.StartDate, 105) 'datePickUp',
           CONVERT(VARCHAR(10), shp.StartDate, 108) 'hourPickUp',
		   ISNULL(ctv.Name, '') 'ServiceVehicle',
		   shp.IsScheduled 'IsScheduled',
           QuantityRegularPackages 'QuantityRegularPackages',
           QuantityOverDimensionedPackage 'QuantityOverDimensionedPackage',
		   css.[Name] StatusName,
		   vpc.Address 'OriginAddress',
		   vpc.DescriptionOfClient 'OriginAddressName',		   
		   vpc.Department 'OriginAddressProvince',
		   vpc.Town 'OriginAddressTown',           
           CONCAT(CONVERT(VARCHAR(10), shp.StartDate, 108), '   ', CONVERT(VARCHAR(10), shp.EndDate, 108)) 'rangeHour'           
           
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
    WHERE
		CONVERT(date, shp.StartDate) >= @startDate
		AND
		CONVERT(date, shp.StartDate) <= @endDate
        AND shp.RowStatus = 1
		AND shp.AccountId = @accountId

END;
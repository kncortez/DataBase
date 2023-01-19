USE [DeliveryBackOffice]
GO

DECLARE @DayOfWeek INT

-- ASINGACIÓN DE DATOS
/*
	1 - Domingo
	2 - Lunes
	3 - Martes
	4 - Miercoles
	5- Jueves
	6 - Viernes
	7 - Sabado
*/
SET @DayOfWeek = 2
-- CONFIGURACIONES
DECLARE @VolumeFactor DECIMAL(10,2) = 100; -- Centimetros a metros
-- Dimensiones de paquetería esta dado en centimetros
DECLARE @SmallPackageId INT = (SELECT TOP 1 CA.ArtId FROM [DeliveryBackOffice].[dbo].[CatArticle] CA WITH(NOLOCK) WHERE CA.ArtName = 'Paquete pequeño' COLLATE Latin1_General_CI_AI)
DECLARE @AlternativePackageId INT = (SELECT TOP 1 CA.ArtId FROM [DeliveryBackOffice].[dbo].[CatArticle] CA WITH(NOLOCK) WHERE CA.ArtName = 'Paquete sobredimensionado' COLLATE Latin1_General_CI_AI)
-- Volumen de paquetes en M3
DECLARE @AveragePackageVolume DECIMAL(10,2) = (SELECT TOP 1 ((CA.ArtWidth * CA.ArtHeight * CA.ArtLength) / (@VolumeFactor * @VolumeFactor * @VolumeFactor)) 'Volume' FROM [DeliveryBackOffice].[dbo].[CatArticle] CA WITH(NOLOCK) WHERE CA.ArtId = @SmallPackageId)
DECLARE @AlternativePackageVolume DECIMAL(10,2) = (SELECT TOP 1 ((CA.ArtWidth * CA.ArtHeight * CA.ArtLength) / (@VolumeFactor * @VolumeFactor * @VolumeFactor)) 'Volume' FROM [DeliveryBackOffice].[dbo].[CatArticle] CA WITH(NOLOCK) WHERE CA.ArtId = @AlternativePackageId)

--- Clientes que se deben tratar  con el volumen de paquete alterno ---
DECLARE @CustomersWithAlternativePackageVolume TABLE (
	CustomerId INT
);

-----------------------------------------------------------------------
-- Clientes que se debe ingresar manualmente el promedio de paquetes --
DECLARE @CustomerWithManualAveragePieces TABLE (
	CustomerId INT,
	AverageTotalPieces INT
);
-----------------------------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#AveragePackagesPerPickup', 'U') IS NOT NULL
        DROP TABLE #AveragePackagesPerPickup;
IF OBJECT_ID('tempdb.dbo.#AverageTimePerPickup', 'U') IS NOT NULL
        DROP TABLE #AverageTimePerPickup;

CREATE TABLE #AveragePackagesPerPickup (
	CustomerId INT,
	VisitPoint INT,
	AverageTotalPieces INT
);

CREATE NONCLUSTERED INDEX TMP_IDX_AveragePackagesPerPickup_Customer ON #AveragePackagesPerPickup (CustomerId, VisitPoint);

CREATE TABLE #AverageTimePerPickup (
	CustomerId INT,
	VisitPoint INT,
	AverageTimePickup DECIMAL(10,2)
);

CREATE NONCLUSTERED INDEX TMP_IDX_AverageTimePerPickup_Customer ON #AverageTimePerPickup (CustomerId, VisitPoint);

-- Obtener promedio de piezas recolectadas
INSERT INTO #AveragePackagesPerPickup
	(
		CustomerId
		,VisitPoint
		,AverageTotalPieces
	)
SELECT
	Customer,
	VisitPoint,
	AVG(TotalPieces) 'AverageTotalPieces'
FROM
	(
		SELECT
			Customer
			,DayWithinWeek 'DayOfWeek'
			,VisitPoint
			,MAX(PiecesByPickup) 'TotalPieces'
		FROM
			(
				SELECT		
					Cu.IdCustomer 'Customer'
					,SP.SchedulePickupId 'Pickup'
					,SP.StartDate 'PickupDate'
					,VPI.DayOfVisit 'DayWithinWeek'
					,VPC.CodeOfReference 'VisitPoint'
					,SUM((DO.Pieces_Dry + DO.Pieces_Cold)) 'PiecesByPickup'
				FROM -- Recolecciones programadas
					[DeliveryBackOffice].[dbo].[VisitPointItinerary] VPI WITH(NOLOCK)
					INNER JOIN 
						[DeliveryBackOffice].[dbo].VisitPointFrequency VPF WITH (NOLOCK)
						ON 
							VPF.IdVPFrequency = VPI.VPFrequencyID AND VPF.RowStatus ='true' 
					INNER JOIN 
						[DeliveryBackOffice].[dbo].VisitPointConfiguration VPConfig WITH (NOLOCK)
						ON 
							VPConfig.IdVPConfiguration = VPF.VPConfigurationID AND VPConfig.RowStatus ='true'
					INNER JOIN 
						[DeliveryBackOffice].[dbo].VisitPointClient VPC WITH (NOLOCK)
						ON 
							VPC.CodeOfReference = VPConfig.VisitPointID
							AND
							VPC.StatusClient = 'true'
					INNER JOIN 
						[DeliveryBackOffice].[dbo].Customer Cu WITH (NOLOCK)
						ON 
							Cu.IdCustomer = VPC.CustomerID AND Cu.RowSatus ='true'
					INNER JOIN 
						[DeliveryBackOffice].[dbo].SchedulePickup SP WITH(NOLOCK)
						ON 
							VPC.CodeOfReference = SP.SenderId
							AND 
							DATEPART(WEEKDAY, SP.StartDate) = VPI.DayOfVisit
					LEFT JOIN 
						[DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] DOPD WITH(NOLOCK)
						ON 
							SP.SchedulePickupId = DOPD.IdHeaderRecolection
					LEFT JOIN 
						[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
						ON 
							DOPD.GuideSerie = DO.Guide_Serie
							AND 
							DOPD.GuideNumber = DO.Guide_Number
				WHERE 
					VPI.RowStatus = 'TRUE'
					AND 
					ISNULL(VPI.InitializationTimeOfVisit, '__:__') != '__:__'
					AND 
					ISNULL(VPI.FinalizationTimeOfVisit, '__:__') != '__:__'
				GROUP BY
					Cu.IdCustomer,
					SP.SchedulePickupId,
					SP.StartDate,
					VPI.DayOfVisit,
					VPC.CodeOfReference
			) PBPBC
		WHERE
			PiecesByPickup IS NOT NULL
		GROUP BY
			Customer,
			DayWithinWeek,
			VisitPoint
	) MPBPBC
GROUP BY
	Customer
	,VisitPoint

-- Obtener promedio de tiempo durante recolección
INSERT INTO #AverageTimePerPickup
	(
		CustomerId
		,VisitPoint
		,AverageTimePickup
	)
SELECT
	Customer,
	VisitPoint,
	CAST(MAX(DifferenceInSeconds) AS DECIMAL) / 60 'DifferenceInMinutes'
FROM
	(
		SELECT
			Customer
			,DayWithinWeek 'DayOfWeek'
			,VisitPoint
			,CAST(MAX(DifferenceInSeconds) AS DECIMAL) 'DifferenceInSeconds'
		FROM
			(
				SELECT		
					Cu.IdCustomer 'Customer'
					,SP.SchedulePickupId 'Pickup'
					,SP.StartDate 'PickupDate'
					,VPI.DayOfVisit 'DayWithinWeek'
					,VPC.CodeOfReference 'VisitPoint'
					,MAX(DATEDIFF(SECOND,SM.CiPuDate,SM.CoPuDate)) 'DifferenceInSeconds'
				FROM -- Recolecciones programadas
					[DeliveryBackOffice].[dbo].[VisitPointItinerary] VPI WITH(NOLOCK)
					INNER JOIN 
						[DeliveryBackOffice].[dbo].VisitPointFrequency VPF WITH (NOLOCK)
						ON 
							VPF.IdVPFrequency = VPI.VPFrequencyID AND VPF.RowStatus ='true' 
					INNER JOIN 
						[DeliveryBackOffice].[dbo].VisitPointConfiguration VPConfig WITH (NOLOCK)
						ON 
							VPConfig.IdVPConfiguration = VPF.VPConfigurationID AND VPConfig.RowStatus ='true'
					INNER JOIN 
						[DeliveryBackOffice].[dbo].VisitPointClient VPC WITH (NOLOCK)
						ON 
							VPC.CodeOfReference = VPConfig.VisitPointID
							AND
							VPC.StatusClient = 'true'
					INNER JOIN 
						[DeliveryBackOffice].[dbo].Customer Cu WITH (NOLOCK)
						ON 
							Cu.IdCustomer = VPC.CustomerID AND Cu.RowSatus ='true'
					INNER JOIN 
						[DeliveryBackOffice].[dbo].SchedulePickup SP WITH(NOLOCK)
						ON 
							VPC.CodeOfReference = SP.SenderId
							AND 
							DATEPART(WEEKDAY, SP.StartDate) = VPI.DayOfVisit
					INNER JOIN
						[DeliveryBackOffice].[dbo].[ServiceManagement] SM WITH(NOLOCK)
						ON
							SP.SchedulePickupId = SM.IdSchedulePickup
				WHERE 
					VPI.RowStatus = 'TRUE'
					AND 
					ISNULL(VPI.InitializationTimeOfVisit, '__:__') != '__:__'
					AND 
					ISNULL(VPI.FinalizationTimeOfVisit, '__:__') != '__:__'
					AND
					SM.CiPuDate IS NOT NULL
					AND
					SM.CoPuDate IS NOT NULL
				GROUP BY
					Cu.IdCustomer,
					SP.SchedulePickupId,
					SP.StartDate,
					VPI.DayOfVisit,
					VPC.CodeOfReference
			) TBPBC
		WHERE
			DifferenceInSeconds IS NOT NULL
		GROUP BY
			Customer,
			VisitPoint,
			DayWithinWeek
	) MTBPBC
GROUP BY
	Customer,
	VisitPoint

-- Información para procesamiento
SELECT	
	DISTINCT
		--Cu.IdCustomer,
		VPI.IdVPItinerary IdItinerary,
		VPC.DescriptionOfClient 'Descripción de punto de visita',
		(CASE WHEN LTRIM(RTRIM(ISNULL(VPC.Latitude, ''))) != '' THEN VPC.Latitude ELSE NULL END) 'Latitud',
		(CASE WHEN LTRIM(RTRIM(ISNULL(VPC.Longitude, ''))) != '' THEN VPC.Longitude ELSE NULL END) 'Longitud',
		VPC.[Address] 'Dirección',
		VPConfig.AveragePackageDaily 'Promedio de paquetes configurado',
		APPP.AverageTotalPieces 'Promedio de paquetes recolectados',
		ATPP.AverageTimePickup 'Promedio de tiempo de ejecución de recolección',
		(APPP.AverageTotalPieces * @AveragePackageVolume) 'Carga del servicio',
		VPI.InitializationTimeOfVisit 'Hora de atención inicial de recolección',
		VPI.FinalizationTimeOfVisit 'Hora de atención final de recolección'
FROM 
	[DeliveryBackOffice].[dbo].VisitPointItinerary VPI
	INNER JOIN 
		[DeliveryBackOffice].[dbo].VisitPointFrequency VPF WITH (NOLOCK)
		ON 
			VPF.IdVPFrequency = VPI.VPFrequencyID 
			AND 
			VPF.RowStatus ='true' 
	INNER JOIN 
		[DeliveryBackOffice].[dbo].VisitPointConfiguration VPConfig WITH (NOLOCK)
		ON 
			VPConfig.IdVPConfiguration = VPF.VPConfigurationID 
			AND 
			VPConfig.RowStatus ='true'
	INNER JOIN 
		[DeliveryBackOffice].[dbo].VisitPointClient VPC WITH (NOLOCK)
		ON 
			VPC.CodeOfReference = VPConfig.VisitPointID
			AND
			VPC.StatusClient = 'true'
	INNER JOIN 
		[DeliveryBackOffice].[dbo].Customer Cu WITH (NOLOCK)
		ON 
			Cu.IdCustomer = VPC.CustomerID 
			AND 
			Cu.RowSatus ='true'
	LEFT JOIN
		#AveragePackagesPerPickup APPP
		ON
			APPP.CustomerId = Cu.IdCustomer
			AND
			APPP.VisitPoint = VPC.CodeOfReference
	LEFT JOIN
		#AverageTimePerPickup ATPP
		ON
			ATPP.CustomerId = Cu.IdCustomer
			AND
			ATPP.VisitPoint = VPC.CodeOfReference
WHERE 
	VPI.DayOfVisit = @DayOfWeek
	AND 
	VPI.RowStatus = 'TRUE'
	AND 
	ISNULL(VPI.InitializationTimeOfVisit, '__:__') != '__:__'
	AND 
	ISNULL(VPI.FinalizationTimeOfVisit, '__:__') != '__:__'

IF OBJECT_ID('tempdb.dbo.#AveragePackagesPerPickup', 'U') IS NOT NULL
        DROP TABLE #AveragePackagesPerPickup;
IF OBJECT_ID('tempdb.dbo.#AverageTimePerPickup', 'U') IS NOT NULL
        DROP TABLE #AverageTimePerPickup;
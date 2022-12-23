-- =============================================
-- Author:		<Alberto Ixchop>
-- Create date: <22-09-2022>
-- Description:	<Método para carga de servicios pendientes de procesar filtrado por hubs y rango de fechas>
-- =============================================
CREATE PROCEDURE [dbo].[sphw_GetPendingRecollectionServices]
	-- Add the parameters for the stored procedure here
	@HubId	INT = -1,
	@StartDate DATE =NULL,
	@EndDate DATE =NULL,
	@IdUser INT = -1

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @RefClientId BIGINT = (SELECT TOP 1 Acc.AccIdAccount FROM [DeliveryBackOffice].[dbo].[Account] Acc WITH(NOLOCK) INNER JOIN [DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK) ON Acc.IdCustomer = Cu.IdCustomer WHERE Cu.[Name] = 'Cliente Referenciado' COLLATE Latin1_General_CI_AI);

    DECLARE @TranCounter INT;  
    SET @TranCounter = @@TRANCOUNT;  
    IF @TranCounter > 0  
        SAVE TRANSACTION SPGetPendingRecolectionServices;  
    ELSE  
        BEGIN TRANSACTION;  

	DECLARE @ResponseTable AS TABLE(
		Qualification BIT,
		IdServiceManagement INT,
		datecreated NVARCHAR(50),
		datePickUp NVARCHAR(50),
		hourPickUp NVARCHAR(50),
		ServiceVehicle NVARCHAR(50),
		IsScheduled BIT,
		QuantityRegularPackages INT,
		QuantityOverDimensionedPackage INT,
		StatusName NVARCHAR(50),
		OriginAddress NVARCHAR(600),
		OriginAddressName NVARCHAR(100),
		OriginAddressProvince NVARCHAR(50),
		OriginAddressTown NVARCHAR(50),
		rangeHour NVARCHAR(50),
		IdHubLogistic INT,
		HubAbbreviation NVARCHAR(10),
		FirstName NVARCHAR(100),
		LastName NVARCHAR(100),
		Scheduled BIT,
		CurrierManId INT,
		IdRoute INT,
		IdRouteAssigment INT,
		CurrierFirstName NVARCHAR(100),
		Last_Name NVARCHAR(100),
		Latitude NVARCHAR(100),
		Longitude NVARCHAR(100),
		IsAlerted BIT
	);
		
	BEGIN TRY
		IF @StartDate IS NULL
			SET @StartDate = GETDATE();
		IF @EndDate IS NULL
			SET @EndDate = GETDATE();

		SELECT 
			1 AS 'StatusCode', 
			'Registros obtenidos' AS 'Description';
		
		INSERT INTO @ResponseTable
		SELECT 
			ISNULL(shp.ServiceRate,0) 'Qualification',
			srv.IdServiceManagement 'IdServiceManagement' , 
			CONCAT(CONVERT(VARCHAR(10), shp.DateCreated, 105),' ',CONVERT(VARCHAR(10), shp.DateCreated, 108))  'datecreated',
			CONVERT(VARCHAR(10), shp.StartDate, 105) 'datePickUp',
			CONVERT(VARCHAR(10), shp.StartDate, 108) 'hourPickUp',
			ISNULL(ctv.Name, '') 'ServiceVehicle',
			shp.IsScheduled 'IsScheduled',
			ISNULL(QuantityRegularPackages,0) 'QuantityRegularPackages',
			ISNULL(QuantityOverDimensionedPackage,0)'QuantityOverDimensionedPackage',
			css.[Name] StatusName,
			vpc.Address 'OriginAddress',
			vpc.DescriptionOfClient 'OriginAddressName',		   
			vpc.Department 'OriginAddressProvince',
			vpc.Town 'OriginAddressTown',           
			CONCAT(CONVERT(VARCHAR(10), shp.StartDate, 108), '   ', CONVERT(VARCHAR(10), shp.EndDate, 108)) 'rangeHour',
			ISNULL(SPHUB.IdHubLogistic,hub.IdHubLogistic) 'IdHubLogistic',
			ISNULL(SPHUB.HubAbbreviation,hub.HubAbbreviation) 'HubAbbreviation',
			(CASE WHEN Ac.AccIdAccount = @RefClientId THEN vpc.DescriptionOfClient ELSE PR.PerFirstName END) 'FirstName',
			PR.PerLastName 'LastName',
			shp.IsScheduled 'Scheduled',
			RA.IdCurrierMan 'CurrierManId',
			ISNULL(RA.IdRoute,-1) 'IdRoute',
			RA.IdRouteAssigment 'IdRouteAssigment',
			SNR.First_Name 'CurrierFirstName',
			SNR.Last_Name 'Last_Name',
			vpc.Latitude 'Latitude',
			vpc.Longitude 'Longitude',
			CAST(ISNULL((SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[DeliveryOrderAlert] DOA WITH(NOLOCK) WHERE DOA.ServiceManagementId = srv.IdServiceManagement AND DOA.RowStatus = 1),0) AS BIT) 'IsAlerted'
		FROM DeliveryBackOffice.dbo.SchedulePickup AS shp WITH (NOLOCK)
			LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpc WITH (NOLOCK)
				ON shp.SenderId = vpc.CodeOfReference
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
					INNER JOIN DBO.HubLogistics HL ON HL.HubAbbreviation=DSCAux.Hub 
				WHERE DSCAux.RowStatus = 1 AND HL.HubStatus =1
				GROUP BY DSCAux.HeaderCode,HL.IdHubLogistic
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
			LEFT JOIN [DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
						ON Cu.IdCustomer = vpc.CustomerID
			------------------------------------------------------------------------------------
			--COURIER ASIGNADO
			LEFT JOIN [DeliveryBackOffice].[dbo].RouteAssigment RA WITH(NOLOCK)
						ON RA.IdRouteAssigment = srv.IdPuRouteAssigment
			LEFT JOIN [DeliveryBackOffice].[dbo].SenderReceiver SNR WITH(NOLOCK)
						ON SNR.ID=RA.IdCurrierMan
			------------------------------------------------------------------------------------
			--USUARIO POR HUB ASIGNADO
			INNER JOIN [DeliveryBackOffice].[dbo].HubLogisticByUser HLBU WITH(NOLOCK)
						ON HLBU.HubLogisticId=ISNULL(shp.IdHubLogistics, hub.IdHubLogistic)
			------------------------------------------------------------------------------------
			LEFT JOIN DBO.HubLogistics SPHUB ON shp.IdHubLogistics=SPHUB.IdHubLogistic
			------------------------------------------------------------------------------------
			--INCIDENCIA
			LEFT JOIN (
				SELECT INSRV.ServiceManagementId FROM [DeliveryBackOffice].[dbo].IncidenceServices INSRV WITH(NOLOCK)
				GROUP BY ServiceManagementId
			) INSRV
						ON INSRV.ServiceManagementId=srv.IdServiceManagement

		WHERE
			CONVERT(date, shp.StartDate) >= @startDate
			AND
			CONVERT(date, shp.StartDate) <= @endDate
			AND shp.RowStatus = 1
			--AND (
			--	@HubId = -1 
			--	OR (SPHUB.IdHubLogistic IS NOT NULL AND SPHUB.IdHubLogistic= @HubId)
			--	OR (HUB.IdHubLogistic IS NULL AND HUB.IdHubLogistic = @HubId)
			--)
			AND(
				@IdUser =-1
				OR
				HLBU.UserId=@IdUser
			)
			AND
			------------------------------------------------------------------------
			--FILTRO DE SERVICIO PENDINETE (ESTADO VALIDO Y SIN INCIDENCIA)
				srv.ServiceStatusId IN (SELECT IdServiceStatus FROM DBO.CatServiceStatus WHERE Name IN ('Creado','Asignado a Ruta','Reprogramado'))
				AND
				INSRV.ServiceManagementId IS NULL--No posee ninguna incidencia registrada
			------------------------------------------------------------------------

		SELECT
			DISTINCT
				RT.Qualification
				,RT.IdServiceManagement
				,RT.datecreated
				,RT.datePickUp
				,RT.hourPickUp
				,RT.ServiceVehicle
				,RT.IsScheduled
				,RT.QuantityRegularPackages
				,RT.QuantityOverDimensionedPackage
				,RT.StatusName
				,RT.OriginAddress
				,RT.OriginAddressName
				,RT.OriginAddressProvince
				,RT.OriginAddressTown
				,RT.rangeHour
				,RT.IdHubLogistic
				,RT.HubAbbreviation
				,RT.FirstName
				,RT.LastName
				,RT.Scheduled
				,RT.CurrierManId
				,RT.IdRoute
				,RT.IdRouteAssigment
				,RT.CurrierFirstName
				,RT.Last_Name
				,RT.Latitude
				,RT.Longitude
				,RT.IsAlerted
		FROM
			@ResponseTable RT
		ORDER BY
			RT.IsAlerted DESC,
			RT.datecreated DESC

		SELECT
			DISTINCT
				RT.Qualification
				,RT.IdServiceManagement
				,RT.datecreated
				,RT.datePickUp
				,RT.hourPickUp
				,RT.ServiceVehicle
				,RT.IsScheduled
				,RT.QuantityRegularPackages
				,RT.QuantityOverDimensionedPackage
				,RT.StatusName
				,RT.OriginAddress
				,RT.OriginAddressName
				,RT.OriginAddressProvince
				,RT.OriginAddressTown
				,RT.rangeHour
				,RT.IdHubLogistic
				,RT.HubAbbreviation
				,RT.FirstName
				,RT.LastName
				,RT.Scheduled
				,RT.CurrierManId
				,RT.IdRoute
				,RT.IdRouteAssigment
				,RT.CurrierFirstName
				,RT.Last_Name
				,RT.Latitude
				,RT.Longitude
				,RT.IsAlerted
		FROM
			@ResponseTable RT
		ORDER BY
			IsAlerted DESC

		IF @TranCounter = 0  
            COMMIT TRANSACTION;  
	END TRY
	BEGIN CATCH
        IF @TranCounter = 0  
            ROLLBACK TRANSACTION;  
        ELSE IF XACT_STATE() <> -1  
                ROLLBACK TRANSACTION SPGetPendingRecolectionServices;  
		SELECT 
			0 AS 'StatusCode', 
			ERROR_MESSAGE() AS 'Description';
	END CATCH

END
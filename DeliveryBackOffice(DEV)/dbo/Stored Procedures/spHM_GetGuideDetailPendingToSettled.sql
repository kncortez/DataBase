-- =============================================
-- Author:		<Alberto, Ixchop>
-- Create date: <11-10-2022>
-- Description:	<Carga guías pendientes por liquidar en proceso de liquidación unificada>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_GetGuideDetailPendingToSettled]
	-- Add the parameters for the stored procedure here
	@CourierId INT,
	@DateOfRoute DATE = NULL
AS
BEGIN


	IF(@DateOfRoute IS NULL)
	BEGIN
		SET @DateOfRoute = CAST(GETDATE() AS DATE);
	END
	-- Tipo de estado de guía terminal
	DECLARE @FinalStatusOfGuideId INT = (SELECT TOP 1 CCT.IdCatCheckpointType FROM [DeliveryBackOffice].[dbo].[CatCheckpointType] CCT WITH(NOLOCK) WHERE CCT.CheckpointTypeDescription = 'Checkpoint final');
	DECLARE @IncidenceStatusOfGuideId INT = (SELECT TOP 1 CCT.IdCatCheckpointType FROM [DeliveryBackOffice].[dbo].[CatCheckpointType] CCT WITH(NOLOCK) WHERE CCT.CheckpointTypeDescription = 'Checkpoint de incidencia');

	-- Tipos de servicio
	DECLARE @PickupServiceSubTypeId INT = (SELECT TOP 1 STSM.IdSubTypeServiceManagment FROM [DeliveryBackOffice].[dbo].[SubTypeServiceManagment] STSM WITH(NOLOCK) WHERE STSM.[Name] = 'Recolección' )
	DECLARE @DeliveryServiceSubTypeId INT = (SELECT TOP 1 STSM.IdSubTypeServiceManagment FROM [DeliveryBackOffice].[dbo].[SubTypeServiceManagment] STSM WITH(NOLOCK) WHERE STSM.[Name] = 'Entrega' )
	DECLARE @ReturnServiceSubTypeId INT = (SELECT TOP 1 STSM.IdSubTypeServiceManagment FROM [DeliveryBackOffice].[dbo].[SubTypeServiceManagment] STSM WITH(NOLOCK) WHERE STSM.[Name] = 'Devolución' )
	-- Estados de servicio interpretados como pendientes de procesar
	DECLARE @GeneratedServiceStatusId INT = (SELECT TOP 1 CSS.IdServiceStatus FROM [DeliveryBackOffice].[dbo].[CatServiceStatus] CSS WITH(NOLOCK) WHERE CSS.[Name] = 'Creado');
	DECLARE @OnRouteServiceStatusId INT = (SELECT TOP 1 CSS.IdServiceStatus FROM [DeliveryBackOffice].[dbo].[CatServiceStatus] CSS WITH(NOLOCK) WHERE CSS.[Name] = 'Asignado a Ruta');
	-- Estados de guías interpretados como pendientes de procesar o no posibles de interpretar
	-- Estados terminales se toman para buscar aquellas en estados pendientes
	DECLARE @FinalStatusOfGuide AS TABLE (
		StatusOrderId INT
	);
	INSERT INTO @FinalStatusOfGuide
		(StatusOrderId)
	SELECT
		SO.StatusOrderId
	FROM
		[DeliveryBackOffice].[dbo].[StatusOrder] SO WITH(NOLOCK)
	WHERE
		SO.CatCheckpointTypeId IN (@FinalStatusOfGuideId, @IncidenceStatusOfGuideId)

	-- Variables de control de flujo
	DECLARE @CourierRouteAssignments AS TABLE (
		IdRouteAssignment INT,
		IdRoute INT,
		IdVehicle INT,
		IdCourier INT,
		DateOfRoute DATE
	);

	-- Variables de respuesta 
	DECLARE @GuideList AS TABLE(
		RouteAssignmentId INT,
		GuideSerie NVARCHAR(2),
		GuideNumber INT,
		Guide NVARCHAR(50),
		GuideStatusId INT,
		GuideStatusDescription NVARCHAR(50),
		ClientName NVARCHAR(200),
		ServiceType NVARCHAR(10),
		ServiceTypeActions NVARCHAR(500)
	);

	DECLARE @ServiceList AS TABLE(
		RouteAssignmentId INT,
		ServiceManagementId INT,
		ServiceStatusId INT,
		ServiceStatusDescription NVARCHAR(50),
		ClientName NVARCHAR(200),
		ServiceType NVARCHAR(10),
		ServiceTypeActions NVARCHAR(500)
	);

	-- Inicio de procesamiento de datos
	BEGIN TRY
		INSERT INTO @CourierRouteAssignments
			(IdRouteAssignment, IdRoute, IdVehicle, IdCourier, DateOfRoute)
		SELECT
			RA.IdRouteAssigment
			,RA.IdRoute
			,RA.IdVehicle
			,RA.IdCurrierMan
			,RA.DateOfRoute
		FROM
			[DeliveryBackOffice].[dbo].[RouteAssigment] RA WITH(NOLOCK)
			INNER JOIN
				[DeliveryBackOffice].[dbo].[SenderReceiver] SR WITH(NOLOCK)
				ON
					RA.IdCurrierMan = SR.ID
		WHERE
			RA.DateOfRoute = @DateOfRoute
			AND
			RA.IdCurrierMan = @CourierId
			AND
			RA.RowStatus = 1

		IF(EXISTS(SELECT TOP 1 1 FROM  @CourierRouteAssignments))
		BEGIN

			-- Guías de servicios de entrega y devolución pendientes de procesar
			-- Entregas
			INSERT INTO @GuideList
				(RouteAssignmentId, GuideSerie, GuideNumber, Guide, GuideStatusId, GuideStatusDescription, ClientName, ServiceType)
			SELECT
				CRA.IdRouteAssignment,
				RPD.Guide_Serie 'GuideSerie',
				RPD.Guide_Number 'GuideNumber',
				CONCAT(RPD.Guide_Serie, RPD.Guide_Number) 'Guide',
				DO.StatusOrderId 'GuideStatus',
				SO.OrderDescription 'GuideStatusDescription',
				SMD.ServiceCustomerName 'ClientName',
				'DELIVERY' 'ServiceType'
			FROM
				@CourierRouteAssignments CRA
				INNER JOIN
					[DeliveryBackOffice].[dbo].[ServiceManagement] SM WITH(NOLOCK)
					ON
						CRA.IdRouteAssignment = SM.IdPuRouteAssigment
						AND
						SM.RowStatus = 1
				INNER JOIN
					[DeliveryBackOffice].[dbo].[ServiceManagementDetail] SMD WITH(NOLOCK)
					ON
						SM.IdServiceManagement = SMD.ServiceManagement
						AND
						SMD.SubTypeServiceManagmentId IN (@DeliveryServiceSubTypeId)
						AND
						SMD.RowStatus = 1
				INNER JOIN
					[DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD WITH(NOLOCK)
					ON
						SMD.IdServiceManagementDetail = RPD.ServiceManagementDetailId
						AND RPD.RowStatus=1
				INNER JOIN
					[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
					ON
						RPD.Guide_Serie = DO.Guide_Serie
						AND
						RPD.Guide_Number = DO.Guide_Number
				INNER JOIN
					[DeliveryBackOffice].[dbo].[StatusOrder] SO WITH(NOLOCK)
					ON
						DO.StatusOrderId = SO.StatusOrderId
				LEFT JOIN
					@FinalStatusOfGuide FSOG
					ON
						DO.StatusOrderId = FSOG.StatusOrderId
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[UnifiedRouteSettlement] URS WITH(NOLOCK)
					ON
						URS.RouteAssignmentId = CRA.IdRouteAssignment
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[UnifiedRouteSettlementDetail] URSD WITH(NOLOCK)
					ON
						URS.IdUnifiedRouteSettlement = URSD.UnifiedRouteSettlementId
						AND
						DO.Guide_Serie = URSD.GuideSerie
						AND
						DO.Guide_Number = URSD.GuideNumber
						AND
						URSD.RowStatus = 1
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[UnifiedRouteSettlementDetail] URSDOP WITH(NOLOCK)
					ON
						URS.IdUnifiedRouteSettlement = URSD.UnifiedRouteSettlementId
						AND
						DO.Guide_Serie = URSDOP.GuideSerie
						AND
						DO.Guide_Number = URSDOP.GuideNumber
						AND
						URSDOP.IsOpenProcess > 0
						AND
						URSDOP.UserProcess IS NOT NULL
						AND
						URSDOP.RowStatus = 0
			WHERE
				-- Que no este en estado terminal
				--FSOG.StatusOrderId IS NULL
				--AND
				-- Que no este liquidada en el proceso de las rutas actuales
				URSD.IdUnifiedRouteSettlementDetail IS NULL
				OR NOT(URSD.RowStatus=1 AND URSD.IsOpenProcess IN (0,NULL))
				--AND
				-- Que no este en un proceso abierto de las rutas actuales
				--URSDOP.IdUnifiedRouteSettlementDetail IS NULL

			-- Devoluciones
			INSERT INTO @GuideList
				(RouteAssignmentId, GuideSerie, GuideNumber, Guide, GuideStatusId, GuideStatusDescription, ClientName, ServiceType)
			SELECT
				CRA.IdRouteAssignment,
				RPD.Guide_Serie 'GuideSerie',
				RPD.Guide_Number 'GuideNumber',
				CONCAT(RPD.Guide_Serie, RPD.Guide_Number) 'Guide',
				DO.StatusOrderId 'GuideStatus',
				SO.OrderDescription 'GuideStatusDescription',
				SMD.ServiceCustomerName 'ClientName',
				'RETURN' 'ServiceType'
			FROM
				@CourierRouteAssignments CRA
				INNER JOIN
					[DeliveryBackOffice].[dbo].[ServiceManagement] SM WITH(NOLOCK)
					ON
						CRA.IdRouteAssignment = SM.IdPuRouteAssigment
						AND
						SM.RowStatus = 1
				INNER JOIN
					[DeliveryBackOffice].[dbo].[ServiceManagementDetail] SMD WITH(NOLOCK)
					ON
						SM.IdServiceManagement = SMD.ServiceManagement
						AND
						SMD.SubTypeServiceManagmentId IN (@ReturnServiceSubTypeId)
						AND
						SMD.RowStatus = 1
				INNER JOIN
					[DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD WITH(NOLOCK)
					ON
						SMD.IdServiceManagementDetail = RPD.ServiceManagementDetailId
						AND RPD.RowStatus=1
				INNER JOIN
					[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
					ON
						RPD.Guide_Serie = DO.Guide_Serie
						AND
						RPD.Guide_Number = DO.Guide_Number
				INNER JOIN
					[DeliveryBackOffice].[dbo].[StatusOrder] SO WITH(NOLOCK)
					ON
						DO.StatusOrderId = SO.StatusOrderId
				LEFT JOIN
					@FinalStatusOfGuide FSOG
					ON
						DO.StatusOrderId = FSOG.StatusOrderId
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[UnifiedRouteSettlement] URS WITH(NOLOCK)
					ON
						URS.RouteAssignmentId = CRA.IdRouteAssignment
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[UnifiedRouteSettlementDetail] URSD WITH(NOLOCK)
					ON
						URS.IdUnifiedRouteSettlement = URSD.UnifiedRouteSettlementId
						AND
						DO.Guide_Serie = URSD.GuideSerie
						AND
						DO.Guide_Number = URSD.GuideNumber
						AND
						URSD.RowStatus = 1
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[UnifiedRouteSettlementDetail] URSDOP WITH(NOLOCK)
					ON
						URS.IdUnifiedRouteSettlement = URSD.UnifiedRouteSettlementId
						AND
						DO.Guide_Serie = URSDOP.GuideSerie
						AND
						DO.Guide_Number = URSDOP.GuideNumber
						AND
						URSDOP.IsOpenProcess > 0
						AND
						URSDOP.UserProcess IS NOT NULL
						AND
						URSDOP.RowStatus = 0
			WHERE
				-- Que no este en estado terminal
				--FSOG.StatusOrderId IS NULL
				--AND
				-- Que no este liquidada en el proceso de las rutas actuales
				--URSD.IdUnifiedRouteSettlementDetail IS NULL
				--AND
				-- Que no este en un proceso abierto de las rutas actuales
				--URSDOP.IdUnifiedRouteSettlementDetail IS NULL
				URSD.IdUnifiedRouteSettlementDetail IS NULL
				OR NOT(URSD.RowStatus=1 AND URSD.IsOpenProcess IN (0,NULL))



			---GUÍAS DE RECOLECCIÓN PENDIENTES DE LIQUIDAR

			INSERT INTO @GuideList
				(RouteAssignmentId, GuideSerie, GuideNumber, Guide, GuideStatusId, GuideStatusDescription, ClientName, ServiceType)
			SELECT
				CRA.IdRouteAssignment,
				DOP.GuideSerie 'GuideSerie',
				DOP.GuideNumber 'GuideNumber',
				CONCAT(DOP.GuideSerie, DOP.GuideNumber) 'Guide',
				DO.StatusOrderId 'GuideStatus',
				SO.OrderDescription 'GuideStatusDescription',
				SP.SenderName 'ClientName',
				'PICKUP' 'ServiceType'
			FROM
				@CourierRouteAssignments CRA
				INNER JOIN
					[DeliveryBackOffice].[dbo].[ServiceManagement] SM WITH(NOLOCK)
					ON
						CRA.IdRouteAssignment = SM.IdPuRouteAssigment
						AND
						SM.RowStatus = 1
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[CatServiceStatus] CSS WITH(NOLOCK)
					ON
						SM.ServiceStatusId = CSS.IdServiceStatus
				INNER JOIN
					[DeliveryBackOffice].[dbo].[SchedulePickup] SP WITH(NOLOCK)
					ON
						SM.IdSchedulePickup = SP.SchedulePickupId
						AND
						SP.RowStatus = 1
				INNER JOIN DBO.DeliveryOrderPaymentDetail DOP WITH(NOLOCK) ON 
					DOP.IdHeaderRecolection=SP.SchedulePickupId
				INNER JOIN DBO.DeliveryOrder DO WITH(NOLOCK)
					ON DO.Guide_Number=DOP.GuideNumber
						AND DO.Guide_Serie=DOP.GuideSerie
				INNER JOIN
					[DeliveryBackOffice].[dbo].[StatusOrder] SO WITH(NOLOCK)
					ON
						DO.StatusOrderId = SO.StatusOrderId
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[UnifiedRouteSettlement] URS WITH(NOLOCK)
					ON
						URS.RouteAssignmentId = CRA.IdRouteAssignment
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[UnifiedRouteSettlementDetail] URSD WITH(NOLOCK)
					ON
						URS.IdUnifiedRouteSettlement = URSD.UnifiedRouteSettlementId
						AND
						URSD.ServiceManagementId = SM.IdServiceManagement
						AND
						URSD.RowStatus = 1
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[UnifiedRouteSettlementDetail] URSDOP WITH(NOLOCK)
					ON
						URS.IdUnifiedRouteSettlement = URSD.UnifiedRouteSettlementId
						AND
						URSD.ServiceManagementId = SM.IdServiceManagement
			WHERE 			
				(URSD.IdUnifiedRouteSettlementDetail IS NULL
				OR NOT(URSD.RowStatus=1 AND URSD.IsOpenProcess IN (0,NULL)))
				AND URS.UserSettlement IS NULL --FILTRO PARA LIQUIDACIONES PENDIENTES DE CERRAR


			-- Servicios de recolección pendientes de procesar
			INSERT INTO @ServiceList
				(RouteAssignmentId, ServiceManagementId, ServiceStatusId, ServiceStatusDescription, ClientName, ServiceType)
			SELECT
				CRA.IdRouteAssignment,
				SM.IdServiceManagement 'ServiceId',
				SM.ServiceStatusId 'StatusId',
				CSS.[Name] 'StatusDescription',
				SP.SenderName 'ClientName',
				'PICKUP' 'ServiceType'
			FROM
				@CourierRouteAssignments CRA
				INNER JOIN
					[DeliveryBackOffice].[dbo].[ServiceManagement] SM WITH(NOLOCK)
					ON
						CRA.IdRouteAssignment = SM.IdPuRouteAssigment
						AND
						SM.RowStatus = 1
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[CatServiceStatus] CSS WITH(NOLOCK)
					ON
						SM.ServiceStatusId = CSS.IdServiceStatus
				INNER JOIN
					[DeliveryBackOffice].[dbo].[SchedulePickup] SP WITH(NOLOCK)
					ON
						SM.IdSchedulePickup = SP.SchedulePickupId
						AND
						SP.RowStatus = 1
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[UnifiedRouteSettlement] URS WITH(NOLOCK)
					ON
						URS.RouteAssignmentId = CRA.IdRouteAssignment
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[UnifiedRouteSettlementDetail] URSD WITH(NOLOCK)
					ON
						URS.IdUnifiedRouteSettlement = URSD.UnifiedRouteSettlementId
						AND
						URSD.ServiceManagementId = SM.IdServiceManagement
						AND
						URSD.RowStatus = 1
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[UnifiedRouteSettlementDetail] URSDOP WITH(NOLOCK)
					ON
						URS.IdUnifiedRouteSettlement = URSD.UnifiedRouteSettlementId
						AND
						URSD.ServiceManagementId = SM.IdServiceManagement
						AND
						URSDOP.IsOpenProcess > 0
						AND
						URSDOP.UserProcess IS NOT NULL
						AND
						URSDOP.RowStatus = 0
			WHERE
				SM.ServiceStatusId IN (
					@GeneratedServiceStatusId
					, @OnRouteServiceStatusId
				)
				AND
				-- Que no este liquidada en el proceso de las rutas actuales
				URSD.IdUnifiedRouteSettlementDetail IS NULL
				AND
				-- Que no este en un proceso abierto de las rutas actuales
				URSDOP.IdUnifiedRouteSettlementDetail IS NULL
				AND URS.UserSettlement IS NULL

			IF ( 
				EXISTS ( SELECT TOP 1 1 FROM @GuideList ) 
				OR
				EXISTS ( SELECT TOP 1 1 FROM @ServiceList )
			)
			BEGIN

				UPDATE
					GL
				SET
					GL.ServiceTypeActions = ISNULL(( 
							SELECT STUFF(( 
								SELECT 
									',' + CABST.ActionName
								FROM
									[DeliveryBackOffice].[dbo].[CatActionByServiceType] CABST WITH(NOLOCK)
								WHERE
									GL.ServiceType = CABST.ServiceType
								FOR XML PATH(''), TYPE 
							) 
							.value('.', 'varchar(max)'),1,1,'' 
							)
						),'')
				FROM
					@GuideList GL

				UPDATE
					SL
				SET
					SL.ServiceTypeActions = ISNULL(( 
							SELECT STUFF(( 
								SELECT 
									',' + CABST.ActionName
								FROM
									[DeliveryBackOffice].[dbo].[CatActionByServiceType] CABST WITH(NOLOCK)
								WHERE
									SL.ServiceType = CABST.ServiceType
								FOR XML PATH(''), TYPE 
							) 
							.value('.', 'varchar(max)'),1,1,'' 
							)
						),'')
				FROM
					@ServiceList SL

				SELECT
					1 'CodeResponse',
					'Datos de ruta exitosamente obtenidos' 'Description'

				SELECT
					GL.RouteAssignmentId
					,GL.GuideSerie
					,GL.GuideNumber
					,GL.Guide 'Service'
					,GL.GuideStatusId 'ServiceStatusId'
					,GL.GuideStatusDescription 'ServiceStatusDescription'
					,GL.ServiceType
					,GL.ServiceTypeActions
					,GL.ClientName
				FROM
					@GuideList GL

				SELECT
					SL.RouteAssignmentId
					,SL.ServiceManagementId 'Service'
					,SL.ServiceStatusId
					,SL.ServiceStatusDescription
					,SL.ServiceType
					,SL.ServiceTypeActions
					,SL.ClientName
				FROM
					@ServiceList SL
		
			END
			ELSE
			BEGIN

			SELECT
				2 'CodeResponse',
				'Sin guías/servicios pendientes de operar' 'Description'

			END
		END
		ELSE
		BEGIN

			SELECT
				2 'CodeResponse',
				'Sin guías/servicios pendientes de operar' 'Description'

		END
	END TRY
	BEGIN CATCH

		SELECT
			0 'CodeResponse',
			'Error al tratar de obtener información de la ruta en la fecha indicada' 'Description' 

	END CATCH




END
-- =============================================
-- Author:		<Alberto Ixchop>
-- Create date: <30-09-2022>
-- Description:	<Carga de detalle de manifiestos de liquidación de rutas unificadas>
-- =============================================
CREATE PROCEDURE spHM_GetSettlementUnifiedRoutes
	@CUI NVARCHAR(25)
	,@Token NVARCHAR(50)
	,@Date AS DATE = NULL
	--@Date DATE
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;	
    DECLARE @TranCounter INT;  
    SET @TranCounter = @@TRANCOUNT;  
    IF @TranCounter > 0  
        SAVE TRANSACTION SPStartServiceRecolection
    ELSE  
        BEGIN TRANSACTION;  

	BEGIN TRY			
		IF @Date IS NULL
			SET @Date =GETDATE()
		DECLARE @IdSubTypeDelivery INT=(SELECT IdSubTypeServiceManagment from dbo.SubTypeServiceManagment where [Name] =  'Entrega');
		DECLARE @IdSubTypeReturn INT=(SELECT IdSubTypeServiceManagment from dbo.SubTypeServiceManagment where [Name] =  'Devolución');
		DECLARE @IdSubTypePickup INT=(SELECT IdSubTypeServiceManagment from dbo.SubTypeServiceManagment where [Name] =  'Recolección');
		DECLARE @IdCourier INT = (select ID from dbo.SenderReceiver SR where SR.CUI=@CUI);

		DECLARE @ORDERSTATUS_DELIVERED INT = (SELECT StatusOrderId FROM DBO.StatusOrder WHERE OrderDescription ='Entregado');
		DECLARE @ORDERSTATUS_RETURNED INT = (SELECT StatusOrderId FROM DBO.StatusOrder WHERE OrderDescription ='Devuelto');
		DECLARE @ORDERSTATUS_TRASLATE INT = (SELECT StatusOrderId FROM DBO.StatusOrder WHERE OrderDescription = 'Traslado a Express Center');
		DECLARE @ORDERSTATUS_TRASLATE_Del INT = (SELECT StatusOrderId FROM DBO.StatusOrder WHERE OrderDescription = 'Entregado En Express Center');
		DECLARE @ORDERSTATUS_TRASLATE_Ret INT = (SELECT StatusOrderId FROM DBO.StatusOrder WHERE OrderDescription = 'Devuelto en Express Center');

		DECLARE @GuidesToSettled TABLE (
			GuideSerie NVARCHAR(2),
			GuideNumber INT,
			PieceNumber INT,
			IdRouteAssigment INT,
			IdSubTypeServiceManagment INT,
			ServiceManagement INT,
			IdUnifiedRouteSettlementDetail INT,
			IsOpenProcess BIT,
			IsDry BIT,
			IsTransfer BIT
		);

		IF @IdCourier IS NULL
		BEGIN
				SELECT 0 AS 'StatusCode',
				'No se encontro un curier con el DPI ingresado' AS 'Description';
		END
		ELSE
		BEGIN
			SELECT			  
				1 AS 'StatusCode',
				'Registros obtenidos' AS 'Description';
			--------------------------------------------------------------------------------------------
			--Liquidando guias pendiente de liquidar(Solo guias de entrega, devolución y traslado )
			INSERT INTO @GuidesToSettled (
				GuideSerie,
				GuideNumber,
				PieceNumber,
				IdRouteAssigment,
				IdSubTypeServiceManagment,
				ServiceManagement,
				IdUnifiedRouteSettlementDetail,
				IsOpenProcess,
				IsDry,
				IsTransfer
			)
			SELECT 
				RPD.Guide_Serie,
				RPD.Guide_Number,
				DOP.NoPiece,
				RA.IdRouteAssigment,
				STSM.IdSubTypeServiceManagment,
				SMD.ServiceManagement,
				URSD.IdUnifiedRouteSettlementDetail,
				URSD.IsOpenProcess,
				IIF(DO.Pieces_Dry=1,1,0),
				ISNULL(TransferGuide.IsTraslate,0)
			FROM DBO.RouteAssigment RA
			INNER JOIN DBO.ServiceManagement SM 
				ON SM.IdPuRouteAssigment=RA.IdRouteAssigment
			INNER JOIN DBO.ServiceManagementDetail SMD 
				ON SMD.ServiceManagement=SM.IdServiceManagement		
			INNER JOIN DBO.SubTypeServiceManagment STSM 
				ON SMD.SubTypeServiceManagmentId=STSM.IdSubTypeServiceManagment
			INNER JOIN DBO.RoutePreparationDetail RPD 
				ON RPD.ServiceManagementDetailId=SMD.IdServiceManagementDetail
			INNER JOIN DBO.DeliveryOrderPiece DOP ON
				DOP.GuideSerie=RPD.Guide_Serie
				AND DOP.GuideNumber= RPD .Guide_Number
			INNER JOIN DBO.DeliveryOrder DO ON 
				DO.Guide_Serie=DOP.GuideSerie
				AND DO.Guide_Number=DOP.GuideNumber				
			LEFT JOIN DBO.UnifiedRouteSettlementDetail URSD ON 		
				URSD.GuideSerie=RPD.Guide_Serie
				AND URSD.GuideNumber=RPD.Guide_Number
				AND URSD.RowStatus=1
			LEFT JOIN DBO.UnifiedRouteSettlement URS ON URS.IdUnifiedRouteSettlement=URSD.UnifiedRouteSettlementId
			OUTER APPLY (
				SELECT TOP 1 1 'IsTraslate' 
				FROM DBO.DeliveryOrderDetail DOD
				WHERE DOD.Guide_Serie= RPD.Guide_Serie
					AND DOD.Guide_Number =RPD.Guide_Number
					AND DOD.StatusOrderId IN (@ORDERSTATUS_TRASLATE,@ORDERSTATUS_TRASLATE_Del,@ORDERSTATUS_TRASLATE_Ret)
					AND DOD.RowStatus=1
			) TransferGuide
			WHERE 
				--AND 
				RA.RowStatus=1		
				AND RA.IdVehicle IS NOT NULL
				AND RA.IdRoute IS NOT NULL		
				AND RA.IdCurrierMan=@IdCourier
				--FILTRANDO GUIAS PENDIENTES DE LIQUIDAR (NO SE TOMAN EN CUENTA AQUELLOS QUE TIENEN PROCESO ABIERTO)
				AND
					URSD.IdUnifiedRouteSettlementDetail IS NULL
				AND(
					--FILTRANDO  GUIAS EN ESTADO EXITOSO
					DO.StatusOrderId IN (@ORDERSTATUS_DELIVERED,@ORDERSTATUS_RETURNED)
					OR TransferGuide.IsTraslate = 1
				)
				AND RA.DateOfRoute =@Date
			

			------Buscar guias las cuales el routeassigment no estan asociados a un UnifiedrouteSettlement
			------Insertar en UnifiedRouteSettlement los route assigment encontrados anteriormente
			INSERT INTO [dbo].[UnifiedRouteSettlement]
						([RouteAssignmentId]
						,[TotalGuidesSettled]
						,[TotalPiecesSettled]
						,[TotalPiecesMissing]
						,[UserSettlement]
						,[DateSettlement]
						,[SettlementStation]
						,[TotalCODGuidesSettled]
						,[UserCODSettlement]
						,[DateCODSettlement]
						,[CODSettlementStation]
						,[RowStatus]
						,[TokenCreated]
						,[DateCreated]
						,[TokenUpdated]
						,[DateUpdated])
			SELECT 
				IdRouteAssigment,
				COUNT(DISTINCT CHECKSUM(GTS.GuideSerie,GTS.GuideNumber)),
				COUNT(DISTINCT CHECKSUM(GTS.GuideSerie,GTS.GuideNumber,GTS.PieceNumber)),
				0,
				NULL,
				NULL,
				NULL,
				0,
				NULL,
				NULL,
				NULL,
				1,
				@Token,
				GETDATE(),
				NULL,
				NULL
			FROM @GuidesToSettled GTS
			WHERE GTS.IdRouteAssigment IS NULL
			GROUP BY GTS.IdRouteAssigment;


			--------Insertar en UnifiedRouteSettlementDetail las guías que no estan liquidadas
			INSERT INTO [dbo].[UnifiedRouteSettlementDetail]
						([UnifiedRouteSettlementId]
						,[ServiceManagementId]
						,[GuideSerie]
						,[GuideNumber]
						,[PiecesSettled]
						,[PiecesMissing]
						,[ServiceSettlementAmount]
						,[ServiceCODSettlementAmount]
						,[UserSettlement]
						,[DateSettlement]
						,[UserCODSettlement]
						,[DateCODSettlement]
						,[IsOpenProcess]
						,[UserProcess]
						,[IsArrival]
						,[IsReturn]
						,[IsDelivered]
						,[IsTransfered]
						,[RowStatus]
						,[TokenCreated]
						,[DateCreated]
						,[TokenUpdated]
						,[DateUpdated])
			SELECT
				URS.IdUnifiedRouteSettlement,--([UnifiedRouteSettlementId]
				GTS.ServiceManagement,		--ServiceManagementId
				GTS.GuideSerie,				--[GuideSerie]
				GTS.GuideNumber,
				COUNT(DISTINCT CHECKSUM(GTS.GuideSerie,GTS.GuideNumber,GTS.PieceNumber)),
				0,
				SUM(SM.Amount),
				0,
				@Token,
				GETDATE(),
				NULL,
				NULL,
				0,
				NULL,
				0,
				0,
				0,
				0,
				1,
				@Token,
				GETDATE(),
				NULL,
				NULL
			FROM @GuidesToSettled GTS
				INNER JOIN UnifiedRouteSettlement URS ON
					URS.RouteAssignmentId=GTS.IdRouteAssigment
				INNER JOIN ServiceManagement SM ON
					SM.IdServiceManagement=GTS.ServiceManagement
			GROUP BY URS.IdUnifiedRouteSettlement,
				GTS.ServiceManagement,		
				GTS.GuideSerie,				
				GTS.GuideNumber;
				


			INSERT INTO [dbo].[UnifiedRouteSettlementDetailPiece]
					   ([UnifiedRouteSettlementDetailId]
					   ,[PieceNumber]
					   ,[IsDryPiece]
					   ,[ActCode]
					   ,[RowStatus]
					   ,[TokenCreated]
					   ,[DateCreated]
					   ,[TokenUpdated]
					   ,[DateUpdated])
			SELECT
				URSD.IdUnifiedRouteSettlementDetail,
				GTS.PieceNumber,
				GTS.IsDry,
				AD.ActId,
				1,
				@Token,
				GETDATE(),
				NULL,
				NULL
			FROM @GuidesToSettled GTS
				INNER JOIN UnifiedRouteSettlement URS ON
					URS.RouteAssignmentId=GTS.IdRouteAssigment
				INNER JOIN DBO.UnifiedRouteSettlementDetail URSD ON
					URSD.UnifiedRouteSettlementId=URS.IdUnifiedRouteSettlement
				INNER JOIN ServiceManagement SM ON
					SM.IdServiceManagement=GTS.ServiceManagement
				LEFT JOIN DBO.ActDetail AD ON
					AD.GuideSerie=GTS.GuideSerie
					AND AD.GuideNumber=GTS.GuideNumber
			WHERE GTS.IdUnifiedRouteSettlementDetail IS NULL --GUIAS SIN IDROUTEASSIGMENTE EN TABLA URS(UnifiedRouteSettlement)
			GROUP BY 
				URSD.IdUnifiedRouteSettlementDetail,
				GTS.PieceNumber,
				GTS.IsDry,
				AD.ActId;


			--ACTUALIZANDO CONTADORES DE UnifiedRouteSettlement			
			UPDATE URS SET
				URS.TotalGuidesSettled =SUB_1.TotalGuides,
				URS.TotalPiecesSettled =SUB_1.TotalPieces
			FROM DBO.UnifiedRouteSettlement URS
			INNER JOIN (
				SELECT 
					URSD.UnifiedRouteSettlementId 'UnifiedRouteSettlementId',
					COUNT(DISTINCT CHECKSUM(URSD.GuideSerie,URSD.GuideNumber)) 'TotalGuides',
					COUNT(DISTINCT CHECKSUM(URSD.GuideSerie,URSD.GuideNumber,URSDP.PieceNumber))'TotalPieces'
				FROM @GuidesToSettled GTS
					INNER JOIN DBO.UnifiedRouteSettlementDetail URSD
						ON URSD.GuideSerie = GTS.GuideSerie
						AND URSD.GuideNumber = GTS.GuideNumber
					INNER JOIN DBO.UnifiedRouteSettlementDetailPiece URSDP
						ON URSDP.UnifiedRouteSettlementDetailId=URSD.IdUnifiedRouteSettlementDetail
					GROUP BY URSD.UnifiedRouteSettlementId				
			)SUB_1 ON SUB_1.UnifiedRouteSettlementId=URS.IdUnifiedRouteSettlement
				
			----------------------------------------------------------------------------------------------
			----Realizando la liquidación en el antiguo flujo por medio de las tablas DeliveryOrderBySettlement y DeliverySettlementDetail
			--	-->Liquidando guias de entrega						
				UPDATE DSD SET 
					Settlement_Collect_OnDelivery = URSD.ServiceSettlementAmount, 
					SettlementCollect_TokenCreated = @Token, 
					SettlementCollect_DateCreated = GETDATE(), 
					Guide_Settlement = 0, -- guía liquidada en bodega
					Guide_Returned = 0,  -- guía liquidada vía material devuelto
					Guide_Delivered = 0  -- guía liquidada vía comprobante de entrega
				FROM [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] DSD
				INNER JOIN @GuidesToSettled GTS ON DSD.Guide_Serie=GTS.GuideSerie AND DSD.Guide_Number=GTS.GuideNumber
				INNER JOIN DBO.UnifiedRouteSettlementDetail URSD ON GTS.IdUnifiedRouteSettlementDetail=URSD.IdUnifiedRouteSettlementDetail
				WHERE GTS.IdSubTypeServiceManagment =@IdSubTypeDelivery
					--AND GTS.IsTransfer = 0 
					--Si son traslados o entregas se liquidan 
			---->Liquidando guías de devolución
				update DeliveryBackOffice.dbo.SettlementByPickupDetail
				set TokenUpdated = @Token,
					DateUpdated = GETDATE(),
					IsPieceLiquidaded = 1
				from DeliveryBackOffice.dbo.SettlementByPickup stp         
					join DeliveryBackOffice.dbo.SettlementByPickupDetail spd on stp.Id = spd.SettlementByPickupId
					INNER JOIN @GuidesToSettled GTS ON spd.GuideSerie=GTS.GuideSerie AND spd.GuideNumber=GTS.GuideNumber
					INNER JOIN DBO.UnifiedRouteSettlementDetail URSD ON GTS.IdUnifiedRouteSettlementDetail=URSD.IdUnifiedRouteSettlementDetail
				where GTS.IdSubTypeServiceManagment = @IdSubTypeReturn
					--AND GTS.IsTransfer = 0--FILTRANDO TRASLADO
			---->Liquidando guías trasladadas

			----------------------------------------------------------------------------------------------
			----ACTUALIZANDO ESTADO DE SERVICIOS
			DECLARE @StatusServiceDelivered INT = (SELECT IdServiceStatus FROM DBO.CatServiceStatus where Name ='Entregado ' );
			DECLARE @StatusServiceReturned INT = (SELECT IdServiceStatus FROM DBO.CatServiceStatus where Name ='Devuelto ' );			

			--	--> Actualizando servicios de guías entregadas/trasladadas
				UPDATE SM SET 
					ServiceStatusId=@StatusServiceDelivered
				FROM DBO.ServiceManagement SM
				INNER JOIN @GuidesToSettled GTS ON GTS.ServiceManagement=SM.IdServiceManagement
				where GTS.IdSubTypeServiceManagment=@IdSubTypeDelivery
				AND GTS.IsTransfer=0

				INSERT INTO [dbo].[EventService]
						   ([ServiceManagementId]
						   ,[ServiceStatusId]
						   ,[RowStauts]
						   ,[TokenCreated]
						   ,[DateCreated]
						   ,[Observations])
				SELECT
						   GTS.ServiceManagement
						   ,@IdSubTypeDelivery
						   ,1
						   ,@Token
						   ,GETDATE()
						   ,'Actualización de estado desde spHM_GetSettlementUnifiedRoutes'
				FROM @GuidesToSettled GTS 
				where GTS.IdSubTypeServiceManagment=@IdSubTypeDelivery
				--AND GTS.IsTransfer=0
				GROUP BY GTS.ServiceManagement;


			--	--> ACtualizando serivicos de guías devueltas
				UPDATE SM SET 
					ServiceStatusId=@StatusServiceReturned
				FROM DBO.ServiceManagement SM
				INNER JOIN @GuidesToSettled GTS ON GTS.ServiceManagement=SM.IdServiceManagement
				where GTS.IdSubTypeServiceManagment=@IdSubTypeReturn
				AND GTS.IsTransfer=0

				INSERT INTO [dbo].[EventService]
						   ([ServiceManagementId]
						   ,[ServiceStatusId]
						   ,[RowStauts]
						   ,[TokenCreated]
						   ,[DateCreated]
						   ,[Observations])
				SELECT
						   GTS.ServiceManagement
						   ,@IdSubTypeReturn
						   ,1
						   ,@Token
						   ,GETDATE()
						   ,'Actualización de estado desde spHM_GetSettlementUnifiedRoutes'
				FROM @GuidesToSettled GTS 
				where GTS.IdSubTypeServiceManagment=@IdSubTypeReturn
				AND GTS.IsTransfer=0
				GROUP BY GTS.ServiceManagement;

			

			SELECT 
				DOPD.GuideSerie 'GuideSerie',
				DOPD.GuideNumber 'GuideNumber',
				DOP.IsDry 'IsDry',
				DOP.NoPiece 'NumberPiece',
				CONCAT(DOPD.GuideSerie,CAST(DOPD.GuideNumber AS NVARCHAR(100))) 'Guide',
				STSM.IdSubTypeServiceManagment 'IdTypeService',
				STSM.[Name] 'NameTypeService',
				CAST(IIF(URSD.RowStatus=1 AND URSD.IsOpenProcess=0,1,0) AS BIT) 'Settlement',
				ISNULL(AD.ActId,0) 'ActId',
				NULL 'IdSettlement'
			FROM DBO.RouteAssigment RA 
			INNER JOIN DBO.ServiceManagement SM 
				ON SM.IdPuRouteAssigment=RA.IdRouteAssigment
				AND SM .RowStatus=1
			INNER JOIN DBO.ServiceManagementDetail SMD
				ON SMD.ServiceManagement=SM.IdServiceManagement
			INNER JOIN DBO.SubTypeServiceManagment STSM 
				ON SMD.SubTypeServiceManagmentId=STSM.IdSubTypeServiceManagment
			INNER JOIN DBO.SchedulePickup SP
				ON SM.IdSchedulePickup= SP.SchedulePickupId
				AND SP.RowStatus=1
			INNER JOIN DBO.DeliveryOrderPaymentDetail DOPD
				ON DOPD.IdHeaderRecolection=SP.SchedulePickupId
			INNER JOIN DBO.DeliveryOrderPiece DOP WITH (NOLOCK)
				ON DOP.GuideSerie=DOPD.GuideSerie
				AND DOP.GuideNumber=DOPD.GuideNumber
			LEFT JOIN DBO.UnifiedRouteSettlementDetail URSD ON 		
				URSD.GuideSerie=DOPD.GuideSerie
				AND URSD.GuideNumber=DOPD.GuideNumber
				AND URSD.RowStatus=1
			LEFT JOIN DBO.UnifiedRouteSettlement URS ON URSD.UnifiedRouteSettlementId=URS.IdUnifiedRouteSettlement
			LEFT JOIN DBO.ActDetail AD ON
				AD.GuideSerie=DOPD.GuideSerie
				AND AD.GuideNumber=DOPD.GuideNumber
			WHERE 
				RA.RowStatus=1		
				AND RA.IdVehicle IS NOT NULL
				AND RA.IdRoute IS NOT NULL		
				AND RA.IdCurrierMan=@IdCourier--@CUI
				AND URS.UserSettlement IS NULL --FILTRO PARA LIQUIDACIONES PENDIENTES DE CERRAR
				AND RA.DateOfRoute =@Date
			GROUP BY 
				STSM.IdSubTypeServiceManagment,
				STSM.Name,
				DOPD.GuideSerie,
				DOPD.GuideNumber,
				SMD.ServiceManagement,
				URSD.RowStatus,
				URSD.IsOpenProcess,
				DOP.IsDry,				
				DOP.NoPiece,
				AD.ActId
			UNION 
			SELECT 
						RPD.Guide_Serie 'GuideSerie',
						RPD.Guide_Number 'GuideNumber',
						DOP.IsDry 'IsDry',
						DOP.NoPiece 'NumberPiece',
						CONCAT(RPD.Guide_Serie,CAST(RPD.Guide_Number AS NVARCHAR(100))) 'Guide',
						STSM.IdSubTypeServiceManagment 'IdTypeService',
						STSM.[Name] 'NameTypeService',
						CAST(IIF(URSD.RowStatus=1 AND URSD.IsOpenProcess=0,1,0) AS BIT) 'Settlement',
						ISNULL(AD.ActId,0) 'ActId',
						IIF(STSM.IdSubTypeServiceManagment=2,DSETTD.ID_DeliveryOrderBySettlement,sbp.Id) 'IdSettlement'
			FROM DBO.RouteAssigment RA 
			INNER JOIN DBO.ServiceManagement SM 
				ON SM.IdPuRouteAssigment=RA.IdRouteAssigment
			INNER JOIN DBO.ServiceManagementDetail SMD 
				ON SMD.ServiceManagement=SM.IdServiceManagement		
			INNER JOIN DBO.SubTypeServiceManagment STSM 
				ON SMD.SubTypeServiceManagmentId=STSM.IdSubTypeServiceManagment
			INNER JOIN DBO.RoutePreparationDetail RPD 
				ON RPD.ServiceManagementDetailId=SMD.IdServiceManagementDetail
			INNER JOIN DBO.DeliveryOrderPiece DOP WITH (NOLOCK)
				ON DOP.GuideSerie=RPD.Guide_Serie
				AND DOP.GuideNumber=RPD.Guide_Number
			LEFT JOIN DBO.UnifiedRouteSettlementDetail URSD ON 		
				URSD.GuideSerie=RPD.Guide_Serie
				AND URSD.GuideNumber=RPD.Guide_Number
				AND URSD.RowStatus=1
			LEFT JOIN DBO.UnifiedRouteSettlement URS ON URSD.UnifiedRouteSettlementId=URS.IdUnifiedRouteSettlement
			LEFT JOIN DBO.ActDetail AD ON
				AD.GuideSerie=RPD.Guide_Serie
				AND AD.GuideNumber=RPD.Guide_Number
			LEFT JOIN DBO.DeliverySettlementDetail DSETTD ON 
				DSETTD.Guide_Serie=RPD.Guide_Serie
				AND DSETTD.Guide_Number=RPD.Guide_Number
			LEFT JOIN dbo.SettlementByPickup sbp ON
				sbp.RouteAssigmentId=RA.IdRouteAssigment
			WHERE 
				RA.RowStatus=1		
				AND RA.IdVehicle IS NOT NULL
				AND RA.IdRoute IS NOT NULL		
				AND RA.IdCurrierMan=@IdCourier--@CUI
				AND URS.UserSettlement IS NULL --FILTRO PARA LIQUIDACIONES PENDIENTES DE CERRAR
				AND RA.DateOfRoute =@Date
			GROUP BY 
				STSM.IdSubTypeServiceManagment,
				STSM.Name,
				RPD.Guide_Serie,
				RPD.Guide_Number,
				SMD.ServiceManagement,
				URSD.RowStatus,
				URSD.IsOpenProcess,
				DOP.IsDry,				
				DOP.NoPiece,
				AD.ActId,
				DSETTD.ID_DeliveryOrderBySettlement,
				sbp.Id

		END



	
		IF @TranCounter = 0  
            COMMIT TRANSACTION; 		
	END TRY
	BEGIN CATCH
        IF @TranCounter = 0  
            ROLLBACK TRANSACTION;  
        ELSE IF XACT_STATE() <> -1  
                ROLLBACK TRANSACTION SPStartServiceRecolection;  
		SELECT			  
			0 AS 'StatusCode',
			ERROR_MESSAGE() AS 'Description';
	END CATCH




END
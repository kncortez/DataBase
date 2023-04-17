-- =============================================
-- Author:		<Alberto Ixchop>     
-- Create date: <03-10-2022>
-- Description:	<Cierre de proceso de liquidación de ruta unificada>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_ClosureSettlementUnifiedRoutes]
	@CUI NVARCHAR(25),
	@Token NVARCHAR(50),
	@Date AS DATE = NULL
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @IDCOURIER INT = (SELECT ID FROM DBO.SenderReceiver WHERE CUI=@CUI)

	DECLARE @TranCounter INT;  
    SET @TranCounter = @@TRANCOUNT;  
    IF @TranCounter > 0  
        SAVE TRANSACTION SPClosureSettlementUnifiedRoutes
    ELSE  
	BEGIN TRANSACTION;  

	BEGIN TRY

	DECLARE @TOTALGUIDESRECO INT = 0;
	DECLARE @TOTALGUIDESDL INT = 0;

	--CONTADORES RECOLECCIONES
	DECLARE @COUNTGUIDESNOTLIQUIDED_PU INT = 0;
	DECLARE @COUNTGUIDESNOTRECOLECTED_PU INT = 0;
	DECLARE @COUNTSERVICESWITHINCIDENCE_PU INT = 0;

	--MESSAGE ERROR VARIABLE
	DECLARE @MESSAGEERROR NVARCHAR(600)='';

	DECLARE @ALLOK BIT =1;--Bandera que indica que todas las validaciones son correctas

	--ID STATUS VARIABLES
	DECLARE @STATUSSCHCOLLECTED_DO INT = (SELECT StatusOrderId FROM DBO.StatusOrder WHERE OrderDescription = 'Programado para recolección');
	DECLARE @STATUSCOLLECTED_DO INT = (SELECT StatusOrderId FROM DBO.StatusOrder WHERE OrderDescription = 'Recolectado');
	DECLARE @STATUSINCIDENCE_SM INT = (SELECT IdServiceStatus FROM DBO.CatServiceStatus CS WHERE CS.Name= 'Incidencia');
	DECLARE @STATUSDELIVERED_DO INT = (SELECT StatusOrderId FROM DBO.StatusOrder WHERE OrderDescription = 'Entregado');
	DECLARE @STATUSRETURNED_DO INT = (SELECT StatusOrderId FROM DBO.StatusOrder WHERE OrderDescription = 'Devuelto');
	DECLARE @STATUSINROUTE INT = (SELECT StatusOrderId FROM DBO.StatusOrder WHERE OrderDescription = 'En ruta');
	DECLARE @STATUSFAILED_DO INT = (SELECT StatusOrderId FROM dbo.StatusOrder WITH (NOLOCK) WHERE OrderDescription = 'Intento de entrega fallida');
	DECLARE @STATUSARRIVAL_DO INT = (SELECT StatusOrderId FROM DBO.StatusOrder WHERE OrderDescription = 'Arribó a las instalaciones');
	DECLARE @RETURNEDTOFORZA_DO INT = (SELECT StatusOrderId FROM dbo.StatusOrder WITH (NOLOCK) WHERE OrderDescription = 'Paquete Retornado para Reproceso');
	DECLARE @STATUSLOST_DO INT = (SELECT StatusOrderId FROM dbo.StatusOrder WITH (NOLOCK) WHERE OrderDescription = 'Paquete Extraviado');

	DECLARE @STATUSTRANSFER_DO INT = (SELECT StatusOrderId FROM DBO.StatusOrder WITH (NOLOCK) WHERE OrderDescription ='Traslado a Express Center');

	DECLARE @IdSubTypeDelivery INT=(SELECT IdSubTypeServiceManagment from dbo.SubTypeServiceManagment where [Name] =  'Entrega');
	DECLARE @IdSubTypeRecollection INT=(SELECT IdSubTypeServiceManagment from dbo.SubTypeServiceManagment where [Name] =  'Recolección');
	DECLARE @IdSubTypeReturn INT=(SELECT IdSubTypeServiceManagment from dbo.SubTypeServiceManagment where [Name] =  'Devolución');

	IF @Date IS NULL
		SET @Date =GETDATE()


	
	DECLARE @HasSettled BIT =NULL;
	SELECT TOP 1 @HasSettled= IIF(URS.UserSettlement IS NULL,0,1) FROM DBO.RouteAssigment RA WITH(NOLOCK) 
		LEFT JOIN DBO.UnifiedRouteSettlement URS WITH(NOLOCK)
			ON URS.RouteAssignmentId=RA.IdRouteAssigment
	WHERE RA.IdCurrierMan=@IDCOURIER
	AND RA.DateOfRoute = @Date
	ORDER BY URS.DateCreated DESC

	--NULL, SIN RUTAS QUE CERRAR
	--1 LA LIQUIDACIÓN YA FUE CERRADA
	--0 LA LIQUIDACIÓN AUN NO SE HA CERRADO

	IF @HasSettled IS NULL
	BEGIN 
			SELECT			  
				0 AS 'StatusCode',
				'No hay servicios/guías liquidados para realizar el cierre' AS 'Description';	
	END
	ELSE IF @HasSettled =1
	BEGIN
			SELECT			  
				2 AS 'StatusCode',
				'La liquidación ya fue cerrada' AS 'Description';	
			--TABLA 1
			--Listando los manifiestos del todos los cierres realizados
			SELECT URS.IdUnifiedRouteSettlement 'URSID' FROM DBO.UnifiedRouteSettlement URS  WITH(NOLOCK) 
				INNER JOIN DBO.RouteAssigment RA  WITH(NOLOCK) ON 
					RA.IdRouteAssigment=URS.RouteAssignmentId
			WHERE RA.IdCurrierMan=@IDCOURIER AND RA.DateOfRoute=@Date;

	END
	ELSE IF @HasSettled =0
	BEGIN 
	

		--- Tabla donde se guarda las guías a liquidar
		DECLARE @AllGuidesSettled TABLE (		
			GuideSerie NVARCHAR(2),
			GuideNumber INT,
			PieceNumber INT,
			IdUnifiedRouteSettlementDetailPiece INT,
			IdUnifiedRouteSettlementDetail INT,
			IdUnifiedRouteSettlement INT,
			SubTypeServiceManagmentId INT
		);
		DECLARE @ManifestList TABLE (		
			URSID INT
		);
		INSERT INTO @ManifestList
			SELECT URS.IdUnifiedRouteSettlement 'URSID' FROM DBO.UnifiedRouteSettlement URS  WITH(NOLOCK) 
				INNER JOIN DBO.RouteAssigment RA WITH(NOLOCK)  ON 
					RA.IdRouteAssigment=URS.RouteAssignmentId
			WHERE RA.IdCurrierMan=@IDCOURIER AND RA.DateOfRoute=@Date
			AND URS.UserSettlement IS NULL;

		DECLARE @EXISTGUIDES BIT =0;
		----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		--INICIO VALIDACIÓN DE GUÍAS Y SERVICIOS DE RECOLECCIÓN
		----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
		SELECT 
			@COUNTGUIDESNOTLIQUIDED_PU=COUNT(DISTINCT CASE WHEN URSD.UnifiedRouteSettlementId IS NULL  OR NOT(URSD.RowStatus=1 AND URSD.IsOpenProcess IN (0,NULL)) THEN DO.Guide_Number ELSE NULL END)--CANTIDAD DE GUÍAS SIN LIQUIDAR
			,@COUNTGUIDESNOTRECOLECTED_PU=SUM(CASE WHEN DO.StatusOrderId NOT IN (@STATUSCOLLECTED_DO,@STATUSSCHCOLLECTED_DO) THEN 1 ELSE 0 END) --CANTIDAD DE GUIAS DE RECOLECCIÓN QUE NO ESTAN EN ESTADO RECOLECTADO
			,@COUNTSERVICESWITHINCIDENCE_PU=SUM(CASE WHEN SM.ServiceStatusId=@STATUSINCIDENCE_SM THEN 1 ELSE 0 END) --CANTIDAD DE SERVICIOS CON INCIDENCIA
			,@TOTALGUIDESRECO = COUNT(DISTINCT CHECKSUM(DO.Guide_Number,DO.Guide_Serie))
		FROM RouteAssigment RA WITH(NOLOCK) 
		INNER JOIN DBO.ServiceManagement SM  WITH(NOLOCK) 
			ON SM.IdPuRouteAssigment=RA.IdRouteAssigment
			AND SM .RowStatus=1
		--INNER JOIN DBO.ServiceManagementDetail SMD
			--ON SMD.ServiceManagement=SM.IdServiceManagement
		INNER JOIN DBO.SchedulePickup SP WITH(NOLOCK) 
			ON SM.IdSchedulePickup= SP.SchedulePickupId
			AND SP.RowStatus=1
		INNER JOIN DBO.DeliveryOrderPaymentDetail DOPD WITH(NOLOCK) 
			ON DOPD.IdHeaderRecolection=SP.SchedulePickupId
		INNER JOIN DBO.DeliveryOrder DO WITH (NOLOCK)
			ON DO.Guide_Serie=DOPD.GuideSerie
			AND DO.Guide_Number=DOPD.GuideNumber
		LEFT JOIN DBO.UnifiedRouteSettlement URS  WITH(NOLOCK) ON 		
			URS.RouteAssignmentId=RA.IdRouteAssigment
		LEFT JOIN DBO.UnifiedRouteSettlementDetail URSD  WITH(NOLOCK) ON 		
			URSD.GuideSerie=DOPD.GuideSerie
			AND URSD.GuideNumber=DOPD.GuideNumber
			AND URSD.RowStatus=1
			AND URS.IdUnifiedRouteSettlement=URSD.UnifiedRouteSettlementId
		WHERE 
			RA.RowStatus=1		
			--AND RA.IdVehicle IS NOT NULL
			AND RA.IdRoute IS NOT NULL		
			AND RA.IdCurrierMan=@IDCOURIER--@CUI
			AND URS.UserSettlement IS NULL --FILTRO PARA LIQUIDACIONES PENDIENTES DE CERRAR
			AND RA.DateOfRoute=@Date
			AND DO.Guide_Number NOT IN (3698645,3701496)
	
		IF @TOTALGUIDESRECO IS NOT NULL AND @TOTALGUIDESRECO>0
		BEGIN
			IF @COUNTGUIDESNOTLIQUIDED_PU  IS NULL OR @COUNTGUIDESNOTLIQUIDED_PU >0 
			BEGIN
				SET @ALLOK=0;
				SET @MESSAGEERROR= CONCAT(@MESSAGEERROR,'Existen  ' , CONVERT(NVARCHAR(10),@COUNTGUIDESNOTLIQUIDED_PU),' guías de recolección pendientes de liquidar ', CHAR(13) )
			END
			IF @COUNTGUIDESNOTRECOLECTED_PU IS NULL OR @COUNTGUIDESNOTRECOLECTED_PU >0 
			BEGIN
				SET @ALLOK=0;
				SET @MESSAGEERROR= CONCAT(@MESSAGEERROR,'Existen ',CONVERT(NVARCHAR(10),@COUNTGUIDESNOTRECOLECTED_PU),' guías de recolección que aún no se han recolectado', CHAR(13) )
			END	
			IF @COUNTSERVICESWITHINCIDENCE_PU IS NULL OR @COUNTSERVICESWITHINCIDENCE_PU >0 
			BEGIN
				SET @ALLOK=0;
				SET @MESSAGEERROR= CONCAT(@MESSAGEERROR,'Existen ',CONVERT(NVARCHAR(10),@COUNTSERVICESWITHINCIDENCE_PU),' servicios de recolección con incidencia'+ CHAR(13) )
			END	
		END
		ELSE
		BEGIN
			SET @EXISTGUIDES = IIF(@EXISTGUIDES=1,1,0)
		END
	
		IF @EXISTGUIDES=1
		BEGIN
			SET @ALLOK=0;
			SET @MESSAGEERROR= 'No se encontraron guías asociadas al courier'
		END

		----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		--FIN VALIDACIÓN DE GUÍAS Y SERVICIOS DE RECOLECCIÓN
		----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		--INICIO VALIDACIÓN DE GUÍAS Y SERVICIOS DE ENTREGA Y DEVOLUCIÓN
		----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		--CONTADORES ENTREGA Y DEVOLUCIONES
		DECLARE @GUIDESCOUNTNOTLIQUIDED_DL INT = 0;
		DECLARE @GUIDESCOUNTNOTDELIVERED_DL INT = 0;
		DECLARE @SERVICESCOUNTWITHINCIDENCE_DL INT = 0;
		DECLARE @DELIVERYFAILEDCOUNT_DL INT = 0;
		SELECT 
			@GUIDESCOUNTNOTLIQUIDED_DL=COUNT(DISTINCT CASE WHEN URSD.UnifiedRouteSettlementId IS NULL OR  NOT(URSD.RowStatus=1 AND URSD.IsOpenProcess IN (0,NULL)) THEN DO.Guide_Number ELSE NULL END)--CANTIDAD DE GUÍAS SIN LIQUIDAR
			,@GUIDESCOUNTNOTDELIVERED_DL=SUM(CASE WHEN DO.StatusOrderId NOT IN (@STATUSDELIVERED_DO,@STATUSRETURNED_DO,@STATUSFAILED_DO,@STATUSLOST_DO,@STATUSTRANSFER_DO) THEN 1 ELSE 0 END) --CANTIDAD DE GUIAS DE ENTREGA/RECOLECCIÓN QUE NO ESTAN EN ESTADO DE ENTREGA O DEVUELTO, INTENTO DE ENTREGA FALLIDO
			,@SERVICESCOUNTWITHINCIDENCE_DL=SUM(CASE WHEN SM.ServiceStatusId=@STATUSINCIDENCE_SM THEN 1 ELSE 0 END) --CANTIDAD DE SERVICIOS CON INCIDENCIA
			--,@DELIVERYFAILEDCOUNT_DL=COUNT(DISTINCT CASE WHEN DOD.StatusCheckpoint =@STATUSFAILED_DO THEN CHECKSUM(DOD.StatusCheckpoint,DO.Guide_Number,DO.Guide_Serie) ELSE NULL END)--CANTIDAD DE GUÍAS CON CHECKPOINT ACTUAL COMO INTENTO DE ENTREGA FALLIDA
			,@TOTALGUIDESDL = COUNT(DISTINCT CHECKSUM(DO.Guide_Number,DO.Guide_Serie))
		FROM RouteAssigment RA  WITH(NOLOCK) 
		INNER JOIN DBO.ServiceManagement SM  WITH(NOLOCK) 
			ON SM.IdPuRouteAssigment=RA.IdRouteAssigment
		INNER JOIN DBO.ServiceManagementDetail SMD  WITH(NOLOCK) 
			ON SMD.ServiceManagement=SM.IdServiceManagement		
		INNER JOIN DBO.RoutePreparationDetail RPD  WITH(NOLOCK) 
			ON RPD.ServiceManagementDetailId=SMD.IdServiceManagementDetail
			AND RPD.RowStatus=1
		LEFT JOIN DBO.DeliveryOrder DO WITH (NOLOCK)
			ON DO.Guide_Serie=RPD.Guide_Serie
			AND DO.Guide_Number=RPD.Guide_Number
		OUTER APPLY (
			SELECT TOP 1 StatusOrderId 'StatusCheckpoint'  FROM DBO.DeliveryOrderDetail WITH(NOLOCK) 
			WHERE Guide_Serie=RPD.Guide_Serie
			AND Guide_Number=RPD.Guide_Number
			ORDER BY DateCreated DESC
		) DOD		
		LEFT JOIN DBO.UnifiedRouteSettlement URS  WITH(NOLOCK) ON 		
			URS.RouteAssignmentId=RA.IdRouteAssigment
		LEFT JOIN DBO.UnifiedRouteSettlementDetail URSD  WITH(NOLOCK) ON 		
			URSD.GuideSerie=RPD.Guide_Serie
			AND URSD.GuideNumber=RPD.Guide_Number
			AND URSD.RowStatus=1
			AND URS.IdUnifiedRouteSettlement=URSD.UnifiedRouteSettlementId
		LEFT JOIN DBO.DeliverySettlementDetail DSETTD  WITH(NOLOCK) ON 
					DSETTD.Guide_Serie=RPD.Guide_Serie
					AND DSETTD.Guide_Number=RPD.Guide_Number
					AND DSETTD.RowStatus=1
		WHERE 
			RA.RowStatus=1		
			--AND RA.IdVehicle IS NOT NULL
			AND RA.IdRoute IS NOT NULL		
			AND RA.IdCurrierMan=@IDCOURIER--@CUI
			AND URS.UserSettlement IS NULL --FILTRO PARA LIQUIDACIONES PENDIENTES DE CERRAR
			AND RA.DateOfRoute=@Date
	
		IF  @TOTALGUIDESDL IS NOT NULL AND @TOTALGUIDESDL>0
		BEGIN
			SET @ALLOK=1;
				IF @GUIDESCOUNTNOTLIQUIDED_DL  IS NULL OR @GUIDESCOUNTNOTLIQUIDED_DL  >0 
				BEGIN
					SET @ALLOK=0;
					SET @MESSAGEERROR= CONCAT(@MESSAGEERROR,'Existen  ', CONVERT(NVARCHAR(10),ISNULL(@GUIDESCOUNTNOTLIQUIDED_DL,0)),' guías de entrega pendientes de liquidar ',CHAR(13));
				END
				IF @GUIDESCOUNTNOTDELIVERED_DL  IS NULL OR @GUIDESCOUNTNOTDELIVERED_DL >0 
				BEGIN
					SET @ALLOK=0;
					SET @MESSAGEERROR= CONCAT(@MESSAGEERROR,'Existen ',CONVERT(NVARCHAR(10),ISNULL(@GUIDESCOUNTNOTDELIVERED_DL,0)),' guías de entrega/devolucion que aun no se han entregado', CHAR(13) );
				END	
				IF @SERVICESCOUNTWITHINCIDENCE_DL IS NULL OR @SERVICESCOUNTWITHINCIDENCE_DL >0 
				BEGIN
					SET @ALLOK=0;
					SET @MESSAGEERROR= CONCAT(@MESSAGEERROR,'Existen ',CONVERT(NVARCHAR(10),ISNULL(@SERVICESCOUNTWITHINCIDENCE_DL,0)),' servicios de entrega con incidencia', CHAR(13) )
				END	
				--IF @DELIVERYFAILEDCOUNT_DL IS NULL OR @DELIVERYFAILEDCOUNT_DL >0 
				--BEGIN
				--	SET @ALLOK=0;
				--	SET @MESSAGEERROR= CONCAT(@MESSAGEERROR,'Existen ',CONVERT(NVARCHAR(10),ISNULL(@STATUSFAILED_DO,0)),' guías con checkpoint en estado de entrega fallida', CHAR(13) )
				--END	
		END
		ELSE IF @TOTALGUIDESRECO IS NULL OR @TOTALGUIDESRECO=0
		BEGIN
			SET @EXISTGUIDES=0;
		END


	
		----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		--FIN VALIDACIÓN DE GUÍAS Y SERVICIOS DE ENTREGA Y DEVOLUCIÓN
		----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		IF @ALLOK=1
		BEGIN		

	
			--ACTUALIZANDO LIQUIDACIÓN EN EL NUEVO FLUJO 
			INSERT INTO @AllGuidesSettled (
				[GuideSerie],
				[GuideNumber],
				[PieceNumber],
				[IdUnifiedRouteSettlement],
				[IdUnifiedRouteSettlementDetail],
				[IdUnifiedRouteSettlementDetailPiece],
				[SubTypeServiceManagmentId]
			)
			SELECT  
				URSD.GuideSerie,
				URSD.GuideNumber,
				URSDP.PieceNumber,
				[IdUnifiedRouteSettlement],
				[IdUnifiedRouteSettlementDetail],
				[IdUnifiedRouteSettlementDetailPiece],			
				SMD.SubTypeServiceManagmentId
			FROM DBO.UnifiedRouteSettlement URS WITH(NOLOCK) 
				INNER JOIN DBO.UnifiedRouteSettlementDetail URSD WITH(NOLOCK) 
					ON URSD.UnifiedRouteSettlementId=URS.IdUnifiedRouteSettlement
				INNER JOIN DBO.UnifiedRouteSettlementDetailPiece URSDP WITH(NOLOCK) 
					ON URSDP.UnifiedRouteSettlementDetailId=URSD.IdUnifiedRouteSettlementDetail
				INNER JOIN ServiceManagementDetail SMD  WITH(NOLOCK) ON SMD.ServiceManagement = URSD.ServiceManagementId
				INNER JOIN DBO.RouteAssigment RA  WITH(NOLOCK) ON URS.RouteAssignmentId=RA.IdRouteAssigment
			WHERE RA.IdCurrierMan=@IDCOURIER
			AND RA.DateOfRoute=@Date	
			AND URS.UserSettlement IS NULL --FILTRO PARA LIQUIDACIONES PENDIENTES DE CERRAR;
			AND GuideNumber NOT IN (3701336,3701496,3698645,3701496)
			UNION
			SELECT  
				URSD.GuideSerie,
				URSD.GuideNumber,
				URSDP.PieceNumber,
				[IdUnifiedRouteSettlement],
				[IdUnifiedRouteSettlementDetail],
				[IdUnifiedRouteSettlementDetailPiece],			
				@IdSubTypeRecollection
			FROM DBO.UnifiedRouteSettlement URS WITH(NOLOCK) 
				INNER JOIN DBO.UnifiedRouteSettlementDetail URSD WITH(NOLOCK) 
					ON URSD.UnifiedRouteSettlementId=URS.IdUnifiedRouteSettlement
				INNER JOIN DBO.UnifiedRouteSettlementDetailPiece URSDP WITH(NOLOCK) 
					ON URSDP.UnifiedRouteSettlementDetailId=URSD.IdUnifiedRouteSettlementDetail
				--INNER JOIN ServiceManagementDetail SMD ON SMD.ServiceManagement = URSD.ServiceManagementId
				INNER JOIN DBO.RouteAssigment RA  WITH(NOLOCK) ON URS.RouteAssignmentId=RA.IdRouteAssigment
				LEFT JOIN DBO.ServiceManagement SM WITH(NOLOCK)  ON URSD.ServiceManagementId=SM.IdServiceManagement
				-----------------------------------------------------------------------------
				--RECOLECCIÓN
				LEFT JOIN DBO.SchedulePickup SP WITH(NOLOCK) 
					ON SM.IdSchedulePickup= SP.SchedulePickupId
					AND SP.RowStatus=1
				LEFT JOIN DBO.DeliveryOrderPaymentDetail DOPD WITH(NOLOCK) 
					ON DOPD.IdHeaderRecolection=SP.SchedulePickupId
				-----------------------------------------------------------------------------
			WHERE RA.IdCurrierMan=@IDCOURIER
			AND RA.DateOfRoute=@Date	
			AND URS.UserSettlement IS NULL --FILTRO PARA LIQUIDACIONES PENDIENTES DE CERRAR;		
			AND DOPD.GuideNumber NOT IN (3701336,3701496,3698645,3701496)






						------------------------------------------------------
		--INICIO ACTUALIZACIÓN GUÍAS EN RUTA QUE FUERON RECOLECTADOS 
			INSERT INTO DeliveryOrderDetail (Guide_Serie, Guide_Number, StatusOrderId, UserCreated, DateCreated, DateCreatedInSystem, Observations, Temperature_Celsius, PieceId, RowStatus)			
			SELECT 
				DO.Guide_Serie, DO.Guide_Number, @STATUSARRIVAL_DO, @Token, GETDATE(), GETDATE(), NULL, NULL, NULL, 1
				FROM RouteAssigment RA WITH(NOLOCK) 
				INNER JOIN DBO.ServiceManagement SM  WITH(NOLOCK) 
					ON SM.IdPuRouteAssigment=RA.IdRouteAssigment
					AND SM .RowStatus=1
				--INNER JOIN DBO.ServiceManagementDetail SMD
					--ON SMD.ServiceManagement=SM.IdServiceManagement
				INNER JOIN DBO.SchedulePickup SP WITH(NOLOCK) 
					ON SM.IdSchedulePickup= SP.SchedulePickupId
					AND SP.RowStatus=1
				INNER JOIN DBO.DeliveryOrderPaymentDetail DOPD WITH(NOLOCK) 
					ON DOPD.IdHeaderRecolection=SP.SchedulePickupId
				INNER JOIN DBO.DeliveryOrder DO WITH (NOLOCK)
					ON DO.Guide_Serie=DOPD.GuideSerie
					AND DO.Guide_Number=DOPD.GuideNumber
				LEFT JOIN DBO.UnifiedRouteSettlement URS  WITH(NOLOCK) ON 		
					URS.RouteAssignmentId=RA.IdRouteAssigment
				LEFT JOIN DBO.UnifiedRouteSettlementDetail URSD WITH(NOLOCK)  ON 		
					URSD.GuideSerie=DOPD.GuideSerie
					AND URSD.GuideNumber=DOPD.GuideNumber
					AND URSD.RowStatus=1
					AND URS.IdUnifiedRouteSettlement=URSD.UnifiedRouteSettlementId

				WHERE 
					RA.RowStatus=1		
					AND RA.IdVehicle IS NOT NULL
					AND RA.IdRoute IS NOT NULL		
					AND RA.IdCurrierMan=@IDCOURIER--@CUI
					AND URS.UserSettlement IS NULL --FILTRO PARA LIQUIDACIONES PENDIENTES DE CERRAR
					AND RA.DateOfRoute=@Date		
					AND URSD.IdUnifiedRouteSettlementDetail IS NOT NULL 
					AND URSD.IsOpenProcess IN (0,NULL)
					AND DO.StatusOrderId=@STATUSCOLLECTED_DO
					AND DO.Guide_Number NOT IN (3701336,3701496,3698645,3701496)


			UPDATE DO SET DO.StatusOrderId = @STATUSARRIVAL_DO
				FROM RouteAssigment RA WITH(NOLOCK) 
				INNER JOIN DBO.ServiceManagement SM  WITH(NOLOCK) 
					ON SM.IdPuRouteAssigment=RA.IdRouteAssigment
					AND SM .RowStatus=1
				--INNER JOIN DBO.ServiceManagementDetail SMD
					--ON SMD.ServiceManagement=SM.IdServiceManagement
				INNER JOIN DBO.SchedulePickup SP WITH(NOLOCK) 
					ON SM.IdSchedulePickup= SP.SchedulePickupId
					AND SP.RowStatus=1
				INNER JOIN DBO.DeliveryOrderPaymentDetail DOPD WITH(NOLOCK) 
					ON DOPD.IdHeaderRecolection=SP.SchedulePickupId
				INNER JOIN DBO.DeliveryOrder DO WITH (NOLOCK)
					ON DO.Guide_Serie=DOPD.GuideSerie
					AND DO.Guide_Number=DOPD.GuideNumber
				LEFT JOIN DBO.UnifiedRouteSettlement URS WITH(NOLOCK)  ON 		
					URS.RouteAssignmentId=RA.IdRouteAssigment
				LEFT JOIN DBO.UnifiedRouteSettlementDetail URSD  WITH(NOLOCK) ON 		
					URSD.GuideSerie=DOPD.GuideSerie
					AND URSD.GuideNumber=DOPD.GuideNumber
					AND URSD.RowStatus=1
					AND URS.IdUnifiedRouteSettlement=URSD.UnifiedRouteSettlementId

				WHERE 
					RA.RowStatus=1		
					AND RA.IdVehicle IS NOT NULL
					AND RA.IdRoute IS NOT NULL		
					AND RA.IdCurrierMan=@IDCOURIER--@CUI
					AND URS.UserSettlement IS NULL --FILTRO PARA LIQUIDACIONES PENDIENTES DE CERRAR
					AND RA.DateOfRoute=@Date		
					AND URSD.IdUnifiedRouteSettlementDetail IS NOT NULL 
					AND URSD.IsOpenProcess IN (0,NULL)
					AND DO.StatusOrderId=@STATUSCOLLECTED_DO
					AND DO.Guide_Number NOT IN (3701336,3701496,3698645,3701496)


		--FIN ACTUALIZACIÓN GUÍAS EN RUTA QUE FUERON RECOLECTADOS 
		------------------------------------------------------
		--INICIO ACTUALIZACIÓN GUÍAS EN ESTADO DE ENTREGA FALLIDA A ESTADO 
			INSERT INTO DeliveryOrderDetail (Guide_Serie, Guide_Number, StatusOrderId, UserCreated, DateCreated, DateCreatedInSystem, Observations, Temperature_Celsius, PieceId, RowStatus)			
			SELECT 
				DO.Guide_Serie, DO.Guide_Number, @RETURNEDTOFORZA_DO, @Token, GETDATE(), GETDATE(), NULL, NULL, NULL, 1
				FROM RouteAssigment RA WITH(NOLOCK) 
				INNER JOIN DBO.ServiceManagement SM  WITH(NOLOCK) 
					ON SM.IdPuRouteAssigment=RA.IdRouteAssigment
					AND SM .RowStatus=1
				INNER JOIN DBO.ServiceManagementDetail SMD WITH(NOLOCK) 
					ON SMD.ServiceManagement=SM.IdServiceManagement
				INNER JOIN DBO.RoutePreparationDetail RPD  WITH(NOLOCK) 
					ON RPD.ServiceManagementDetailId=SMD.IdServiceManagementDetail
					AND RPD.RowStatus=1
				LEFT JOIN DBO.DeliveryOrder DO WITH (NOLOCK)
					ON DO.Guide_Serie=RPD.Guide_Serie
					AND DO.Guide_Number=RPD.Guide_Number
				LEFT JOIN DBO.UnifiedRouteSettlement URS  WITH(NOLOCK) ON 		
					URS.RouteAssignmentId=RA.IdRouteAssigment
				LEFT JOIN DBO.UnifiedRouteSettlementDetail URSD  WITH(NOLOCK) ON 		
					URSD.GuideSerie=RPD.Guide_Serie
					AND URSD.GuideNumber=RPD.Guide_Number
					AND URSD.RowStatus=1
					AND URS.IdUnifiedRouteSettlement=URSD.UnifiedRouteSettlementId
				WHERE 
					RA.RowStatus=1		
					--AND RA.IdVehicle IS NOT NULL
					AND RA.IdRoute IS NOT NULL		
					AND RA.IdCurrierMan=@IDCOURIER--@CUI
					AND URS.UserSettlement IS NULL --FILTRO PARA LIQUIDACIONES PENDIENTES DE CERRAR
					AND RA.DateOfRoute=@Date		
					AND URSD.IdUnifiedRouteSettlementDetail IS NOT NULL 
					AND URSD.IsOpenProcess IN (0,NULL)
					AND DO.StatusOrderId=@STATUSFAILED_DO
					AND GuideNumber NOT IN (3701336,3701496,3698645,3701496)

			UPDATE DO SET DO.StatusOrderId = @RETURNEDTOFORZA_DO
				FROM RouteAssigment RA WITH(NOLOCK) 
				INNER JOIN DBO.ServiceManagement SM  WITH(NOLOCK) 
					ON SM.IdPuRouteAssigment=RA.IdRouteAssigment
					AND SM .RowStatus=1
				INNER JOIN DBO.ServiceManagementDetail SMD WITH(NOLOCK) 
					ON SMD.ServiceManagement=SM.IdServiceManagement
				INNER JOIN DBO.RoutePreparationDetail RPD  WITH(NOLOCK) 
					ON RPD.ServiceManagementDetailId=SMD.IdServiceManagementDetail
					AND RPD.RowStatus=1
				LEFT JOIN DBO.DeliveryOrder DO WITH (NOLOCK)
					ON DO.Guide_Serie=RPD.Guide_Serie
					AND DO.Guide_Number=RPD.Guide_Number
				LEFT JOIN DBO.UnifiedRouteSettlement URS  WITH(NOLOCK) ON 		
					URS.RouteAssignmentId=RA.IdRouteAssigment
				LEFT JOIN DBO.UnifiedRouteSettlementDetail URSD  WITH(NOLOCK) ON 		
					URSD.GuideSerie=RPD.Guide_Serie
					AND URSD.GuideNumber=RPD.Guide_Number
					AND URSD.RowStatus=1
					AND URS.IdUnifiedRouteSettlement=URSD.UnifiedRouteSettlementId
				WHERE 
					RA.RowStatus=1		
					--AND RA.IdVehicle IS NOT NULL
					AND RA.IdRoute IS NOT NULL		
					AND RA.IdCurrierMan=@IDCOURIER--@CUI
					AND URS.UserSettlement IS NULL --FILTRO PARA LIQUIDACIONES PENDIENTES DE CERRAR
					AND RA.DateOfRoute=@Date		
					AND URSD.IdUnifiedRouteSettlementDetail IS NOT NULL 
					AND URSD.IsOpenProcess IN (0,NULL)
					AND DO.StatusOrderId=@STATUSFAILED_DO
					AND DO.Guide_Number NOT IN (3701336,3701496,3698645,3701496)
		------------------------------------------------------

			DECLARE @CURRENTDATE DATETIME = GETDATE();
			UPDATE URS SET
				URS.TotalGuidesSettled=SUB1.TotalGuides--TOTAL GUÍAS
				,URS.DateSettlement=@CURRENTDATE 
				,URS.DateUpdated=@CURRENTDATE 
				,URS.TokenUpdated=@CURRENTDATE 
				,URS.TotalPiecesSettled=SUB1.TotalPieces
				,URS.UserSettlement=@Token
			FROM DBO.UnifiedRouteSettlement URS WITH(NOLOCK) 
			INNER JOIN 
				(SELECT
					AGS.IdUnifiedRouteSettlement 'IdUnifiedRouteSettlement'
					,COUNT(DISTINCT AGS.IdUnifiedRouteSettlementDetail) 'TotalGuides'
					,COUNT(DISTINCT AGS.IdUnifiedRouteSettlementDetailPiece) 'TotalPieces'
				FROM @AllGuidesSettled AGS
				GROUP BY AGS.IdUnifiedRouteSettlement
				) AS SUB1 ON SUB1.IdUnifiedRouteSettlement=URS.IdUnifiedRouteSettlement;

			---------------------------------------------
			--INICIO Actualización de UnifiedRouteSettlementDetail y montos de servicio y montos de servicios COD 
			
			UPDATE 
				URSD 
			SET 
				URSD.DateSettlement=@CURRENTDATE 
				,URSD.DateUpdated=@CURRENTDATE 
				,URSD.TokenUpdated=@CURRENTDATE 
				,URSD.UserSettlement=@Token
				,URSD.ServiceSettlementAmount=IIF(1 IN (URSD.IsDelivered,URSD.IsReturn), 
				ISNULL(IIF(stsm.[Name] IN ('Entrega', 'Devolución') AND
					so.OrderDescription IN ('Entregado', 'COD liquidado', 'COD pagado', 'Devuelto')
					, IIF(do.IsCollect = 1, do.PriceShippment, 0), 0), 0), URSD.ServiceSettlementAmount)
				,URSD.ServiceCODSettlementAmount=IIF(1 IN (URSD.IsDelivered), 
				ISNULL(IIF(stsm.[Name] IN ('Entrega', 'Devolución') AND
					so.OrderDescription IN ('Entregado', 'COD liquidado', 'COD pagado', 'Devuelto')
					, ISNULL(do.Collect_OnDelivery, 0), 0), 0), URSD.ServiceCODSettlementAmount)
				FROM (
					SELECT
						DISTINCT
							AGSaux.GuideSerie
							,AGSaux.GuideNumber
							,AGSaux.IdUnifiedRouteSettlement
					FROM
						@AllGuidesSettled AGSaux
				) AGS
				INNER JOIN UnifiedRouteSettlementDetail URSD WITH(NOLOCK) 
					ON URSD.GuideNumber = AGS.GuideNumber
					AND URSD.GuideSerie = AGS.GuideSerie
					AND URSD.RowStatus=1
					AND URSD.UnifiedRouteSettlementId=AGS.IdUnifiedRouteSettlement	
				INNER JOIN ServiceManagement sm WITH (NOLOCK)
					ON URSD.ServiceManagementId = sm.IdServiceManagement
						AND sm.RowStatus = 1
				INNER JOIN CatServiceStatus css WITH (NOLOCK)
					ON sm.ServiceStatusId = css.IdServiceStatus
				INNER JOIN DeliveryOrder do WITH (NOLOCK)
					ON AGS.GuideSerie = do.Guide_Serie
						AND AGS.GuideNumber = do.Guide_Number
				INNER JOIN StatusOrder so WITH (NOLOCK)
					ON do.StatusOrderId = so.StatusOrderId
				LEFT JOIN SubTypeServiceManagment stsm WITH (NOLOCK)
					ON sm.SubTypeServiceManagmentId = stsm.IdSubTypeServiceManagment
				WHERE 
					(css.[Name] <> 'Cancelado' OR css.IdServiceStatus IS NULL)
				

			--FIN Actualización de UnifiedRouteSettlementDetail y montos de servicio y montos de servicios COD 
			---------------------------------------------
			
		
			----------------------------------------------------
			--CREANDO MANIFIESTO PARA GUÍAS DE RECOLECCIÓN 
			----------------------------------------------------
			DECLARE @TYPERECOLLECTID INT = (SELECT IdSubTypeServiceManagment FROM DBO.SubTypeServiceManagment WHERE Name = 'Recolección');
			DECLARE @SETTLEMENTBYPICKUPID INT;
			INSERT INTO dbo.SettlementByPickup (
				RouteAssigmentId, 
				DatePrinted, 
				TokenCreated,
				DateCreated,
				PiecesDry, 
				PiecesCold,
				GuidesQuantity,
				PiecesDryReceived,
				PiecesColdReceived, 
				GuidesQuantityReceived,
				IdCourier
			)
			SELECT 
				URS.RouteAssignmentId
				,GETDATE()
				,@Token
				,GETDATE()
				,SUM(CASE WHEN URSP.IsDryPiece = 1 THEN 1 ELSE 0 END) 
				,SUM(CASE WHEN URSP.IsDryPiece = 0 THEN 1 ELSE 0 END) 
				,COUNT(DISTINCT AGS.IdUnifiedRouteSettlementDetail) 
				,SUM(CASE WHEN URSP.IsDryPiece = 1 THEN 1 ELSE 0 END) 
				,SUM(CASE WHEN URSP.IsDryPiece = 0 THEN 1 ELSE 0 END) 			
				,COUNT(DISTINCT AGS.IdUnifiedRouteSettlementDetail)
				,RA.IdCurrierMan
			FROM 
				@AllGuidesSettled AGS
				INNER JOIN DBO.UnifiedRouteSettlement URS  WITH(NOLOCK) ON URS.IdUnifiedRouteSettlement=AGS.IdUnifiedRouteSettlement			
				INNER JOIN DBO.UnifiedRouteSettlementDetailPiece URSP WITH(NOLOCK) ON AGS.IdUnifiedRouteSettlementDetailPiece=URSP.IdUnifiedRouteSettlementDetailPiece
				INNER JOIN DBO.RouteAssigment RA  WITH(NOLOCK) ON URS.RouteAssignmentId=RA.IdRouteAssigment			
			WHERE AGS.SubTypeServiceManagmentId=@TYPERECOLLECTID
			GROUP BY 
				URS.RouteAssignmentId
				,RA.IdCurrierMan;


			SET @SETTLEMENTBYPICKUPID = SCOPE_IDENTITY();


			INSERT INTO  dbo.SettlementByPickupDetail( 
				SettlementByPickupId,
				GuideSerie,
				GuideNumber,
				RowStatus,
				TokenCreated,
				DateCreated,
				TokenUpdated,
				DateUpdated,
				IsPieceLiquidaded,
				NoPiece)
			SELECT 
				@SETTLEMENTBYPICKUPID
				,AGS.GuideSerie
				,AGS.GuideNumber
				,1
				,@Token
				,@CURRENTDATE
				,NULL
				,NULL
				,1
				,AGS.PieceNumber
			FROM 
				@AllGuidesSettled AGS			
			WHERE AGS.SubTypeServiceManagmentId=@TYPERECOLLECTID
			GROUP BY 
				AGS.GuideSerie
				,AGS.GuideNumber
				,AGS.PieceNumber;

			----------------------------------------------------
			--FIN MANIFIESTO PARA GUÍAS DE RECOLECCIÓN 
			----------------------------------------------------



			--************************************************
			--CREANDO MANIFIESTO PARA GUÍAS DE ENTREGA 
			--************************************************
			DECLARE @TYPEDELIVERYID INT = (SELECT IdSubTypeServiceManagment FROM DBO.SubTypeServiceManagment WHERE Name = 'Entrega');;

			--AGRUPANDO GUIAS POR  DeliveryOrderBySettlement.ID
			UPDATE DOBS SET
				User_Received=@Token
				,Date_Received=GETDATE()
				,Guides_Received=SUB_1.TotalGuides
				,Route_Received=GETDATE()
				,SettlementStationId=NULL
			FROM DeliveryOrderBySettlement DOBS WITH(NOLOCK) 
			INNER JOIN 
			(
				SELECT 
					DOBS.ID,
					COUNT(DISTINCT AGS.GuideNumber) 'TotalGuides'		
				FROM DBO.DeliveryOrderBySettlement DOBS WITH(NOLOCK) 
				INNER JOIN DBO.DeliverySettlementDetail DSD  WITH(NOLOCK)
					ON DSD.ID_DeliveryOrderBySettlement=DOBS.ID
				INNER JOIN @AllGuidesSettled AGS 
					ON AGS.GuideSerie =DSD.Guide_Serie
					AND AGS.GuideNumber=DSD.Guide_Number
				WHERE AGS.SubTypeServiceManagmentId=@TYPEDELIVERYID
				GROUP BY DOBS.ID
			) SUB_1
			ON DOBS.ID=SUB_1.ID;

			--ACTUALIZANDO ROUTEPEPARATION 
			UPDATE RP  SET
				RP.RowStatus=0,
				RP.DateUpdated=GETDATE(),
				RP.TokenUpdated=@Token
			FROM DBO.RoutePreparation RP  WITH(NOLOCK) 
			INNER JOIN DBO.DeliveryOrderBySettlement DOBS WITH(NOLOCK) 
				ON RP.DeliveryOrderBySettlementId=DOBS.ID
			INNER JOIN 
			(
				SELECT 
					DOBS.ID,
					COUNT(DISTINCT AGS.GuideNumber) 'TotalGuides'		
				FROM DBO.DeliveryOrderBySettlement DOBS WITH(NOLOCK) 
				INNER JOIN DBO.DeliverySettlementDetail DSD WITH(NOLOCK)
					ON DSD.ID_DeliveryOrderBySettlement=DOBS.ID
				INNER JOIN @AllGuidesSettled AGS 
					ON AGS.GuideSerie =DSD.Guide_Serie
					AND AGS.GuideNumber=DSD.Guide_Number
				GROUP BY DOBS.ID
			) SUB_1
			ON DOBS.ID=SUB_1.ID;	
			----------------------------------------------------
			--FIN MANIFIESTO PARA GUÍAS DE ENTREGA 
			----------------------------------------------------



			--************************************************
			--CREANDO MANIFIESTO PARA DEVOLUCIÓN 
			--************************************************		
			update sbp set
					TokenUpdated = @Token,
					DateUpdated = GETDATE(),
					GuidesQuantityReceived = SUB_1.TotalGuides
			from dbo.SettlementByPickup sbp WITH(NOLOCK) 
			INNER JOIN 
			(	SELECT 
					RA.IdRouteAssigment
					,COUNT(DISTINCT AGS.IdUnifiedRouteSettlementDetail) 'TotalGuides'
			
				FROM 
					@AllGuidesSettled AGS
					INNER JOIN DBO.UnifiedRouteSettlement URS WITH(NOLOCK)  ON URS.IdUnifiedRouteSettlement=AGS.IdUnifiedRouteSettlement			
					INNER JOIN DBO.UnifiedRouteSettlementDetailPiece URSP WITH(NOLOCK)  ON AGS.IdUnifiedRouteSettlementDetailPiece=URSP.IdUnifiedRouteSettlementDetailPiece
					INNER JOIN DBO.RouteAssigment RA WITH(NOLOCK)  ON URS.RouteAssignmentId=RA.IdRouteAssigment			
				WHERE AGS.SubTypeServiceManagmentId=@TYPERECOLLECTID
				GROUP BY 
				RA.IdRouteAssigment
			)SUB_1 ON SUB_1.IdRouteAssigment=SBP.RouteAssigmentId;
			----------------------------------------------------
			--FIN MANIFIESTO PARA DEVOLUCIÓN 
			----------------------------------------------------



				----------------------------------------------------------------------------------------------
				----ACTUALIZANDO ESTADO DE SERVICIOS
				DECLARE @StatusServiceDelivered INT = (SELECT IdServiceStatus FROM DBO.CatServiceStatus where Name ='Entregado ' );
				DECLARE @StatusServiceReturned INT = (SELECT IdServiceStatus FROM DBO.CatServiceStatus where Name ='Devuelto ' );			
				DECLARE @StatusServiceCollected INT = (SELECT IdServiceStatus FROM DBO.CatServiceStatus where Name ='Recolectado ');
			
				--	--> Actualizando servicios de guías entregadas/trasladadas
					UPDATE SM
					SET ServiceStatusId =
					CASE
						WHEN (stsm.IdSubTypeServiceManagment IS NULL OR
							stsm.[Name] = 'Recolección') THEN @StatusServiceCollected
						WHEN stsm.[Name] = 'Entrega' THEN @StatusServiceDelivered
						WHEN stsm.[Name] = 'Devolución' THEN @StatusServiceReturned
						ELSE SM.ServiceStatusId
					END
					FROM @AllGuidesSettled AGS
					INNER JOIN DBO.UnifiedRouteSettlementDetail URSD WITH(NOLOCK) 
						ON URSD.IdUnifiedRouteSettlementDetail = AGS.IdUnifiedRouteSettlementDetail
					INNER JOIN DBO.ServiceManagement SM WITH(NOLOCK) 
						ON URSD.ServiceManagementId = SM.IdServiceManagement
					LEFT JOIN SubTypeServiceManagment stsm WITH (NOLOCK)
						ON SM.SubTypeServiceManagmentId = stsm.IdSubTypeServiceManagment
					--where SMD.SubTypeServiceManagmentId IN (@IdSubTypeDelivery)
					--AND GTS.IsTransfer=0
					--GROUP BY SM.IdServiceManagement;

					INSERT INTO [dbo].[EventService]
							   ([ServiceManagementId]
							   ,[ServiceStatusId]
							   ,[RowStauts]
							   ,[TokenCreated]
							   ,[DateCreated]
							   ,[Observations])
					SELECT
							   SM.IdServiceManagement
							   ,SMD.SubTypeServiceManagmentId
							   ,1
							   ,@Token
							   ,GETDATE()
							   ,'Actualización de estado desde spHM_GetSettlementUnifiedRoutes'
					FROM @AllGuidesSettled	AGS
					INNER JOIN DBO.UnifiedRouteSettlementDetail URSD WITH(NOLOCK) 
						ON URSD.IdUnifiedRouteSettlementDetail=AGS.IdUnifiedRouteSettlementDetail
					INNER JOIN DBO.ServiceManagement SM  WITH(NOLOCK) ON URSD.ServiceManagementId=SM.IdServiceManagement
					INNER JOIN DBO.ServiceManagementDetail SMD  WITH(NOLOCK) ON SMD.ServiceManagement=SM.IdServiceManagement				
					GROUP BY SM.IdServiceManagement,SMD.SubTypeServiceManagmentId;




			SELECT			  
				1 AS 'StatusCode',
				'Cierre de liquidación de ruta unificada completada' AS 'Description';
			--Listando manifiesto  para impresión

			--TABLA 1
			--Listando manifiestos del ultimo cierre realizado
			SELECT URSID 'URSID' FROM @ManifestList;
		

		END
		ELSE
		BEGIN
			--ERROR		
			SET @MESSAGEERROR= CONCAT('Se encontraron los siguientes errores: ', CHAR(13),@MESSAGEERROR)	
			SELECT			  
				0 AS 'StatusCode',
				@MESSAGEERROR AS 'Description';
		END;

	END





	
		COMMIT TRANSACTION; 

	END TRY
	BEGIN CATCH
        IF @TranCounter = 0  
            ROLLBACK TRANSACTION;  
        ELSE IF XACT_STATE() <> -1  
                ROLLBACK TRANSACTION SPClosureSettlementUnifiedRoutes;  
		SELECT			  
			0 AS 'StatusCode',
			ERROR_MESSAGE() AS 'Description';
	END CATCH


END
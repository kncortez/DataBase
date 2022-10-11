-- =============================================
-- Author:		<Alberto Ixchop>     
-- Create date: <03-10-2022>
-- Description:	<Cierre de proceso de liquidación de ruta unificada>
-- =============================================
CREATE PROCEDURE spHM_ClosureSettlementUnifiedRoutes
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
		IF @TranCounter = 0  
            COMMIT TRANSACTION; 

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
	DECLARE @STATUSCOLLECTED_DO INT = (SELECT StatusOrderId FROM DBO.StatusOrder WHERE OrderDescription = 'Recolectado');
	DECLARE @STATUSINCIDENCE_SM INT = (SELECT IdServiceStatus FROM DBO.CatServiceStatus CS WHERE CS.Name= 'Incidencia');
	DECLARE @STATUSDELIVERED_DO INT = (SELECT StatusOrderId FROM DBO.StatusOrder WHERE OrderDescription = 'Entregado');
	DECLARE @STATUSRETURNED_DO INT = (SELECT StatusOrderId FROM DBO.StatusOrder WHERE OrderDescription = 'Devuelto');
	DECLARE @STATUSINROUTE INT = (SELECT StatusOrderId FROM DBO.StatusOrder WHERE OrderDescription = 'En ruta');
	DECLARE @STATUSFAILED_DO INT = (SELECT StatusOrderId FROM dbo.StatusOrder WITH (NOLOCK) WHERE OrderDescription = 'Intento de entrega fallida');

	DECLARE @IdSubTypeDelivery INT=(SELECT IdSubTypeServiceManagment from dbo.SubTypeServiceManagment where [Name] =  'Entrega');
	DECLARE @IdSubTypeReturn INT=(SELECT IdSubTypeServiceManagment from dbo.SubTypeServiceManagment where [Name] =  'Devolución');

	IF @Date IS NULL
		SET @Date =GETDATE()

	------------------------------------------------------
	--INICIO ACTUALIZACIÓN GUÍAS EN RUTA QUE FUERON RECOLECTADOS 
		UPDATE DO SET DO.StatusOrderId = @STATUSDELIVERED_DO
			FROM RouteAssigment RA
			INNER JOIN DBO.ServiceManagement SM 
				ON SM.IdPuRouteAssigment=RA.IdRouteAssigment
				AND SM .RowStatus=1
			INNER JOIN DBO.ServiceManagementDetail SMD
				ON SMD.ServiceManagement=SM.IdServiceManagement
			INNER JOIN DBO.SchedulePickup SP
				ON SM.IdSchedulePickup= SP.SchedulePickupId
				AND SP.RowStatus=1
			INNER JOIN DBO.DeliveryOrderPaymentDetail DOPD
				ON DOPD.IdHeaderRecolection=SP.SchedulePickupId
			INNER JOIN DBO.DeliveryOrder DO WITH (NOLOCK)
				ON DO.Guide_Serie=DOPD.GuideSerie
				AND DO.Guide_Number=DOPD.GuideNumber
			LEFT JOIN DBO.UnifiedRouteSettlementDetail URSD ON 		
				URSD.GuideSerie=DOPD.GuideSerie
				AND URSD.GuideNumber=DOPD.GuideNumber
				AND URSD.RowStatus=1
			LEFT JOIN DBO.UnifiedRouteSettlement URS ON 		
				URS.IdUnifiedRouteSettlement=URSD.UnifiedRouteSettlementId
				AND URSD.RowStatus=1
			WHERE 
				RA.RowStatus=1		
				AND RA.IdVehicle IS NOT NULL
				AND RA.IdRoute IS NOT NULL		
				AND RA.IdCurrierMan=@IDCOURIER--@CUI
				AND URS.UserSettlement IS NULL --FILTRO PARA LIQUIDACIONES PENDIENTES DE CERRAR
				AND RA.DateOfRoute=@Date		
				AND DO.StatusOrderId = @STATUSINROUTE 
				AND URSD.IdUnifiedRouteSettlementDetail IS NOT NULL 
				AND URSD.IsOpenProcess=0
	--FIN ACTUALIZACIÓN GUÍAS EN RUTA QUE FUERON RECOLECTADOS 
	------------------------------------------------------


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
	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--INICIO VALIDACIÓN DE GUÍAS Y SERVICIOS DE RECOLECCIÓN
	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	SELECT 
		@COUNTGUIDESNOTLIQUIDED_PU=COUNT(DISTINCT CASE WHEN URSD.GuideNumber IS NULL THEN DO.Guide_Number ELSE NULL END)--CANTIDAD DE GUÍAS SIN LIQUIDAR
		,@COUNTGUIDESNOTRECOLECTED_PU=SUM(CASE WHEN DO.StatusOrderId<>@STATUSCOLLECTED_DO THEN 1 ELSE 0 END) --CANTIDAD DE GUIAS DE RECOLECCIÓN QUE NO ESTAN EN ESTADO RECOLECTADO
		,@COUNTSERVICESWITHINCIDENCE_PU=SUM(CASE WHEN SM.ServiceStatusId=@STATUSINCIDENCE_SM THEN 1 ELSE 0 END) --CANTIDAD DE SERVICIOS CON INCIDENCIA
		,@TOTALGUIDESRECO = COUNT(DISTINCT CHECKSUM(DO.Guide_Number,DO.Guide_Serie))
	FROM RouteAssigment RA
	INNER JOIN DBO.ServiceManagement SM 
		ON SM.IdPuRouteAssigment=RA.IdRouteAssigment
		AND SM .RowStatus=1
	INNER JOIN DBO.ServiceManagementDetail SMD
		ON SMD.ServiceManagement=SM.IdServiceManagement
	INNER JOIN DBO.SchedulePickup SP
		ON SM.IdSchedulePickup= SP.SchedulePickupId
		AND SP.RowStatus=1
	INNER JOIN DBO.DeliveryOrderPaymentDetail DOPD
		ON DOPD.IdHeaderRecolection=SP.SchedulePickupId
	INNER JOIN DBO.DeliveryOrder DO WITH (NOLOCK)
		ON DO.Guide_Serie=DOPD.GuideSerie
		AND DO.Guide_Number=DOPD.GuideNumber
	LEFT JOIN DBO.UnifiedRouteSettlementDetail URSD ON 		
		URSD.GuideSerie=DOPD.GuideSerie
		AND URSD.GuideNumber=DOPD.GuideNumber
		AND URSD.RowStatus=1
	LEFT JOIN DBO.UnifiedRouteSettlement URS ON 		
		URS.IdUnifiedRouteSettlement=URSD.UnifiedRouteSettlementId
		AND URSD.RowStatus=1
	WHERE 
		RA.RowStatus=1		
		AND RA.IdVehicle IS NOT NULL
		AND RA.IdRoute IS NOT NULL		
		AND RA.IdCurrierMan=@IDCOURIER--@CUI
		AND URS.UserSettlement IS NULL --FILTRO PARA LIQUIDACIONES PENDIENTES DE CERRAR
		AND RA.DateOfRoute=@Date
	
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
			SET @MESSAGEERROR= CONCAT(@MESSAGEERROR,'Existen ',CONVERT(NVARCHAR(10),@COUNTGUIDESNOTRECOLECTED_PU),' guías de recolección que aun no se han recolectado', CHAR(13) )
		END	
		IF @COUNTSERVICESWITHINCIDENCE_PU IS NULL OR @COUNTSERVICESWITHINCIDENCE_PU >0 
		BEGIN
			SET @ALLOK=0;
			SET @MESSAGEERROR= CONCAT(@MESSAGEERROR,'Existen ',CONVERT(NVARCHAR(10),@COUNTSERVICESWITHINCIDENCE_PU),' servicios de recolección con incidencia'+ CHAR(13) )
		END	
	END
	ELSE
	BEGIN
			SET @ALLOK=0;
			SET @MESSAGEERROR= CONCAT(@MESSAGEERROR,'No se encontraron guías asociadas al courier')
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
		@GUIDESCOUNTNOTLIQUIDED_DL=COUNT(DISTINCT CASE WHEN URSD.GuideNumber IS NULL THEN DO.Guide_Number ELSE NULL END)--CANTIDAD DE GUÍAS SIN LIQUIDAR
		,@GUIDESCOUNTNOTDELIVERED_DL=SUM(CASE WHEN DO.StatusOrderId NOT IN (@STATUSDELIVERED_DO,@STATUSRETURNED_DO) THEN 1 ELSE 0 END) --CANTIDAD DE GUIAS DE ENTREGA/RECOLECCIÓN QUE NO ESTAN EN ESTADO DE ENTREGA O DEVUELTO
		,@SERVICESCOUNTWITHINCIDENCE_DL=SUM(CASE WHEN SM.ServiceStatusId=@STATUSINCIDENCE_SM THEN 1 ELSE 0 END) --CANTIDAD DE SERVICIOS CON INCIDENCIA
		,@DELIVERYFAILEDCOUNT_DL=SUM(CASE WHEN DOD.StatusCheckpoint =@STATUSFAILED_DO THEN 1 ELSE 0 END)--CANTIDAD DE GUÍAS CON CHECKPOINT ACTUAL COMO INTENTO DE ENTREGA FALLIDA
		,@TOTALGUIDESDL = COUNT(DISTINCT CHECKSUM(DO.Guide_Number,DO.Guide_Serie))
	FROM RouteAssigment RA 
	INNER JOIN DBO.ServiceManagement SM 
		ON SM.IdPuRouteAssigment=RA.IdRouteAssigment
	INNER JOIN DBO.ServiceManagementDetail SMD 
		ON SMD.ServiceManagement=SM.IdServiceManagement		
	INNER JOIN DBO.RoutePreparationDetail RPD 
		ON RPD.ServiceManagementDetailId=SMD.IdServiceManagementDetail
	LEFT JOIN DBO.DeliveryOrder DO WITH (NOLOCK)
		ON DO.Guide_Serie=RPD.Guide_Serie
		AND DO.Guide_Number=RPD.Guide_Number
	OUTER APPLY (
		SELECT TOP 1 StatusOrderId 'StatusCheckpoint'  FROM DBO.DeliveryOrderDetail
		WHERE Guide_Serie=RPD.Guide_Serie
		AND Guide_Number=RPD.Guide_Number
		ORDER BY DateCreated DESC
	) DOD		
	LEFT JOIN DBO.UnifiedRouteSettlementDetail URSD ON 		
		URSD.GuideSerie=RPD.Guide_Serie
		AND URSD.GuideNumber=RPD.Guide_Number
		AND URSD.RowStatus=1
	LEFT JOIN DBO.UnifiedRouteSettlement URS ON 		
		URS.IdUnifiedRouteSettlement=URSD.UnifiedRouteSettlementId
		AND URSD.RowStatus=1
	WHERE 
		RA.RowStatus=1		
		AND RA.IdVehicle IS NOT NULL
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
				SET @MESSAGEERROR= CONCAT(@MESSAGEERROR,'Existen  ', CONVERT(NVARCHAR(10),ISNULL(@GUIDESCOUNTNOTLIQUIDED_DL,0)),' guías de recolección pendientes de liquidar ',CHAR(13));
			END
			IF @GUIDESCOUNTNOTDELIVERED_DL  IS NULL OR @GUIDESCOUNTNOTDELIVERED_DL >0 
			BEGIN
				SET @ALLOK=0;
				SET @MESSAGEERROR= CONCAT(@MESSAGEERROR,'Existen ',CONVERT(NVARCHAR(10),ISNULL(@GUIDESCOUNTNOTDELIVERED_DL,0)),' guías de entrega/devolucion que aun no se han entregado', CHAR(13) );
			END	
			IF @SERVICESCOUNTWITHINCIDENCE_DL IS NULL OR @SERVICESCOUNTWITHINCIDENCE_DL >0 
			BEGIN
				SET @ALLOK=0;
				SET @MESSAGEERROR= CONCAT(@MESSAGEERROR,'Existen ',CONVERT(NVARCHAR(10),ISNULL(@SERVICESCOUNTWITHINCIDENCE_DL,0)),' servicios de recolección con incidencia', CHAR(13) )
			END	
			IF @DELIVERYFAILEDCOUNT_DL IS NULL OR @DELIVERYFAILEDCOUNT_DL >0 
			BEGIN
				SET @ALLOK=0;
				SET @MESSAGEERROR= CONCAT(@MESSAGEERROR,'Existen ',CONVERT(NVARCHAR(10),ISNULL(@STATUSFAILED_DO,0)),' guías con checkpoint en estado de entrega fallida', CHAR(13) )
			END	
	END
	ELSE IF @TOTALGUIDESRECO IS NULL OR @TOTALGUIDESRECO=0
	BEGIN
			SET @ALLOK=0;
			SET @MESSAGEERROR= 'No se encontraron guías asociadas al courier'
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
		FROM DBO.UnifiedRouteSettlement URS
			INNER JOIN DBO.UnifiedRouteSettlementDetail URSD
				ON URSD.UnifiedRouteSettlementId=URS.IdUnifiedRouteSettlement
			INNER JOIN DBO.UnifiedRouteSettlementDetailPiece URSDP
				ON URSDP.UnifiedRouteSettlementDetailId=URSD.IdUnifiedRouteSettlementDetail
			INNER JOIN ServiceManagementDetail SMD ON SMD.ServiceManagement = URSD.ServiceManagementId
			INNER JOIN DBO.RouteAssigment RA ON URS.RouteAssignmentId=RA.IdRouteAssigment
		WHERE RA.IdCurrierMan=@IDCOURIER
		AND URS.UserSettlement IS NULL --FILTRO PARA LIQUIDACIONES PENDIENTES DE CERRAR;


		DECLARE @CURRENTDATE DATETIME = GETDATE();
		UPDATE URS SET
			URS.TotalGuidesSettled=SUB1.TotalGuides--TOTAL GUÍAS
			,URS.DateSettlement=@CURRENTDATE 
			,URS.DateUpdated=@CURRENTDATE 
			,URS.TokenUpdated=@CURRENTDATE 
			,URS.TotalPiecesSettled=SUB1.TotalPieces
			,URS.UserSettlement=@Token
		FROM DBO.UnifiedRouteSettlement URS
		INNER JOIN 
			(SELECT
				AGS.IdUnifiedRouteSettlement 'IdUnifiedRouteSettlement'
				,COUNT(DISTINCT AGS.IdUnifiedRouteSettlementDetail) 'TotalGuides'
				,COUNT(DISTINCT AGS.IdUnifiedRouteSettlementDetailPiece) 'TotalPieces'
			FROM @AllGuidesSettled AGS
			GROUP BY AGS.IdUnifiedRouteSettlement
			) AS SUB1 ON SUB1.IdUnifiedRouteSettlement=URS.IdUnifiedRouteSettlement;

		
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
			INNER JOIN DBO.UnifiedRouteSettlement URS ON URS.IdUnifiedRouteSettlement=AGS.IdUnifiedRouteSettlement			
			INNER JOIN DBO.UnifiedRouteSettlementDetailPiece URSP ON AGS.IdUnifiedRouteSettlementDetailPiece=URSP.IdUnifiedRouteSettlementDetailPiece
			INNER JOIN DBO.RouteAssigment RA ON URS.RouteAssignmentId=RA.IdRouteAssigment			
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
		FROM DeliveryOrderBySettlement DOBS
		INNER JOIN 
		(
			SELECT 
				DOBS.ID,
				COUNT(DISTINCT AGS.GuideNumber) 'TotalGuides'		
			FROM DBO.DeliveryOrderBySettlement DOBS
			INNER JOIN DBO.DeliverySettlementDetail DSD WITH(NOLOCK)
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
		FROM DBO.RoutePreparation RP 
		INNER JOIN DBO.DeliveryOrderBySettlement DOBS
			ON RP.DeliveryOrderBySettlementId=DOBS.ID
		INNER JOIN 
		(
			SELECT 
				DOBS.ID,
				COUNT(DISTINCT AGS.GuideNumber) 'TotalGuides'		
			FROM DBO.DeliveryOrderBySettlement DOBS
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
		from dbo.SettlementByPickup sbp
		INNER JOIN 
		(	SELECT 
				RA.IdRouteAssigment
				,COUNT(DISTINCT AGS.IdUnifiedRouteSettlementDetail) 'TotalGuides'
			
			FROM 
				@AllGuidesSettled AGS
				INNER JOIN DBO.UnifiedRouteSettlement URS ON URS.IdUnifiedRouteSettlement=AGS.IdUnifiedRouteSettlement			
				INNER JOIN DBO.UnifiedRouteSettlementDetailPiece URSP ON AGS.IdUnifiedRouteSettlementDetailPiece=URSP.IdUnifiedRouteSettlementDetailPiece
				INNER JOIN DBO.RouteAssigment RA ON URS.RouteAssignmentId=RA.IdRouteAssigment			
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
				UPDATE SM SET 
					ServiceStatusId= SMD.SubTypeServiceManagmentId
				FROM @AllGuidesSettled	AGS
				INNER JOIN DBO.UnifiedRouteSettlementDetail URSD
					ON URSD.IdUnifiedRouteSettlementDetail=AGS.IdUnifiedRouteSettlementDetail
				INNER JOIN DBO.ServiceManagement SM ON URSD.ServiceManagementId=SM.IdServiceManagement
				INNER JOIN DBO.ServiceManagementDetail SMD ON SMD.ServiceManagement=SM.IdServiceManagement
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
				INNER JOIN DBO.UnifiedRouteSettlementDetail URSD
					ON URSD.IdUnifiedRouteSettlementDetail=AGS.IdUnifiedRouteSettlementDetail
				INNER JOIN DBO.ServiceManagement SM ON URSD.ServiceManagementId=SM.IdServiceManagement
				INNER JOIN DBO.ServiceManagementDetail SMD ON SMD.ServiceManagement=SM.IdServiceManagement				
				GROUP BY SM.IdServiceManagement,SMD.SubTypeServiceManagmentId;





		SELECT			  
			1 AS 'StatusCode',
			'Cierre de liquidación de ruta unificada completada' AS 'Description';

	END
	ELSE
	BEGIN
		--ERROR		
		SET @MESSAGEERROR= CONCAT('Se encontraron los siguientes errores: ', CHAR(13),@MESSAGEERROR)	
		SELECT			  
			0 AS 'StatusCode',
			@MESSAGEERROR AS 'Description';
	END;		

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
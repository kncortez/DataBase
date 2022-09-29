-- =============================================
-- Author:		<Alberto, Ixchop>
-- Create date: <12-09-2022>
-- Description:	<Método para reasignar guía dentro de preparación de ruta de entrega en hermes mobile>
-- =============================================
CREATE PROCEDURE spHM_ReassignGuidePreparation
	@GuideSerie AS NVARCHAR(2),
	@GuideNumber AS INT,
	@FromRouteId INT,
	@DatePreparation DATE = NULL,	
	@RoutePreparationId INT = NULL,
	@ToRouteId INT,	
	@Token AS NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.	
	DECLARE @RecordExist BIT=0;
	DECLARE @BelongsToRoute bit=0;
	DECLARE @Msg_error NVARCHAR(100)='';
	--DECLARE @RecordExist BIT=0;
	IF NOT ((@DatePreparation IS NOT NULL) AND (@FromRouteId IS NOT NULL)) AND @RoutePreparationId IS NULL
	BEGIN 
			SELECT
				2 'StatusCode'
			   ,'Parámetros inválidos' 'Description'
	END
	ELSE IF @RoutePreparationId IS NOT NULL
	BEGIN 
		--Verificando registros existentes para parámetro routeid
		SET @RecordExist= (SELECT TOP 1 1 FROM RoutePreparation RP WHERE RP.IdRoutePreparation=@RoutePreparationId);
		--Verificando SI LA GUÍA PERTENECE AL ROUTEPREPARATION
		SELECT TOP 1 @BelongsToRoute=1 FROM DBO.RoutePreparation RP 
			INNER JOIN DBO.RoutePreparationDetail RPD ON RPD.RoutePreparationId=RP.IdRoutePreparation
		WHERE RP.IdRoutePreparation =@RoutePreparationId
		AND RPD.Guide_Serie=@GuideSerie AND RPD.Guide_Number=@GuideNumber;
		set @Msg_error='La guía no se encuentra asociada a la preparación indicada'
						
		
	END
	ELSE
	BEGIN 
		--Verificando registros existentes para parámetros @RouteId y @Datepreparation
		SET @RecordExist= (SELECT TOP 1 1 FROM RoutePreparation WHERE CatRouteId = @FromRouteId  AND DateRoutePreparation = @DatePreparation);
		--Verificando SI LA GUÍA PERTENECE AL ROUTEPREPARATION
		SELECT TOP 1 @BelongsToRoute=1,@RoutePreparationId = RP.IdRoutePreparation FROM DBO.RoutePreparation RP 
			INNER JOIN DBO.RoutePreparationDetail RPD ON RPD.RoutePreparationId=RP.IdRoutePreparation
		WHERE RP.DateRoutePreparation =@DatePreparation and RP.CatRouteId=@FromRouteId 
		AND RPD.Guide_Serie=@GuideSerie AND RPD.Guide_Number=@GuideNumber;
		set @Msg_error='La guía no se encuentra asociada a la ruta y la fecha indicada'
	END
	

	IF @BelongsToRoute <> 1
	BEGIN 
		SELECT
			2 'StatusCode'
			,@Msg_error 'Description'
	END
	ELSE IF @RecordExist = 0 
	BEGIN
		SELECT
			2 'StatusCode'
			,'No se encontraron guías' 'Description'
	END
	ELSE
	IF @RecordExist <> 0
	BEGIN


	
		--Una preparación de ruta vigente es aquella la cual no ha sido despachada.
		--DECLARE @HasBeenDispatched BIT= EXISTS(SELECT DeliveryOrderBySettlementId FROM DBO.RoutePreparation rp where rp.IdRoutePreparation=@RoutePreparationId);

		DECLARE @DeliveryOrderBySettlementIdOrigin int = NULL; --Variable para comprobar vigencia de preparación origen
		DECLARE @DeliveryOrderBySettlementIdDestiny int = NULL; --Variable para comprobar vigencia de preparación origen
		DECLARE @ToRoutePreparationId INT =NULL; --Guarda el id de la preparación destino (posiblemente existente)
		--Comprobando si la ruta de preparación origen esta vigente
		SELECT @DeliveryOrderBySettlementIdOrigin = DeliveryOrderBySettlementId FROM DBO.RoutePreparation rp where rp.IdRoutePreparation=@RoutePreparationId
		--Comprobando si la ruta de preparación origen esta vigente	
		SELECT TOP 1 
			@ToRoutePreparationId = RP.IdRoutePreparation,
			@DeliveryOrderBySettlementIdDestiny = DeliveryOrderBySettlementId  
		FROM DBO.RoutePreparation RP 
		WHERE RP.DateRoutePreparation =@DatePreparation and RP.CatRouteId=@ToRouteId

		IF @DeliveryOrderBySettlementIdOrigin IS NOT NULL
		BEGIN
			SELECT
				2 'StatusCode'
				,'La ruta de preparación origen no esta vigente' 'Description';
		END
		ELSE IF @DeliveryOrderBySettlementIdDestiny IS NOT NULL AND @ToRoutePreparationId IS NOT NULL
		BEGIN
			SELECT
				2 'StatusCode'
				,'La ruta de preparación destino no esta vigente' 'Description';
		END
		ELSE IF  @ToRoutePreparationId IS NOT NULL AND @ToRoutePreparationId = @RoutePreparationId
		BEGIN
			SELECT
				2 'StatusCode'
				,'La ruta de destino es la misma que la ruta de origen' 'Description';
		END
		ELSE
		BEGIN
			----------------------------------------------------
			----INICIO DE REASIGNACIÓN DE RUTA DE PREPARACIÓN
			----------------------------------------------------
			SELECT
				1 'StatusCode'
				,'Guía reasignada correctamente' 'Description'
			IF @ToRoutePreparationId IS NULL --La preparación de ruta destino no existe
			BEGIN
				--se debe generar los campos necesarios de la misma en RoutePreparation.
				--Crear nuevo registro en route preparation
				DECLARE @PiecesDry INT=0;
				DECLARE @PiecesCold INT=0;
				select	@PiecesDry+=Pieces_Dry,
						@PiecesCold+=Pieces_Cold 
				from dbo.DeliveryOrder 
				where	Guide_Number=@GuideNumber and 
						Guide_Serie=@GuideSerie;

				INSERT INTO [dbo].[RoutePreparation]
						   ([CatRouteId]
						   ,[DateRoutePreparation]
						   ,[GuidesQuantity]
						   ,[PiecesDry]
						   ,[PiecesCold]
						   ,[DeliveryOrderBySettlementId]
						   ,[RowStatus]
						   ,[TokenCreated]
						   ,[DateCreated]
						   ,[TokenUpdated]
						   ,[DateUpdated]
						   ,[CatVehicleId]
						   ,[IsSimpliRoute])
					 VALUES
						   (@ToRouteId
						   ,@DatePreparation
						   ,0--<GuidesQuantity, smallint,>
						   ,@PiecesDry --<PiecesDry, smallint,>
						   ,@PiecesCold--<PiecesCold, smallint,>
						   ,NULL--<DeliveryOrderBySettlementId, bigint,>
						   ,1--<RowStatus, bit,>
						   ,@Token
						   ,GETDATE()
						   ,NULL
						   ,NULL
						   ,NULL--<CatVehicleId, int,>
						   ,NULL)--<IsSimpliRoute, int,>;
				SET @ToRoutePreparationId = SCOPE_IDENTITY();
			END
			--Actualizando route preparation origen
			update rp set
				rp.TokenUpdated = @Token,
				rp.DateUpdated = GETDATE(),
				rp.GuidesQuantity = rp.GuidesQuantity + 1
			from RoutePreparation rp
			where rp.IdRoutePreparation=@RoutePreparationId;
			--Actualizando route preparation destino
			update rp set
				rp.TokenUpdated = @Token,
				rp.DateUpdated = GETDATE(),
				rp.GuidesQuantity = rp.GuidesQuantity + 1
			from RoutePreparation rp
			where rp.IdRoutePreparation=@ToRoutePreparationId;

			--Inicio anulanción de preparación de guías origen
			UPDATE RPDP
			SET
				TokenUpdated=@Token,
				DateUpdated= GETDATE(),
				RowStatus = 0
			FROM [DeliveryBackOffice].[dbo].[RoutePreparationDetailPiece] RPDP 
			INNER JOIN[DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD ON RPDP.RoutePreparationDetailId=RPD.IdRoutePreparationDetail
			INNER JOIN [DeliveryBackOffice].[dbo].[RoutePreparation] RP
				ON RP.IdRoutePreparation=RPD.RoutePreparationId
			WHERE RP.IdRoutePreparation=@RoutePreparationId;

			UPDATE RPD
			SET     
				UserProcess = NULL,
				IsOpenProcess = 0,
				RowStatus = 0,
				TokenUpdated=@Token,
				DateUpdated= GETDATE()
			FROM [DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD
			INNER JOIN [DeliveryBackOffice].[dbo].[RoutePreparation] RP
				ON RP.IdRoutePreparation=RPD.RoutePreparationId
			WHERE RP.IdRoutePreparation=@RoutePreparationId;
			--Fin anulanción de preparación de guías origen

			--Nuevo registro con la guía en la preparación de ruta destino
			INSERT INTO [dbo].[RoutePreparationDetail]
				([RoutePreparationId]
				,[Guide_Serie]
				,[Guide_Number]
				,[RowStatus]
				,[TokenCreated]
				,[DateCreated]
				,[TokenUpdated]
				,[DateUpdated]
				,[GuideOrder]
				,[ETAGuide]
				,[UserProcess]
				,[IsOpenProcess]
				,[ServiceManagementDetailId])
			VALUES
				(@ToRoutePreparationId
				,@GuideSerie
				,@GuideNumber
				,1
				,@Token
				,GETDATE()
				,NULL
				,NULL
				,NULL--<GuideOrder, decimal(5,2),>
				,NULL--<ETAGuide, time(7),>
				,NULL--<UserProcess, nvarchar(50),>
				,0--<IsOpenProcess, bit,>
				,NULL);--<ServiceManagementDetailId, bigint,>)
			----------------------------------------------------				
			----FIN DE REASIGNACIÓN DE RUTA DE PREPARACIÓN
			----------------------------------------------------
		END
	END
END
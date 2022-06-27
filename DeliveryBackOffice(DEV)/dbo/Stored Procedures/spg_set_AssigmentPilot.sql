
-- =============================================
-- Author:		<Abner, Juarez>
-- Create date: <2020-02-15>
-- Description:	<Asigna una Piloto a un ruta>
-- =============================================
-- =============================================
-- Modified:		<Alberto, Ixchop>
-- Create date: <2022-01-27>
-- Description:	<Asigna una Piloto a un ruta>
-- =============================================
CREATE PROCEDURE [dbo].[spg_set_AssigmentPilot]
		@idRoute AS int,
		@idCourrieMan as int,
		@idVehicle as int,
		@dateRoute AS date,
		@token as varchar(50),
		@dateCreated as datetime,
		@confirm as int,
		@roteType as nvarchar(max)=NULL
		--roteType indica que tipo de ruta se desea asignar a un piloto
			--RECOLECCION indica que se desea asignar un piloto a una ruta de recoleccion
AS
BEGIN
	DECLARE @idRouteAssigment int
	DECLARE @countCourrier int=0
	DECLARE @countVehicle int=0
	DECLARE @countRoutes int=0
	DECLARE @IDRUTETYPE INT=NULL;
	SET @roteType =UPPER(@roteType)
	DECLARE @filterRoutes AS TABLE (id int);--Lista de rutas filtradas
	IF @roteType ='RECOLECCION'
		SET @IDRUTETYPE =(SELECT IdTypeRoute FROM DBO.CatTypeRoute WHERE Name ='Recolección' AND RowStatus=1);

	INSERT INTO @filterRoutes
		SELECT RA.IdRoute
			FROM DBO.RouteAssigment RA 
			LEFT JOIN DBO.CatRoute CR ON  RA.IdRoute=CR.IdRoute 
			WHERE RA.DateOfRoute=@dateRoute 
			AND (@IDRUTETYPE IS NULL OR CR.IdTypeRoute=@IDRUTETYPE )AND RA.DateOfRoute=@dateRoute
			GROUP BY RA.IdRoute;


	DECLARE @IdsRouteAssigmentCourrier AS TABLE (id int,idcourier int);--Lista de courriers asignados en la fecha
	DECLARE @IdsRouteAssigmentVehicle AS TABLE (id int,idvehicle int);--lista de vehiculos asignados en la fecha
	INSERT INTO  @IdsRouteAssigmentCourrier 
		SELECT IdRouteAssigment,IdCurrierMan FROM dbo.RouteAssigment  RA
		WHERE RA.DateOfRoute = @dateRoute  --AND RA.IdCurrierMan =@idCourrieMan
		AND (RA.IdRoute IN (SELECT ID FROM @filterRoutes));--FILTRANDO POR RUTAS 
			
	INSERT INTO  @IdsRouteAssigmentVehicle
		SELECT IdRouteAssigment,IdVehicle FROM dbo.RouteAssigment RA
		WHERE RA.DateOfRoute = @dateRoute -- AND IdVehicle =@idVehicle
		AND (RA.IdRoute IN (SELECT ID FROM @filterRoutes))--FILTRANDO POR RUTAS;

	SET @countCourrier= (SELECT COUNT(*) FROM @IdsRouteAssigmentCourrier WHERE idcourier=@idCourrieMan);
	SET @countVehicle= (SELECT COUNT(*) FROM @IdsRouteAssigmentVehicle WHERE idvehicle=@idVehicle);
	SET @countRoutes=(SELECT COUNT(ID) FROM @filterRoutes where ID=@idRoute);
	
	--SI EL NUMERO DE VECES QUE EL COURIER Y VEHICULO HAN SIDO ASIGNADOS ES 0
	IF @countCourrier=0 AND @countVehicle=0
	BEGIN
		IF @countRoutes >0 --SI LA RUTA YA HA SIDO ASIGNADO DURANTE EL DIA, ASIGNARLE UN PILOTO Y UN VEHICULO
			BEGIN
				SET @idRouteAssigment=(SELECT IdRouteAssigment
					FROM DBO.RouteAssigment RA
					WHERE RA.IdRoute=@idRoute AND RA.DateOfRoute = @dateRoute
					AND ( RA.IdRoute IN (SELECT ID FROM @filterRoutes)));
				UPDATE [DeliveryBackOffice].[dbo].[RouteAssigment] Set IdCurrierMan=@idCourrieMan, IdVehicle=@idVehicle WHERE IdRouteAssigment=@idRouteAssigment
				UPDATE [DeliveryBackOffice].[dbo].[ServiceManagement] Set IdPuCourrier=@idCourrieMan WHERE IdPuRouteAssigment=@idRouteAssigment
				
				--Actualizar Courier en tabla de Rabbit
				UPDATE SettlementPickupStation
				SET CouriermanId = @idCourrieMan
				   ,TokenUpdated = @token
				   ,DateUpdated = GETDATE()
				WHERE RouteId = @idRoute
				AND TransactionDate = @dateRoute
				AND RowStatus = 'TRUE'
			END
		ELSE		-- SI LA RUTA NO HA SIDO ASIGNADO DURANTE EL DIA
		BEGIN
			INSERT INTO [DeliveryBackOffice].[dbo].[RouteAssigment] (IdRoute,IdCurrierMan,IdVehicle,DateOfRoute,RowStatus,TokenCreated,DateCreated)
			VALUES (@idRoute,@idCourrieMan,@idVehicle,@dateRoute,1,@token,GETDATE())		
		END
	END
	--SI EL NUMERO DE COURIER O VEHICULO  ES DIFERENTE A 0, DEBE CONFIRMARSE LA REASIGNACION CON CONFIRM=1 
	ELSE IF @confirm=1
	BEGIN
			--DESASIGANDO COURIERS
			UPDATE[DeliveryBackOffice].[dbo].[RouteAssigment]
			SET IdCurrierMan = NULL WHERE IdCurrierMan=@idCourrieMan and  (IdRouteAssigment in (select id from @IdsRouteAssigmentCourrier) );
			UPDATE [DeliveryBackOffice].[dbo].[ServiceManagement] Set IdPuCourrier=NULL 
				WHERE IdPuRouteAssigment in (select id from @IdsRouteAssigmentCourrier where idcourier=@idCourrieMan);
			--DESASIGNANDO VEHICULOS
			UPDATE[DeliveryBackOffice].[dbo].[RouteAssigment] SET IdVehicle = NULL 
				WHERE IdVehicle=@idVehicle AND DateOfRoute = @dateRoute AND (IdVehicle IN (SELECT idsra.idvehicle FROM @IdsRouteAssigmentVehicle idsra));
			--Desasignando Courier en tabla de Rabbit
			UPDATE sps
			SET CouriermanId = NULL
				,TokenUpdated = @token
				,DateUpdated = GETDATE()
			FROM SettlementPickupStation sps
			JOIN RouteAssigment ra
				ON ra.IdRoute = sps.RouteId
			JOIN @IdsRouteAssigmentCourrier rac
				ON rac.id = ra.IdRouteAssigment
			WHERE sps.CouriermanId = @idCourrieMan
			AND sps.TransactionDate = @dateRoute
			AND sps.RowStatus = 'TRUE'

		 IF @countRoutes=0 --SI LA RUTA NO HA SIDO ASIGNADO DURANTE EL DIA; CREAR EL REGISTRO
		 BEGIN
			INSERT INTO [DeliveryBackOffice].[dbo].[RouteAssigment] (IdRoute,IdCurrierMan,IdVehicle,DateOfRoute,RowStatus,TokenCreated,DateCreated)
			VALUES (@idRoute,@idCourrieMan,@idVehicle,@dateRoute,1,@token,GETDATE())		
		 END
		 ELSE
		 BEGIN 
			--ASIGNANDO COURIER Y VEHICULO
			UPDATE [DeliveryBackOffice].[dbo].[RouteAssigment] SET
				IdCurrierMan=@idCourrieMan, 
				IdVehicle=@idVehicle 
				WHERE  DateOfRoute= @dateRoute AND IdRoute=@idRoute AND (IdRoute IN (SELECT ID FROM @filterRoutes))
			UPDATE [DeliveryBackOffice].[dbo].[ServiceManagement] Set 
				IdPuCourrier=@idCourrieMan 
				WHERE IdPuRouteAssigment IN (SELECT IdRouteAssigment FROM DBO.RouteAssigment WHERE IdRoute=@idRoute AND ( IdRoute IN (SELECT ID FROM @filterRoutes)));
			--Actualizar Courier en tabla de Rabbit
			UPDATE SettlementPickupStation
			SET CouriermanId = @idCourrieMan
				,TokenUpdated = @token
				,DateUpdated = GETDATE()
			WHERE RouteId = @idRoute
			AND TransactionDate = @dateRoute
			AND RowStatus = 'TRUE'
		 END
	END
	--REGRESANDO DATA SOBRE EL NUMERO DE VECES QUE EL COURIER HA ASIGNADO; Y EL NUMERO DE VECES QUE EL VEHICULO HA SIDO ASIGNADO
	SELECT @countCourrier as countCourrier, @countVehicle as CountVehicle
END

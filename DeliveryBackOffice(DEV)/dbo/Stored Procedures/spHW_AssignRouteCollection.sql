-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-09-13>
-- Description:	<SP  asignación de servicio de recolección bajo selección de courier>
-- =============================================
-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-10-18>
-- Description:	<agregar devolución de parametros Nombre de Courierman, código de ruta, código de unidad, placas de vehículo>
-- =============================================
CREATE PROCEDURE [dbo].[spHW_AssignRouteCollection]
@IdCurrierMan AS INT,
@IdRoute AS INT,
@IdVehicle AS INT=NULL,
@IdServiceManagment AS INT,
@Token AS NVARCHAR(50),
@IdRouteAssigment AS INT
AS
BEGIN

    DECLARE @IDRUTETYPE AS INT=NULL;
	DECLARE @IdSchedulePickup as int
	DECLARE @NameCourrier AS NVARCHAR(150)
	DECLARE @CodeOfRoute AS NVARCHAR(20)
	DECLARE @UnitCode AS NVARCHAR(20)
	DECLARE @vehicleplates AS NVARCHAR(10)
	
	SET NOCOUNT ON;


	SET @IDRUTETYPE =(SELECT IdTypeRoute FROM DBO.CatTypeRoute WITH (NOLOCK) WHERE Name ='Recolección' AND RowStatus=1);
	
			SELECT  @IdSchedulePickup = IdSchedulePickup
			FROM [dbo].[ServiceManagement] SMD WITH(NOLOCK) 
			WHERE SMD.IdServiceManagement = @IdServiceManagment
					
			
BEGIN TRANSACTION
 BEGIN TRY 
	
   IF(EXISTS(
		SELECT Top 1 1
		FROM RouteAssigment RA WITH (NOLOCK)
		INNER JOIN CatRoute CR WITH (NOLOCK)
		ON RA.IdRoute = CR.IdRoute
		WHERE RA.IdCurrierMan = @IdCurrierMan AND 
		      RA.IdRoute = @IdRoute AND 
			  CR.IdTypeRoute = @IDRUTETYPE AND RA.DateOfRoute=FORMAT(GETDATE(),'yyyy-MM-dd')  AND 1=0
       ))
	BEGIN
	

	SELECT @NameCourrier = ISNULL(First_Name+' '+Last_Name,'N/D') 
			FROM [dbo].[SenderReceiver] S WITH (NOLOCK)
			WHERE S.ID = @IdCurrierMan 

			SELECT @vehicleplates = ISNULL(CV.Plate,'N/D'),
			       @UnitCode = ISNULL(CV.UnitNumber,0),
				   @CodeOfRoute = ISNULL(CR.CodeRoute,'N/D')
			FROM RouteAssigment RA WITH (NOLOCK)
		           INNER JOIN CatRoute CR WITH (NOLOCK)
		           ON RA.IdRoute = CR.IdRoute
				   INNER JOIN CatVehicle CV WITH (NOLOCK)
				   ON RA.IdVehicle =cv.IdVehicle
		    WHERE RA.IdCurrierMan = @IdCurrierMan AND 
		                 RA.IdRoute = @IdRoute AND 
			             CR.IdTypeRoute = @IDRUTETYPE AND RA.DateOfRoute=FORMAT(GETDATE(),'yyyy-MM-dd')
				


			
			UPDATE [DeliveryBackOffice].[dbo].[ServiceManagement]
				SET IdPuCourrier = @IdCurrierMan,
					IdPuRouteAssigment = @idRouteAssigment,
					ServiceStatusId = 2,
					TokenUpdated = 'AUTOASIGNACION',
					DateUpdated = GETDATE()
				WHERE IdServiceManagement = @IdServiceManagment 

			UPDATE [DeliveryBackOffice].[dbo].[SchedulePickup]
				SET AssigmentStatus = 1
				WHERE SchedulePickupId = @IdSchedulePickup
	
	         SELECT Result=1,
			        Descrip='Ruta asignada exitosamente',
					CodeOfRoute=@CodeOfRoute, 
					NameCourrier=@NameCourrier,
					UnitCode=@UnitCode, 
					vehicleplates=@vehicleplates, 
					IDRUTETYPE=@IDRUTETYPE,
					IdSchedulePickup=@IdSchedulePickup


	

	END
		ELSE
		  BEGIN 
				SELECT Result=0, 
				Descrip='Courierman no disponible',
				CodeOfRoute='N/D', 
				NameCourrier='N/D',
				UnitCode='N/D', 
				vehicleplates='N/D', 
				IDRUTETYPE=NULL,
				IdSchedulePickup=0
		  END 
	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;

        SELECT Result=2, 
				Descrip='Error al realizar la asignación',
				CodeOfRoute='N/D', 
				NameCourrier='N/D',
				UnitCode='N/D', 
				vehicleplates='N/D', 
				IdSchedulePickup=0
             
		
		ROLLBACK TRANSACTION;
	END CATCH
	
END
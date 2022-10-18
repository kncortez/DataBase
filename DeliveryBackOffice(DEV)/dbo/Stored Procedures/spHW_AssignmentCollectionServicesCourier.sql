-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-09-22>
-- Description:	<Sp para asignar servicio de recolección a Courierman>
-- =============================================
-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-10-18>
-- Description:	<agregar devolución de parametros Nombre de Courierman, código de ruta, código de unidad, placas de vehículo>
-- =============================================
CREATE PROCEDURE [dbo].[spHW_AssignmentCollectionServicesCourier] 
@IdCurrierMan AS INT,
@IdRoute AS INT,
@IdVehicle AS INT=NULL,
@IdServiceManagment AS INT,
@Token AS NVARCHAR(50),
@IdRouteAssigment AS INT
AS
BEGIN

    DECLARE @NameCourrier AS NVARCHAR(150)
	DECLARE @CodeOfRoute AS NVARCHAR(10)
	DECLARE @UnitCode AS NVARCHAR(20)
	DECLARE @vehicleplates AS NVARCHAR(10)
	DECLARE @Result AS INT
	DECLARE @IdSchedulePickup as int
	DECLARE @IDRUTETYPE AS INT=(
	                            SELECT IdTypeRoute 
	                            FROM DBO.CatTypeRoute WITH (NOLOCK)
								WHERE Name ='Recolección' COLLATE Latin1_General_CI_AI AND RowStatus=1
								);
	DECLARE @status AS  INT =
            (
                 SELECT IdServiceStatus
                  FROM [DeliveryBackOffice].[dbo].[CatServiceStatus] WITH(NOLOCK) 
                  WHERE [Name] = 'Asignado a Ruta' COLLATE Latin1_General_CI_AI
            );


			

			SELECT   @IdSchedulePickup = IdSchedulePickup
					FROM [dbo].[ServiceManagement] SMD WITH(NOLOCK) 
					WHERE SMD.IdServiceManagement = @IdServiceManagment


	SET NOCOUNT ON;
	IF(EXISTS(SELECT TOP 1 1 FROM dbo.SchedulePickup WITH(NOLOCK) WHERE SchedulePickupId = @IdSchedulePickup))
	BEGIN
	BEGIN TRANSACTION
	BEGIN TRY

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
		                 RA.IdRoute = @IdRoute  AND
			             CR.IdTypeRoute = @IDRUTETYPE


			UPDATE [DeliveryBackOffice].[dbo].[ServiceManagement]
						SET IdPuCourrier = @IdCurrierMan,
							IdPuRouteAssigment = @IdRouteAssigment,
							ServiceStatusId = @status,
							TokenUpdated = @Token,
							DateUpdated = GETDATE()
						WHERE IdServiceManagement = @IdServiceManagment 
	
			UPDATE [DeliveryBackOffice].[dbo].[SchedulePickup]
						SET  AssigmentStatus = 1
						WHERE SchedulePickupId = @IdSchedulePickup 

					SELECT Result=1,
			        Descrip='Ruta asignada exitosamente',
					CodeOfRoute=ISNULL(@CodeOfRoute,0), 
					NameCourrier=ISNULL(@NameCourrier,'N/D'),
					UnitCode=ISNULL(@UnitCode,'N/D'), 
					vehicleplates=ISNULL(@vehicleplates,'N/D'), 
					IdSchedulePickup=@IdSchedulePickup
			
      COMMIT TRANSACTION
	  END TRY
		BEGIN CATCH
		   SELECT Result=2, 
				Descrip='Courierman no disponible',
				CodeOfRoute='N/D', 
				NameCourrier='N/D',
				UnitCode='N/D', 
				vehicleplates='N/D', 
				IdSchedulePickup=0
			ROLLBACK

	  END CATCH

	

	END
	
END


select * from dbo.catroute
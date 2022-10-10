-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-09-13>
-- Description:	<SP  asignación de servicio de recolección bajo selección de courier>
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
	
	SET NOCOUNT ON;

	SET @IDRUTETYPE =(SELECT IdTypeRoute FROM DBO.CatTypeRoute WITH (NOLOCK) WHERE Name ='Recolección'  COLLATE Latin1_General_CI_AI AND RowStatus=1);
	
			SELECT   @IdSchedulePickup = IdSchedulePickup
					FROM [dbo].[ServiceManagement] SMD WITH(NOLOCK) 
					WHERE SMD.IdServiceManagement = @IdServiceManagment

BEGIN TRANSACTION
BEGIN TRY
   IF (EXISTS(
   
		SELECT Top 1 1
		FROM RouteAssigment RA WITH (NOLOCK)
		INNER JOIN CatRoute CR WITH (NOLOCK)
		ON RA.IdRoute = CR.IdRoute
		WHERE RA.IdCurrierMan = @IdCurrierMan AND 
		      RA.IdRoute = @IdRoute AND 
			  CR.IdTypeRoute = @IDRUTETYPE AND RA.DateOfRoute=FORMAT(GETDATE(),'yyyy-MM-dd') 
       ))
	BEGIN

			
			UPDATE [DeliveryBackOffice].[dbo].[ServiceManagement]
				SET IdPuCourrier = @IdCurrierMan,
					IdPuRouteAssigment = @idRouteAssigment,
					ServiceStatusId = 2,
					TokenUpdated = @Token,
					DateUpdated = GETDATE()
				WHERE IdServiceManagement = @IdServiceManagment 

			UPDATE [DeliveryBackOffice].[dbo].[SchedulePickup]
				SET AssigmentStatus = 1
				WHERE SchedulePickupId = @IdSchedulePickup
	
	         SELECT Result=1, Descrip='Ruta asignada exitosamente'

	

	END
		ELSE
		  BEGIN 
				SELECT Result=0, Descrip='Courierman no disponible'
		  END 
	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH

        SELECT  Result =2
             
		
		ROLLBACK TRANSACTION;
	END CATCH
	
END
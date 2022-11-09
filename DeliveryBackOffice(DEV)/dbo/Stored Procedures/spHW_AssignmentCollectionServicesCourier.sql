-- =============================================
-- Author:		<Edelman>
-- Create date: <2022-09-22>
-- Description:	<Sp para asignar servicio de recolección a Courierman>
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

    DECLARE @SenderName AS NVARCHAR(100)
	DECLARE @SenderPhone AS NVARCHAR(50)
	DECLARE @SenderAdress AS NVARCHAR(100)
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

					SET @Result = 1
			
      COMMIT TRANSACTION
	  END TRY
		BEGIN CATCH
		   SET @Result = 2
			ROLLBACK

	  END CATCH

	
	SELECT @Result;

	END
	
END
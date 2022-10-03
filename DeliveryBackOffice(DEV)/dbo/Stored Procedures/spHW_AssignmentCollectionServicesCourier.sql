-- =============================================
-- Author:		<Edelman>
-- Create date: <2022-09-22>
-- Description:	<Sp para asignar servicio de recolección a courierman>
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
                SELECT StatusOrderId
                FROM StatusOrder WITH(NOLOCK) 
                WHERE OrderDescription = 'Programado para recolección' COLLATE Latin1_General_CI_AI
            );


			SELECT 
					@SenderName   =   SMD.ServiceCustomerName,
					@SenderPhone  =  SMD.ServicePhone,
					@SenderAdress = SMD.ServiceAddress
			FROM [dbo].[ServiceManagementDetail] SMD WITH(NOLOCK) 
			WHERE 	SMD.ServiceManagement = @IdServiceManagment


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
							IdPuRouteAssigment = @idRouteAssigment,
							ServiceStatusId = @status,
							TokenUpdated = @Token,
							DateUpdated = GETDATE()
						WHERE IdServiceManagement = @IdServiceManagment 
	
			UPDATE [DeliveryBackOffice].[dbo].[SchedulePickup]
						SET  StartDate = GETDATE(),
							 EndDate = GETDATE(),
							 SenderName    =  @SenderName,
							 SenderPhone   =  @SenderPhone,
							 AddressPickup =  @SenderAdress
						WHERE SchedulePickupId = @IdServiceManagment 

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
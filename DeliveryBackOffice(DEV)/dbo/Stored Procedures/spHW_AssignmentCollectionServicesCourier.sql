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

	DECLARE @IDRUTETYPE AS INT=(SELECT IdTypeRoute FROM DBO.CatTypeRoute WITH (NOLOCK) WHERE Name ='Recolección' AND RowStatus=1);
	DECLARE @status INT =
            (
                SELECT StatusOrderId
                FROM StatusOrder
                WHERE OrderDescription = 'Programado para recolección'
            );
	
	SET NOCOUNT ON;
	IF(EXISTS(select TOP 1 1 from dbo.SchedulePickup where SchedulePickupId =36365))
	BEGIN
	UPDATE [DeliveryBackOffice].[dbo].[ServiceManagement]
				SET IdPuCourrier = @IdCurrierMan,
					IdPuRouteAssigment = @idRouteAssigment,
					ServiceStatusId = 2,
					TokenUpdated = @Token,
					DateUpdated = GETDATE()
				WHERE IdServiceManagement = @IdServiceManagment 
	
	         SELECT Result=1, Descrip='Ruta asignada exitosamente'

	END
	
END
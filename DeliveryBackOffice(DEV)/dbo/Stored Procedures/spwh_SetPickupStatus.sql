-- =============================================
-- Author:		<Alberto Ixchop>
-- Create date: <16-09-2022>
-- Description:	<Activa o desactiva un servicio de recolección (servicemanagement) y su respectiva recoleccion programada(schedulepickup) >
-- =============================================
CREATE PROCEDURE spwh_SetPickupStatus
	@ServiceManagementId INT,
	@Status BIT,
	@Token NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Control actualización
	DECLARE @RModified INT =0;

	DECLARE @IdchedulePickup BIGINT
	DECLARE @StatusOld INT;
	DECLARE @StatusNew INT;
	DECLARE @statusschedulepickup BIT;
	BEGIN TRANSACTION
	BEGIN TRY

		SELECT
		   @StatusOld = sm.ServiceStatusId
		   ,@IdchedulePickup=sm.IdSchedulePickup
		FROM ServiceManagement sm
		WHERE sm.IdServiceManagement = @ServiceManagementId

	    IF @StatusOld is not null and @StatusOld IN (SELECT IdServiceStatus FROM DBO.CatServiceStatus WHERE Name IN ('Creado','Asignado a ruta','Cancelado'))
		BEGIN
			IF @Status = 1
			BEGIN
				SET @StatusNew = (SELECT TOP 1
						smsl.ServiceStatusIdOld
					FROM ServiceManagementStatusLog smsl
					WHERE smsl.ServiceManagementId = @ServiceManagementId
					ORDER BY smsl.DateCreated DESC)
				IF @StatusNew IS NULL
					SET @StatusNew= (SELECT IdServiceStatus FROM DBO.CatServiceStatus WHERE Name ='Creado')
			END
			ELSE
				SET @StatusNew = (SELECT
						IdServiceStatus
					FROM CatServiceStatus
					WHERE Name = 'Cancelado')	

			IF @StatusOld IS NULL
				SET @StatusOld= (SELECT IdServiceStatus FROM DBO.CatServiceStatus WHERE Name ='Creado')

			UPDATE ServiceManagement
			SET ServiceStatusId = @StatusNew,
				TokenUpdated = @Token,
				DateUpdated = GETDATE()
			WHERE IdSchedulePickup = @IdchedulePickup

			UPDATE SchedulePickup
			SET	
				SchedulePickupStatus = @Status,
				TokenUpdated = @Token,
				DateUpdated = GETDATE()
			WHERE SchedulePickupId = @IdchedulePickup

			SET @RModified = @@ROWCOUNT
		END
		ELSE
			SELECT			  
				0 AS 'StatusCode',
				'Estado inválido para ser cancelado/activado' AS 'Description', 
				@StatusOld 'Status'

	END TRY
	BEGIN CATCH
	SELECT 
			0 'StatusCode', 
			ERROR_MESSAGE() 'Description', 
			@Status 'Status'
			ROLLBACK TRANSACTION;
	END CATCH

	IF (@RModified > 0)
	BEGIN

		INSERT INTO [dbo].[ServiceManagementStatusLog] ([ServiceManagementId]
		, [ServiceStatusIdOld]
		, [ServiceStatusIdNew]
		, [RowStatus]
		, [TokenCreated]
		, [DateCreated]
		, [TokenUpdated]
		, [DateUpdated])
			VALUES (@ServiceManagementId, @StatusOld, @StatusNew, 1, @Token, GETDATE(), NULL, NULL)

		INSERT INTO [dbo].[SchedulePickupStatusLog] ([SchedulePickupId]
		, [SchedulePickupStatus]
		, [RowStatus]
		, [TokenCreated]
		, [DateCreated]
		, [TokenUpdated]
		, [DateUpdated])
			VALUES (@IdchedulePickup, @Status, 1, @Token, GETDATE(), NULL, NULL)
		SELECT			  
			1 'StatusCode',
			'Registro actualizado correctamente' 'Description', 
			@Status 'Status'
			COMMIT TRANSACTION;
	END
	ELSE
		SELECT			  
			0 AS 'StatusCode',
			'Registro no encontrado' AS 'Description', 
			@Status 'Status'
END

-- =============================================
-- Author:		<Alberto Ixchop>
-- Create date: <16-09-2022>
-- Description:	<Activa o desactiva un servicio de recolección (servicemanagement) y su respectiva recoleccion programada(schedulepickup) >
-- =============================================
CREATE PROCEDURE [dbo].[spwh_SetPickupStatus]
	@ServiceManagementId INT,
	@Status BIT,
	@Token NVARCHAR(50),
	@Validate bit = 1--Activa o desactiva la validación de estados validos a ser activados/reactivados
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @TranCounter INT;  
    SET @TranCounter = @@TRANCOUNT;  
    IF @TranCounter > 0  
        SAVE TRANSACTION SPSetPickupStatus;  
    ELSE  
        BEGIN TRANSACTION;  

	-- Control actualización
	DECLARE @RModified INT =0;

	DECLARE @IdchedulePickup BIGINT
	DECLARE @StatusOld INT;
	DECLARE @StatusNew INT;
	DECLARE @statusschedulepickup BIT;
	BEGIN TRY

		SELECT
		   @StatusOld = sm.ServiceStatusId
		   ,@IdchedulePickup=sm.IdSchedulePickup
		FROM ServiceManagement sm
		WHERE sm.IdServiceManagement = @ServiceManagementId

	    IF @IdchedulePickup IS NOT NULL AND 
			(@Validate =0 OR (@StatusOld is not null and @StatusOld IN (SELECT IdServiceStatus FROM DBO.CatServiceStatus WHERE Name IN ('Creado','Asignado a ruta','Cancelado'))))
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
				'Estado inválido para ser cancelado/activado o servicio inexistente' AS 'Description', 
				@StatusOld 'Status';

		IF @TranCounter = 0  
            COMMIT TRANSACTION; 
	END TRY
	BEGIN CATCH
		SELECT 
			0 'StatusCode', 
			ERROR_MESSAGE() 'Description', 
			@Status 'Status';

        IF @TranCounter = 0  
            ROLLBACK TRANSACTION;  
        ELSE IF XACT_STATE() <> -1  
                ROLLBACK TRANSACTION SPSetPickupStatus;  
	END CATCH

	IF (@RModified > 0)
	BEGIN

        INSERT INTO EventService
        (
            ServiceManagementId,
            ServiceStatusId,
            RowStauts,
            TokenCreated,
            DateCreated,
            Observations
        )
        VALUES
        (	
			@ServiceManagementId, 
			@StatusNew, 
			1, 
			@Token, 
			GETDATE(), 
			IIF(@Status=1,'Servicio reactivado','Servicio cancelado')
		);
		SELECT			  
			1 'StatusCode',
			'Registro actualizado correctamente' 'Description', 
			@Status 'Status';
	END
	ELSE
		SELECT			  
			0 AS 'StatusCode',
			'Registro no encontrado' AS 'Description', 
			@Status 'Status';
END
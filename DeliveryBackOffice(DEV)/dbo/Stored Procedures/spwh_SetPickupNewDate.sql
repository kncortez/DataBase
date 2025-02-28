-- =============================================
-- Author:		<Aylinne Recinos>
-- Create date: <2025-01-15>
-- Description:	<Cambia la fecha programada para la recolección>
-- =============================================
CREATE PROCEDURE [dbo].[spwh_SetPickupNewDate]
	@ServiceManagementId INT,
	@NewDate DATETIME,
	@Token NVARCHAR(50)
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
	DECLARE @EndDate AS DATETIME;
	BEGIN TRY

		SELECT
		   @StatusOld = sm.ServiceStatusId
		   ,@IdchedulePickup=sm.IdSchedulePickup
		FROM ServiceManagement sm
		WHERE sm.IdServiceManagement = @ServiceManagementId

	    IF @IdchedulePickup IS NOT NULL AND 
			(@StatusOld is not null and @StatusOld IN (SELECT IdServiceStatus FROM DBO.CatServiceStatus WHERE Name IN ('Creado','Asignado a ruta','Reprogramado')))
		BEGIN
			SET @StatusNew= (SELECT IdServiceStatus FROM DBO.CatServiceStatus WHERE Name ='Reprogramado')

			SET @EndDate=DATEADD(HOUR,2,@NewDate)
			UPDATE ServiceManagement
			SET ServiceStatusId = @StatusNew,
				TokenUpdated = @Token,
				DateUpdated = GETDATE()
			WHERE IdSchedulePickup = @IdchedulePickup

			UPDATE SchedulePickup
			SET	
				StartDate = @NewDate,
				EndDate = @EndDate,
				TokenUpdated = @Token,
				DateUpdated = GETDATE()
			WHERE SchedulePickupId = @IdchedulePickup

			SET @RModified = @@ROWCOUNT
		END
		ELSE
			SELECT			  
				0 AS 'StatusCode',
				'Estado inválido para ser reprogramado o servicio inexistente' AS 'Description', 
				@StatusOld 'Status';

		IF @TranCounter = 0  
            COMMIT TRANSACTION; 
	END TRY
	BEGIN CATCH
		SELECT 
			0 'StatusCode', 
			ERROR_MESSAGE() 'Description'

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
			'Servicio reprogramado'
		);
		SELECT			  
			1 'StatusCode',
			'Registro actualizado correctamente' 'Description'
	END
	ELSE
		SELECT			  
			0 AS 'StatusCode',
			'Registro no encontrado' AS 'Description'
END
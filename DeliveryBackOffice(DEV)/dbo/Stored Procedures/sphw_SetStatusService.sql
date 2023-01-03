
-- =============================================
-- Author:		<Alberto Ixchop>
-- Create date: <23-09-2022>
-- Description:	<Método que modifica el estado de un servicio>
-- =============================================
CREATE PROCEDURE [dbo].[sphw_SetStatusService]
	-- Add the parameters for the stored procedure here
	@ServiceManagementId INT,
	@StateId INT,
	@Token NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @TranCounter INT;  
    SET @TranCounter = @@TRANCOUNT;  
    IF @TranCounter > 0  
        SAVE TRANSACTION SPSetStatusService;  
    ELSE  
        BEGIN TRANSACTION;  

	BEGIN TRY

		DECLARE @OLDSTATE INT = (SELECT ServiceManagement.ServiceStatusId FROM DBO.ServiceManagement WHERE IdServiceManagement=@ServiceManagementId);
		DECLARE @Status bit = NULL;--ACTIVAR/REACTIVAR
		DECLARE @RESULTPICKUPSTATUSEXECUTED TABLE
		(	StatusCode INT, 
			Description NVARCHAR(100),
			Status BIT
		);
		

		IF @StateId = (SELECT IdServiceStatus FROM CatServiceStatus WHERE Name = 'Cancelado')
		BEGIN
			--CANCELANDO SERVICIO
			SET @Status =0;
			INSERT INTO @RESULTPICKUPSTATUSEXECUTED
			(
				StatusCode,
				Description,
				Status
			)
			EXECUTE [dbo].[spwh_SetPickupStatus] 
			   @ServiceManagementId
			  ,@Status
			  ,@Token
			  ,0;
		END
		ELSE
		BEGIN
			IF @OLDSTATE =(SELECT IdServiceStatus FROM CatServiceStatus WHERE Name = 'Cancelado')--SI EL CASO ANTERIOR ERA CANCELADO Y SE REACTIVA
			BEGIN
				--REACTIVANDO SERVICIO
				SET @Status =1;
				INSERT INTO @RESULTPICKUPSTATUSEXECUTED
				(
					StatusCode,
					Description,
					Status
				)
				EXECUTE [dbo].[spwh_SetPickupStatus] 
				   @ServiceManagementId
				  ,@Status
				  ,@Token;			
			END
			UPDATE ServiceManagement
			SET ServiceStatusId = @StateId,
				TokenUpdated = @Token,
				DateUpdated = GETDATE()
			WHERE IdServiceManagement = @ServiceManagementId;

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
				@StateId, 
				1, 
				@Token, 
				GETDATE(), 
				CONCAT('Estado de servicio actualizado a ',(SELECT Name FROM dbo.CatServiceStatus WHERE IdServiceStatus=@StateId))
			);
			
		END

		IF  NOT EXISTS(SELECT StatusCode FROM @RESULTPICKUPSTATUSEXECUTED WHERE StatusCode = 0)
			SELECT			  
				1 AS 'StatusCode',
				'Estado de servicio actualizado correctamente' AS 'Description';
		ELSE
			SELECT StatusCode 'StatusCode', Description 'Description' FROM @RESULTPICKUPSTATUSEXECUTED ;
			
		IF @TranCounter = 0  
            COMMIT TRANSACTION; 
	END TRY
	BEGIN CATCH
        IF @TranCounter = 0  
            ROLLBACK TRANSACTION;  
        ELSE IF XACT_STATE() <> -1  
                ROLLBACK TRANSACTION SPSetStatusService;  
		SELECT			  
			0 AS 'StatusCode',
			ERROR_MESSAGE() AS 'Description';
	END CATCH

END
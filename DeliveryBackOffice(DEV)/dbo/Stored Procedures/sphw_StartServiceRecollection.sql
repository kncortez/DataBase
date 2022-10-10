-- =============================================
-- Author:		<Alberto, Ixchop>
-- Create date: <26-09-2022>
-- Description:	<Inicia un servicio de recolección>
-- =============================================
create PROCEDURE sphw_StartServiceRecollection
	-- Add the parameters for the stored procedure here	
	@CourierId INT,
	@ServiceManagementId INT,
	@Token VARCHAR(50)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @TranCounter INT;  
    SET @TranCounter = @@TRANCOUNT;  
    IF @TranCounter > 0  
        SAVE TRANSACTION SPStartServiceRecolection
    ELSE  
        BEGIN TRANSACTION;  

	BEGIN TRY					

		--DESACTIVANDO CUALQUIER SERVICIO MARCADO COMO ACTIVO EN LA FECHA ACTUAL DEL COURIER
		UPDATE SM SET
			SM.IsActiveService = 0,
			SM.TokenUpdated=@Token,
			SM.DateUpdated = GETDATE()
		FROM DBO.ServiceManagement SM
			INNER JOIN DBO.SchedulePickup SP ON SM.IdSchedulePickup=SP.SchedulePickupId
			LEFT JOIN DBO.RouteAssigment RA ON SM.IdPuRouteAssigment=RA.IdRouteAssigment
			INNER JOIN  DBO.SenderReceiver SR ON SR.ID=RA.IdCurrierMan
		WHERE
			SR.ID=@CourierId 
			AND SM.RowStatus= 1
			AND (IsActiveService=1 OR IsActiveService IS NULL)
			AND CONVERT(DATE,SP.StartDate)=CONVERT(DATE,GETDATE())
			AND SM.IdServiceManagement <> @ServiceManagementId;--FILTRANDO PARA FECHAS DEL DÍA DE HOY

		--MARCANDO SERVICIO COMO ACTIVO
		UPDATE SM SET
			SM.IsActiveService = (CASE WHEN SM.IsActiveService = 1 THEN 0 ELSE 1 END),
			SM.TokenUpdated=@Token,
			SM.DateUpdated = GETDATE()
		FROM DBO.ServiceManagement SM
			LEFT JOIN DBO.RouteAssigment RA ON SM.IdPuRouteAssigment=RA.IdRouteAssigment
			LEFT JOIN  DBO.SenderReceiver SR ON SR.ID=RA.IdCurrierMan
		WHERE 
			IdServiceManagement=@ServiceManagementId 
			AND SR.ID=@CourierId;

		SELECT			  
			1 AS 'StatusCode',
			'Servicio marcado como activo' AS 'Description';
		



		IF @TranCounter = 0  
            COMMIT TRANSACTION; 
	END TRY
	BEGIN CATCH
        IF @TranCounter = 0  
            ROLLBACK TRANSACTION;  
        ELSE IF XACT_STATE() <> -1  
                ROLLBACK TRANSACTION SPStartServiceRecolection;  
		SELECT			  
			0 AS 'StatusCode',
			ERROR_MESSAGE() AS 'Description';
	END CATCH


END
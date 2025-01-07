-- =============================================
-- Author:		<Aylinne Recinos>
-- Create date: <2024-21-10>
-- Description:	<Delivery Tracking - Método para validar las flags de cambio de fecha y cambio de direccion>
-- =============================================

CREATE PROCEDURE [dbo].[SPHW_ValidateFlags]
@GuideSerie NVARCHAR(4),
@GuideNumber INT
AS
BEGIN
BEGIN TRY

        DECLARE @StatusIncVal INT  = (  
        SELECT StatusOrderId FROM DeliveryBackOffice.dbo.StatusOrder  
        WHERE OrderDescription = 'Incidencia Validada'  
        )  

		DECLARE @StatusProcessFinal INT = (
		SELECT IdStatusProcess FROM DeliveryBackOffice.dbo.CatStatusProcess
		WHERE NameStatusProcess = 'Entregado'
		)
        DECLARE @f1 NVARCHAR(10) = (
			SELECT
				CASE
					WHEN 
						IsLastMileReturn = 1 OR
						(SELECT COUNT(CI.IdConfirmationOfIncidence) FROM DeliveryBackOffice.dbo.DeliveryAttempt DA WITH(NOLOCK)
						INNER JOIN DeliveryBackOffice.dbo.ConfirmationOfIncidence CI WITH(NOLOCK)
							ON DA.ConfirmationOfIncidenceId = CI.IdConfirmationOfIncidence
						WHERE DA.Guide_Serie = @GuideSerie AND DA.Guide_Number = @GuideNumber 
							AND CI.StatusOrderId = @StatusIncVal AND CI.IsConfirmed = 1 AND CI.IsDenied = 0) > 1 --INTENTO DEVOLUCIONES
						OR SO.CatStatusProcessId = @StatusProcessFinal --LA GU�A SE ENCUENTRA EN UN ESTADO ENTREGADO
					THEN 'false'
					ELSE 'true'
				END AS 'flagRescheduleDelivery'
			FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH(NOLOCK)
			INNER JOIN DeliveryBackOffice.dbo.StatusOrder SO WITH(NOLOCK)
				ON DO.StatusOrderId = SO.StatusOrderId
			WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber
			);

		DECLARE @f2 NVARCHAR(10) = (
			SELECT
				CASE
					WHEN 
						IsLastMileReturn = 1 OR
						(SELECT COUNT(CI.IdConfirmationOfIncidence) FROM DeliveryBackOffice.dbo.DeliveryAttempt DA WITH(NOLOCK)
						INNER JOIN DeliveryBackOffice.dbo.ConfirmationOfIncidence CI WITH(NOLOCK)
							ON DA.ConfirmationOfIncidenceId = CI.IdConfirmationOfIncidence
						WHERE DA.Guide_Serie = @GuideSerie AND DA.Guide_Number = @GuideNumber 
							AND CI.StatusOrderId = @StatusIncVal AND CI.IsConfirmed = 1 AND CI.IsDenied = 0) > 1 --INTENTO DEVOLUCIONES
						OR SO.CatStatusProcessId = @StatusProcessFinal --LA GU�A SE ENCUENTRA EN UN ESTADO ENTREGADO
					THEN 'false'
					ELSE 'true'
				END AS 'flagChangeAdress'
			FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH(NOLOCK)
			INNER JOIN DeliveryBackOffice.dbo.StatusOrder SO WITH(NOLOCK)
				ON DO.StatusOrderId = SO.StatusOrderId
			WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber
			); 
	--Validación del telefono
	 SELECT   
		ISNULL(@f1,'false') AS 'flagRescheduleDelivery', 
		ISNULL(@f2,'false') AS 'flagChangeAdress'   
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
END;
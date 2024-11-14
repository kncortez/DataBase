-- =============================================
-- Author:		<Aylinne Recinos>
-- Create date: <2024-11-14>
-- Description:	<Delivery Tracking - Método para actualizar el estado de la orden para reimpresión>
-- =============================================

CREATE PROCEDURE [dbo].[SPHW_UpdateStateTracking]
@GuideSerie NVARCHAR(4),
@GuideNumber INT,
@Status NVARCHAR(3)
AS
BEGIN
BEGIN TRY
    BEGIN TRANSACTION  
    -- D - Cambio dirección
	UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrder]
		SET Changed_Tracking = @Status, 
            TokenUpdated = 'SYS-ADMIN-MOVIL-APP',
		    DateUpdated = GETDATE()
	WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber;
	IF @@TRANCOUNT > 0 
	BEGIN  
	COMMIT TRANSACTION;  
	SELECT 1 AS [StatusCode], 'Actualizacion exitosa' AS[MessageResponse] 
	END  
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
END;
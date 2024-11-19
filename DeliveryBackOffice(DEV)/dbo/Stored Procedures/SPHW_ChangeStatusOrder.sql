-- =============================================
-- Author:		<Aylinne Recinos>
-- Create date: <2024-11-18>
-- Description:	<Delivery Tracking - Método para actualizar el estado de la orden>
-- =============================================

CREATE PROCEDURE [dbo].[SPHW_ChangeStatusOrder]
@GuideSerie NVARCHAR(4),
@GuideNumber INT,
@Piece INT,
@Status INT,
@Token NVARCHAR(80)
AS
BEGIN
BEGIN TRY
    BEGIN TRANSACTION  
    UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrder]
			SET StatusOrderId = @Status, 
				TokenUpdated = @Token,
				DateUpdated = GETDATE()
		WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber;
    
    UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrderPiece]
			SET StatusOrderId = @Status, 
				DateUpdated = GETDATE()
		WHERE GuideSerie = @GuideSerie AND GuideNumber = @GuideNumber AND NoPiece = @Piece;
	
	IF @@TRANCOUNT > 0 
	BEGIN  
	COMMIT TRANSACTION;  
	SELECT 1 AS [StatusCode], 'Actualizacion de estado exitosa' AS[MessageResponse] 
	END  
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
END;
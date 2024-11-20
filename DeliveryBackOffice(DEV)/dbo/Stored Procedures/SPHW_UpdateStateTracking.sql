-- =============================================
-- Author:		<Aylinne Recinos>
-- Create date: <2024-11-14>
-- Description:	<Delivery Tracking - Método para actualizar el estado de la orden para reimpresión>
-- =============================================

CREATE PROCEDURE [dbo].[SPHW_UpdateStateTracking]
@GuideSerie NVARCHAR(4),
@GuideNumber INT,
@System NVARCHAR(80) = NULL,
@User NVARCHAR(80) = NULL,
@Status BIT,
@Token NVARCHAR(80)
AS
BEGIN
BEGIN TRY
    BEGIN TRANSACTION  
    IF EXISTS(SELECT TOP 1 1 FROM ReprintOrderTracking WHERE GuideSerie = @GuideSerie AND GuideNumber = @GuideNumber)
	BEGIN 
		UPDATE [DeliveryBackOffice].[dbo].[ReprintOrderTracking]
			SET IsPendingReprint = @Status, 
				SystemReprint = @System,
				UserReprint = @User,
				TokenUpdated = @Token,
				DateUpdated = GETDATE()
		WHERE GuideSerie = @GuideSerie AND GuideNumber = @GuideNumber;
	END
	ELSE 
	BEGIN 
		INSERT INTO [DeliveryBackOffice].[dbo].[ReprintOrderTracking]
		(
		  [GuideSerie]
		, [GuideNumber]
		, [SystemReprint]
		, [UserReprint]
		, [IsPendingReprint]
		, [TokenCreated]
		, [DateCreated]
		) VALUES (@GuideSerie, @GuideNumber, @System, @User, @Status, @Token, GETDATE())
	END
	
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
-- =============================================
-- Author:		<Aylinne Recinos>
-- Create date: <2025-31-01>
-- Description:	<Método para marcar como leída una notificación>
-- =============================================
CREATE PROCEDURE [dbo].[SPWS_ReadNotifications]
@IdNotification INT,
@TypeSuscription INT,
@User NVARCHAR(50),
@Token NVARCHAR(50)
AS
BEGIN
    BEGIN TRANSACTION
    BEGIN TRY
        IF(@TypeSuscription = 1) --Notificación de tracking
        BEGIN
            UPDATE NotificationTrackingLog 
            SET IsRead = 1,
                DateUpdated = GETDATE(),
                UserUpdated = @User,
                TokenUpdated = @Token
            WHERE IdNotificationTrackingLog = @IdNotification
            SELECT 1 AS [StatusCode], 'Notificación actualizada exitosamente' AS [Message]
            COMMIT TRANSACTION;
        END
        ELSE -- Notificación general
        BEGIN
            UPDATE NotificationGeneralLog
            SET IsRead = 1,
                DateUpdated = GETDATE(),
                UserUpdated = @User,
                TokenUpdated = @Token
            WHERE IdNotificationGeneralLog = @IdNotification
            SELECT 1 AS [StatusCode], 'Notificación actualizada exitosamente' AS [Message]
            COMMIT TRANSACTION;
        END
    END TRY
    BEGIN CATCH
        SELECT 0 AS [StatusCode], ERROR_MESSAGE() AS [Message]
        ROLLBACK TRANSACTION
            INSERT INTO dbo.RoutePreparationLogError
            (
                ErrorDescription,
                ErrorNumber,
                ErrorProcedure,
                ErrorLine,
                GuideSerie,
                GuideNumber,
                TokenCreated,
                DateCreated
            )
            VALUES
            (CAST(ERROR_MESSAGE() AS VARCHAR(300))
                    ,ERROR_NUMBER()
                    ,CAST(ERROR_PROCEDURE() AS VARCHAR(100))
                    ,ERROR_LINE()
                    ,0
                    ,0
                    ,'Error al consultar las notificaciones'
                    ,GETDATE())
    END CATCH;
END
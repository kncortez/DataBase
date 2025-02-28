-- =============================================
-- Author:		<Aylinne Recinos>
-- Create date: <2025-24-01>
-- Description:	<Método para desactivar las notificaciones del dispositivo>
-- =============================================
CREATE PROCEDURE [dbo].[SPWS_CancelGeneralNotifications]
@IdOneSignal NVARCHAR(100),
@IdAccount INT = NULL,
@User NVARCHAR(50),
@Token NVARCHAR(50)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
        -- Desactivar las notificaciones generales
            UPDATE NotificationGeneral
            SET RowStatus = 0,
            UserUpdated = @User,
            TokenUpdated = @Token,
            DateUpdated = GETDATE()
            WHERE IdOneSignal = @IdOneSignal
            AND (@IdAccount = 0 OR @IdAccount IS NULL OR IdAccount = @IdAccount)
            AND RowStatus = 1;

        -- Desactivar las notificaciones de las guías
            DECLARE @IdNotificationTracking INT = (SELECT IdNotificationTracking 
                                                    FROM NotificationTracking 
                                                    WHERE IdOneSignal = @IdOneSignal 
                                                    AND (@IdAccount = 0 OR @IdAccount IS NULL OR IdAccount = @IdAccount)
                                                    AND RowStatus = 1) 

            UPDATE GuideSuscription
            SET RowStatus = 0,
            UserUpdated = @User,
            TokenUpdated = @Token,
            DateUpdated = GETDATE()
            WHERE IdNotificationTracking = @IdNotificationTracking
            AND RowStatus = 1;

            UPDATE NotificationTracking
            SET RowStatus = 0,
            UserUpdated = @User,
            TokenUpdated = @Token,
            DateUpdated = GETDATE()
            WHERE IdNotificationTracking = @IdNotificationTracking



            IF(@@ROWCOUNT > 0)
            BEGIN
                SELECT 1 AS [StatusCode], 'Se han desactivado las notificaciones exitosamente.' AS [Message]
                COMMIT TRANSACTION;
            END
            ELSE 
            BEGIN
                SELECT 0 AS [StatusCode], 'El usuario no se encuentra suscrito a notificaciones.' AS [Message]
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
                ,'Error al desactivar las notificaciones'
                ,GETDATE())
    END CATCH;
END
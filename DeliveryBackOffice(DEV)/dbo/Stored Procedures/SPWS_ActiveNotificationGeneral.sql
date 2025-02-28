-- =============================================
-- Author:		<Aylinne Recinos>
-- Create date: <2025-21-01>
-- Description:	<Método para guardar el registro de la activación de notificaciones en One Signal>
-- =============================================
CREATE PROCEDURE [dbo].[SPWS_ActiveNotificationGeneral]
@IdOneSignal NVARCHAR(50),
@IdTypeSuscription INT,
@IdAccount BIGINT,
@User NVARCHAR(50),
@Token NVARCHAR(50)
AS
BEGIN
    BEGIN TRANSACTION
        BEGIN TRY
            DECLARE @IdNotificationGeneral INT;
            DECLARE @StatusNotification BIT;

            SELECT @IdNotificationGeneral = IdNotificationGeneral, 
                   @StatusNotification = RowStatus
            FROM NotificationGeneral 
            WHERE IdOneSignal = @IdOneSignal

            IF(@IdNotificationGeneral IS NULL)
            BEGIN
                INSERT INTO dbo.NotificationGeneral ([IdOneSignal], [IdAccount], [IdTypeSuscription], [UserCreated], [DateCreated], [TokenCreated])
                VALUES(@IdOneSignal, @IdAccount, @IdTypeSuscription, @User, GETDATE(), @Token)
                
                SELECT 1 AS [StatusCode], 'Se han activado las notificaciones de forma exitosa' AS [Message]
                COMMIT TRANSACTION;
            END
            ELSE IF(@StatusNotification = 0)
            BEGIN
                UPDATE dbo.NotificationGeneral
                SET RowStatus = 1,
                    IdAccount = @IdAccount,
                    UserUpdated = @User,
                    DateUpdated = GETDATE(),
                    TokenUpdated = @Token
                WHERE IdNotificationGeneral = @IdNotificationGeneral

                SELECT 1 AS [StatusCode], 'Se han activado las notificaciones de forma exitosa' AS [Message]
                COMMIT TRANSACTION;
            END
            ELSE
            BEGIN
                SELECT 0 AS [StatusCode], 'El usuario ya está suscrito a las notificaciones' AS [Message]
                ROLLBACK TRANSACTION
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
                        ,'Error en suscripción a notificaciones'
                        ,GETDATE())
        END CATCH;
END
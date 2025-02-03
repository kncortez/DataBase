-- =============================================
-- Author:		<Aylinne Recinos>
-- Create date: <2025-22-01>
-- Description:	<Método para guardar el mensaje y obtener el OneSignalId y el Account Id del usuario>
-- =============================================
CREATE PROCEDURE [dbo].[SPWS_ValidateNotificationTrack]
@GuideSerie NVARCHAR(2),
@GuideNumber INT,
@Title NVARCHAR(50),
@Message NVARCHAR(150),
@Action INT,
@User NVARCHAR(50),
@Token NVARCHAR(50)
AS
BEGIN
    BEGIN TRANSACTION
        BEGIN TRY
            DECLARE @IdNotificationTracking INT;
            DECLARE @StatusGuide BIT;

            SELECT  @IdNotificationTracking = IdNotificationTracking
            FROM GuideSuscription WHERE GuideSerie = @GuideSerie AND GuideNumber = @GuideNumber AND RowStatus = 1;

            IF(@IdNotificationTracking IS NOT NULL)
            BEGIN 
                INSERT INTO dbo.NotificationTrackingLog ([Title], [Message], [StatusOrderId], [IdNotificationTracking], [IdActionNotification],[GuideSerie],[GuideNumber], [UserCreated], [DateCreated], [TokenCreated])
                SELECT  @Title, 
                        @Message,
                        do.StatusOrderId,
                        @IdNotificationTracking,
                        @Action,
                        @GuideSerie,
                        @GuideNumber,
                        @User, 
                        GETDATE(), 
                        @Token
                FROM DeliveryOrder do WITH(NOLOCK)
                WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber

                SELECT 1 AS [StatusCode],
                        [IdOneSignal],
                        ISNULL(IdAccount, 0) AS [IdAccount]
                FROM NotificationTracking WHERE IdNotificationTracking = @IdNotificationTracking
                COMMIT TRANSACTION;
            END
            ELSE
            BEGIN
                -- La guía no está suscrita a notificaciones
                SELECT 2 AS [StatusCode]
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
                        ,'Error al insertar notificacion'
                        ,GETDATE())
        END CATCH;
END
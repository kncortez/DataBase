-- =============================================
-- Author:		<Aylinne Recinos>
-- Create date: <2025-17-01>
-- Description:	<Método para guardar el registro de la activación de notificaciones en One Signal>
-- =============================================
CREATE PROCEDURE [dbo].[SPWS_ActiveNotificationTracking]
@GuideSerie NVARCHAR(2),
@GuideNumber INT,
@IdOneSignal NVARCHAR(50),
@IdTypeSuscription INT,
@IdAccount BIGINT = NULL,
@User NVARCHAR(50),
@Token NVARCHAR(50)
AS
BEGIN
    BEGIN TRANSACTION
        BEGIN TRY
            DECLARE @IdNotificationTracking INT;
            DECLARE @IdGuideSuscription INT;
            DECLARE @StatusNotification BIT;
            DECLARE @StatusGuide BIT;
            SELECT  @IdGuideSuscription = IdGuideSuscription,
                    @StatusGuide = RowStatus
            FROM GuideSuscription WHERE GuideSerie = @GuideSerie AND GuideNumber = @GuideNumber;

            IF(@IdGuideSuscription IS NULL)
            BEGIN 
                SELECT  @IdNotificationTracking = IdNotificationTracking, 
                        @StatusNotification = RowStatus
                FROM NotificationTracking 
                WHERE IdOneSignal = @IdOneSignal

                IF(@IdNotificationTracking IS NULL)
                BEGIN
                    INSERT INTO dbo.NotificationTracking ([IdOneSignal], [IdAccount], [IdTypeSuscription], [UserCreated], [DateCreated], [TokenCreated])
                    VALUES(@IdOneSignal, IIF(@IdAccount = 0, NULL, @IdAccount), @IdTypeSuscription, @User, GETDATE(), @Token)

                    SET @IdNotificationTracking = SCOPE_IDENTITY();
                END
                ELSE IF(@StatusNotification = 0)
                BEGIN
                    UPDATE dbo.NotificationTracking
                    SET RowStatus = 1,
                        IdAccount = IIF(@IdAccount = 0, NULL, @IdAccount),
                        UserUpdated = @User,
                        DateUpdated = GETDATE(),
                        TokenUpdated = @Token
                    WHERE IdNotificationTracking = @IdNotificationTracking
                END

                INSERT INTO dbo.GuideSuscription ([IdNotificationTracking], [GuideSerie], [GuideNumber], [UserCreated], [DateCreated], [TokenCreated])
                VALUES(@IdNotificationTracking, @GuideSerie, @GuideNumber, @User, GETDATE(), @Token)

                SELECT 1 AS [StatusCode], 'Los datos se han confirmado exitosamente. Te estaremos notificando todo acerca de esta guía.' AS [Message]
                COMMIT TRANSACTION;
            END
            ELSE
            BEGIN
                IF(@StatusGuide = 1)
                BEGIN
                    SELECT 0 AS [StatusCode], '¡No te preocupes! Activaste las notificaciones de esta guía previamente. Seguiremos informándote.' AS [Message]
                    ROLLBACK TRANSACTION
                END
                ELSE
                BEGIN
                    SELECT  @IdNotificationTracking = IdNotificationTracking, 
                            @StatusNotification = RowStatus
                    FROM NotificationTracking 
                    WHERE IdOneSignal = @IdOneSignal
                    
                    IF(@IdNotificationTracking IS NULL)
                    BEGIN
                        INSERT INTO dbo.NotificationTracking ([IdOneSignal], [IdAccount], [IdTypeSuscription], [UserCreated], [DateCreated], [TokenCreated])
                        VALUES(@IdOneSignal, IIF(@IdAccount = 0, NULL, @IdAccount), @IdTypeSuscription, @User, GETDATE(), @Token)

                        SET @IdNotificationTracking = SCOPE_IDENTITY();
                    END
                    ELSE IF(@StatusNotification = 0)
                    BEGIN
                        UPDATE dbo.NotificationTracking
                        SET RowStatus = 1,
                            IdAccount = IIF(@IdAccount = 0, NULL, @IdAccount),
                            UserUpdated = @User,
                            DateUpdated = GETDATE(),
                            TokenUpdated = @Token
                        WHERE IdNotificationTracking = @IdNotificationTracking
                    END

                    UPDATE dbo.GuideSuscription
                    SET RowStatus = 1,
                        IdNotificationTracking = @IdNotificationTracking,
                        UserUpdated = @User,
                        DateUpdated = GETDATE(),
                        TokenUpdated = @Token
                    WHERE GuideSerie = @GuideSerie AND GuideNumber = @GuideNumber

                    SELECT 1 AS [StatusCode], 'Los datos se han confirmado exitosamente. Te estaremos notificando todo acerca de esta guía.' AS [Message]
                    COMMIT TRANSACTION;
                END
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
                        ,'Error en suscripción de guías'
                        ,GETDATE())
        END CATCH;
END
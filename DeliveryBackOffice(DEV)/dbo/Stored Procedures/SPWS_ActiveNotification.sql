-- =============================================
-- Author:		<Aylinne Recinos>
-- Create date: <2025-17-01>
-- Description:	<Método para guardar el registro de la activación de notificaciones en One Signal>
-- =============================================
CREATE PROCEDURE [dbo].[SPWS_ActiveNotification]
@Phone NVARCHAR(15),
@GuideSerie NVARCHAR(2),
@GuideNumber INT,
@IdOneSignal NVARCHAR(50),
@IdSuscription NVARCHAR(50),
@IdTypeSuscription INT,
@User NVARCHAR(50),
@Token NVARCHAR(50)
AS
BEGIN
    DECLARE @IdNotificationSuscription INT;
    DECLARE @IdUserSuscription INT;
    DECLARE @IdGuideSuscription INT;
    DECLARE @GuideStatus BIT;
    BEGIN TRANSACTION
        BEGIN TRY
             SELECT @IdNotificationSuscription = ns.IdNotificationSuscription,
                    @IdUserSuscription = us.IdUserSuscription,
                    @IdGuideSuscription = gs.IdGuideSuscription,
                    @GuideStatus = gs.RowStatus -- Valida si la guía tiene una suscripción activa
                FROM NotificationSuscription ns 
                INNER JOIN UserSuscription us ON us.IdNotificationSuscription = ns.IdNotificationSuscription
                INNER JOIN GuideSuscription gs ON gs.IdUserSuscription = us.IdUserSuscription
                WHERE ns.Phone = @Phone 
                AND ns.IdOneSignal = @IdOneSignal --Valida que exista el usuario en One Signal
                AND gs.GuideNumber = @GuideNumber --Valida si la guía ya está suscrita a las notificaciones
                AND gs.GuideSerie = @GuideSerie
                AND ns.RowStatus = 1
                AND us.RowStatus = 1

            IF(@IdNotificationSuscription IS NULL) 
            BEGIN
                SELECT @IdNotificationSuscription = IdNotificationSuscription FROM NotificationSuscription WHERE Phone = @Phone AND IdOneSignal = @IdOneSignal
                IF(@IdNotificationSuscription IS NULL)
                BEGIN 
                    INSERT INTO dbo.NotificationSuscription ([Phone], [IdOneSignal], [UserCreated], [DateCreated], [TokenCreated])
                    VALUES(@Phone, @IdOneSignal, @User, GETDATE(), @Token)
                    SET @IdNotificationSuscription = SCOPE_IDENTITY();
                END

                SELECT @IdUserSuscription = IdUserSuscription FROM UserSuscription WHERE IdSuscription = @IdSuscription AND IdNotificationSuscription = @IdNotificationSuscription
                IF(@IdUserSuscription IS NULL)
                BEGIN 
                    INSERT INTO dbo.UserSuscription ([IdNotificationSuscription], [IdSuscription], [IdTypeSuscription], [UserCreated], [DateCreated], [TokenCreated])
                    VALUES(@IdNotificationSuscription, @IdSuscription, @IdTypeSuscription, @User, GETDATE(), @Token)
                    SET @IdUserSuscription = SCOPE_IDENTITY();
                END
                
                INSERT INTO dbo.GuideSuscription ([IdUserSuscription], [GuideSerie], [GuideNumber], [UserCreated], [DateCreated], [TokenCreated])
                VALUES(@IdUserSuscription, @GuideSerie, @GuideNumber, @User, GETDATE(), @Token)
                SELECT 1 AS [StatusCode], 'La guía ha sido suscrita a las notificaciones de forma exitosa' AS [Message]
                COMMIT TRANSACTION;
            END 
            ELSE
            BEGIN 
                -- Si el usuario tiene las notificaciones y suscripción activas y la suscripción a la guía está desactivada
                IF (@GuideStatus = 0)
                BEGIN
                    UPDATE dbo.GuideSuscription
                    SET RowStatus = 1,
                        UserUpdated = @User,
                        DateUpdated = GETDATE(),
                        TokenUpdated = @Token
                    WHERE GuideSerie = @GuideSerie 
                        AND GuideNumber = @GuideNumber 
                        AND IdUserSuscription = @IdUserSuscription
                    
                    SELECT 1 AS [StatusCode], 'La guía ha sido suscrita a las notificaciones de forma exitosa' AS [Message]
                END
                ELSE
                BEGIN
                    SELECT 0 AS [StatusCode], 'La guía ya está suscrita a las notificaciones' AS [Message]
                    ROLLBACK TRANSACTION
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
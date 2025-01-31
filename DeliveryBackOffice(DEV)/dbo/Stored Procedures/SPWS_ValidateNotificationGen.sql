-- =============================================
-- Author:		<Aylinne Recinos>
-- Create date: <2025-24-01>
-- Description:	<Método para guardar el mensaje y validar si cuenta con suscripción activa>
-- =============================================
CREATE PROCEDURE [dbo].[SPWS_ValidateNotificationGen]
@Title NVARCHAR(50),
@Message NVARCHAR(150),
@IdAccount INT,
@Action INT,
@User NVARCHAR(50),
@Token NVARCHAR(50)
AS
BEGIN
    BEGIN TRANSACTION
        BEGIN TRY
            DECLARE @IdNotificationGeneral INT;

            SELECT  @IdNotificationGeneral = IdNotificationGeneral
            FROM NotificationGeneral WHERE IdAccount = @IdAccount AND RowStatus = 1;

            IF(@IdNotificationGeneral IS NOT NULL)
            BEGIN 
                INSERT INTO dbo.NotificationGeneralLog ([Title], [Message], [IdNotificationGeneral], [IdActionNotification], [UserCreated], [DateCreated], [TokenCreated])
                VALUES (@Title, @Message, @IdNotificationGeneral, @Action, @User, GETDATE(), @Token)

                SELECT 1 AS [StatusCode]
                COMMIT TRANSACTION;
            END
            ELSE
            BEGIN
                -- El usuario no está suscrito a notificaciones
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
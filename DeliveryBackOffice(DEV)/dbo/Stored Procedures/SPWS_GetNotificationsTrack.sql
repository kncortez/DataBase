-- =============================================
-- Author:		<Aylinne Recinos>
-- Create date: <2025-24-01>
-- Description:	<Método para devolver las notificaciones de tracking del usuario>
-- =============================================
CREATE PROCEDURE [dbo].[SPWS_GetNotificationsTrack]
@IdOneSignal NVARCHAR(100),
@IdAccount INT = NULL
AS
BEGIN
    BEGIN TRY
        DECLARE @IdNotificationTracking INT;

        SELECT  @IdNotificationTracking = IdNotificationTracking
        FROM dbo.NotificationTracking 
        WHERE IdOneSignal = @IdOneSignal
        AND (@IdAccount = 0 OR IdAccount = @IdAccount)
        AND RowStatus = 1;

        SELECT [Title], [Message] 
        FROM dbo.NotificationTrackingLog 
        WHERE IdNotificationTracking = @IdNotificationTracking
    END TRY
    BEGIN CATCH
        SELECT 0 AS [StatusCode], ERROR_MESSAGE() AS [Message]
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
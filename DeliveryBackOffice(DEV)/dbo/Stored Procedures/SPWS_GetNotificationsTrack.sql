-- =============================================
-- Author:		<Aylinne Recinos>
-- Create date: <2025-24-01>
-- Description:	<Método para devolver las notificaciones de tracking del usuario>
-- =============================================
CREATE PROCEDURE [dbo].[SPWS_GetNotificationsTrack]
@IdOneSignal NVARCHAR(100),
@IdAccount INT = NULL,
@PageNumber INT,
@PageSize INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @offset INT = (@PageNumber - 1) * @PageSize;
    BEGIN TRY
        DECLARE @IdNotificationTracking INT;

        SELECT  @IdNotificationTracking = IdNotificationTracking
        FROM dbo.NotificationTracking 
        WHERE IdOneSignal = @IdOneSignal
        AND (@IdAccount = 0 OR IdAccount = @IdAccount)
        AND RowStatus = 1;

        SELECT [IdNotificationTrackingLog], [Title], [Message], [IdActionNotification], 1 AS [TypeSuscription], [DateCreated]
        FROM dbo.NotificationTrackingLog 
        WHERE IdNotificationTracking = @IdNotificationTracking
        AND IsRead = 0
        ORDER BY DateCreated DESC
        OFFSET @offset ROWS FETCH NEXT @PageSize ROWS ONLY
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
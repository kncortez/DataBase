-- =============================================
-- Author:		<Jerson Ochoa>
-- Create date: <04-05-2023>
-- Description:	<Set a notification queue item as sent>
-- =============================================
CREATE PROCEDURE [dbo].[spNS_SetNotificationsQueueItemAsSent]
	@NotificationQueueId AS INT, 
	@Token AS NVARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRANSACTION
	BEGIN TRY
		
		UPDATE	[dbo].[NotificationQueue]
		SET		[IsSent] = 1,
				[AttemptsRemaining] = [AttemptsRemaining] - 1,
				[TokenUpdated] = @Token,
				[DateUpdated] = SYSDATETIME()
		WHERE	[IdNotificationQueue] = @NotificationQueueId;

		IF @@TRANCOUNT > 0 COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH

		SELECT  
			ERROR_NUMBER() AS spResult  
            ,ERROR_SEVERITY() AS ErrorSeverity  
            ,ERROR_STATE() AS ErrorState  
            ,ERROR_PROCEDURE() AS ErrorProcedure  
            ,ERROR_LINE() AS ErrorLine  
            ,ERROR_MESSAGE() AS spMessage;
		
		ROLLBACK TRANSACTION;

	END CATCH
END
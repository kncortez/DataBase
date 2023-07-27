-- =============================================
-- Author:		<Jerson Ochoa>
-- Create date: <08-05-2023>
-- Description:	<Update attempts remaining from Notification Queue>
-- =============================================
CREATE PROCEDURE [dbo].[spNS_UpdateAttemptsRemainingNotificationQueue]
	@NotificationQueueId AS INT,
	@Token AS NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRANSACTION
	BEGIN TRY
		UPDATE	[dbo].[NotificationQueue]
		SET		[AttemptsRemaining] = [AttemptsRemaining] - 1,
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

-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-09-13>
-- Description:	< Registrar en bitácora los datos enviados y recibido >
-- =============================================
CREATE PROCEDURE [dbo].[SetWebhookLog]
    @WebhookTrackingQueueId bigint,
    @DataSent nvarchar(max),
    @DataReceived nvarchar(max),
	@Token NVARCHAR(50) = 'SYS-HERMESWEBHOOKS'
AS 
BEGIN

    SET NOCOUNT ON

    BEGIN TRANSACTION
	BEGIN TRY
		DECLARE @InsertedData AS TABLE (
			InsertedId BIGINT
		)

		UPDATE
			[DeliveryBackOffice].[dbo].[WebhookTrackingQueue]
		SET
			HasNotified = 1
			,NotificationDate = GETDATE()
			,TokenUpdated = @Token
			,DateUpdated = GETDATE()
		WHERE
			IdWebhookTrackingQueue = @WebhookTrackingQueueId

		INSERT INTO [DeliveryBackOffice].[dbo].[WebhookLog]
			(WebhookTrackingQueueId, DataReceived, DataSent, RowStatus, TokenCreated, DateCreated )
		OUTPUT inserted.IdWebhookLog INTO @InsertedData(InsertedId)
		VALUES
			(@WebhookTrackingQueueId, @DataReceived, @DataSent, 1, @Token, GETDATE())

		IF ( EXISTS (SELECT TOP 1 1 FROM @InsertedData) )
		BEGIN

			COMMIT TRANSACTION;

			SELECT
				CAST(1 AS BIT) [blnResult],
				'Exito registrando bitácora' [resultMessage]

		END
		ELSE
		BEGIN

			ROLLBACK TRANSACTION;
			
			SELECT
				CAST(0 AS BIT) [blnResult],
				'Error registrando bitácora' [resultMessage]

		END
	END TRY
	BEGIN CATCH

		ROLLBACK TRANSACTION;
		
		SELECT
			CAST(0 AS BIT) [blnResult],
			ERROR_MESSAGE() [resultMessage]

	END CATCH

END
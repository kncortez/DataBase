
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-09-13>
-- Description:	< Registrar en bitácora los datos enviados y recibido >
-- =============================================
CREATE PROCEDURE [dbo].[SetWebhookLogWithDates]
    @WebhookTrackingQueueId BIGINT,
    @DataSent NVARCHAR(MAX),
    @DataReceived nvarchar(max),
	@Token NVARCHAR(50) = 'SYS-HERMESWEBHOOKS',
	@DateIni DATETIME,
	@DateBeforeClient DATETIME,
	@DateAfterClient DATETIME,
	@DateFinish DATETIME

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

		INSERT INTO [DeliveryBackOffice].[dbo].[WebhookLogWithDates]
			(WebhookTrackingQueueId, DataReceived, DataSent, RowStatus, TokenCreated, DateCreated,DateIni,DateBeforeClient,DateAfterClient )
		OUTPUT inserted.IdWebhookLog INTO @InsertedData(InsertedId)
		VALUES
			(@WebhookTrackingQueueId, @DataReceived, @DataSent, 1, @Token, @DateFinish,@DateIni,@DateBeforeClient,@DateAfterClient)

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
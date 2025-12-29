
/* =================================================
   SP:        GetCourierLoginToken
   Propósito: Genera o obtiene el token para login en Courier App
   Autor:     Oscar Morales
   Historia:  ---
   Fecha:     2023-04-24

=== CHANGELOG ============================

2024-07-29 | Historia/épica: ---            | Autor: Cristian Suazo  | 
2025-12-10 | Historia/épica: FDAPI-4733     | Autor: Cristian Suazo  | 

=========================================== */
CREATE PROCEDURE [dbo].[GetCourierLoginToken]
    -- Add the parameters for the stored procedure here
    @Phone NVARCHAR(20)
  , @NotificationEmail INT
  , @IdCountry nvarchar(8) = 'GT'

AS
BEGIN
 	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set nocount on;

    BEGIN TRANSACTION

	BEGIN TRY
		
		DECLARE @StationId INT;
		DECLARE @MaxValue INT;
		SET @MaxValue = (SELECT TOP 1 Value FROM ConfigParams WITH(NOLOCK) WHERE Name = 'MaxNumMessagesAllowed')

		DECLARE @SenderReceiverId INT =
                ( 
					SELECT	TOP 1
							ID
					FROM	DeliveryBackOffice.dbo.SenderReceiver WITH(NOLOCK)
					WHERE	Phone LIKE @Phone + '%'
						AND IdCountry = @IdCountry
						AND Estatus = 1
				); 

		DECLARE @Email AS NVARCHAR(50) =  
				( 
					SELECT	TOP 1
							Email
					FROM	DeliveryBackOffice.dbo.SenderReceiver WITH(NOLOCK)
					WHERE	Phone LIKE @Phone + '%'
							AND IdCountry = @IdCountry
							AND Estatus = 1
				);

		
		SET @StationId = 
		   (	
				SELECT HL.IdStation 
				FROM DeliveryBackOffice.dbo.SenderReceiver SR WITH (NOLOCK)
				LEFT JOIN DeliveryBackOffice.dbo.HubLogistics HL WITH (NOLOCK)
					ON SR.HubLogisticId = HL.IdHubLogistic
				WHERE SR.ID = @SenderReceiverId AND HL.IdCountry = @IdCountry
			);

		IF @SenderReceiverId IS NOT NULL
		BEGIN 

			DECLARE @LoginToken NVARCHAR(6)

			SELECT 
					@LoginToken = LoginToken
			FROM	DeliveryBackOffice.dbo.SenderReceiverLoginToken WITH(NOLOCK)
			WHERE	SenderReceiverId = @SenderReceiverId
				AND RowStatus = 1
			
			IF @LoginToken IS NULL
			BEGIN
				SET @LoginToken = (SELECT ROUND(((999999 - 111111) * RAND() + 111111), 0))

				INSERT INTO DeliveryBackOffice.dbo.SenderReceiverLoginToken (LoginToken, SenderReceiverId, RowStatus, TokenCreated, DateCreated)
				VALUES (@LoginToken, @SenderReceiverId, 1, 'SetCourierLoginToken', GETDATE())
			END

			COMMIT TRANSACTION

				DECLARE @DateToken DateTime;
				SET @DateToken = (SELECT Date_UpdateToken FROM DeliveryBackOffice.dbo.SenderReceiver WITH(NOLOCK) where Phone = @Phone AND IdCountry = @IdCountry AND Estatus = 1)

				IF(@DateToken IS NULL)
				BEGIN
					UPDATE DeliveryBackOffice.dbo.SenderReceiver
					SET		Date_UpdateToken = GETDATE()
					WHERE	Phone = @Phone
						AND IdCountry = @IdCountry
						AND Estatus = 1;						
				END

				--Manejo de reinicio de columnas contadores de mensajes
				IF((SELECT Convert(Date,@DateToken)) <> (SELECT Convert(Date,GETDATE())))
				BEGIN
					UPDATE	DeliveryBackOffice.dbo.SenderReceiver
					SET		MessageCounter = 0,
							MailCounter = 0,
							Date_UpdateToken = GETDATE()
					WHERE	Phone = @Phone
						AND IdCountry = @IdCountry
						AND Estatus = 1;
				END

				DECLARE @MCounter INT;
				SET @MCounter = (SELECT TOP 1 MessageCounter FROM DeliveryBackOffice.dbo.SenderReceiver WITH(NOLOCK) WHERE Phone = @Phone AND IdCountry = @IdCountry AND Estatus = 1)

				IF(@NotificationEmail = 0)
				BEGIN
					IF(@MCounter < @MaxValue)
					BEGIN
						UPDATE	DeliveryBackOffice.dbo.SenderReceiver
						SET		MessageCounter = @MCounter +1
						WHERE	Phone = @Phone
							AND IdCountry = @IdCountry
							AND Estatus = 1;
					END
				END

				IF(@NotificationEmail = 1 )
				BEGIN
						DECLARE @ECounter INT;
						SET @ECounter = (SELECT TOP 1 MailCounter FROM DeliveryBackOffice.dbo.SenderReceiver WITH(NOLOCK) WHERE Phone = @Phone AND IdCountry = @IdCountry AND Estatus = 1)

						DECLARE @MMail Varchar(100)
						SET @MMail = (SELECT TOP 1 Email FROM DeliveryBackOffice.dbo.SenderReceiver WITH(NOLOCK) WHERE Phone = @Phone AND IdCountry = @IdCountry AND Estatus = 1)

						IF(@MMail = '')
						BEGIN
							SET @MMail = NULL
						END

						IF(@MMail IS NOT NULL)
						BEGIN
							UPDATE	DeliveryBackOffice.dbo.SenderReceiver
							SET		MailCounter = @ECounter +1
							WHERE	Phone = @Phone
								AND IdCountry =@IdCountry
								AND Estatus = 1;
						END
				END

				SELECT
						'200' 'StatusCode'
						,'Token obtenido correctamente.' 'Description' 
						,@LoginToken 'LoginToken'
						,@Email 'Email'
						,@MaxValue 'MaxValue'
						,MessageCounter
						,MailCounter
						,IdCountry
						,@StationId AS StationId
				FROM	SenderReceiver WITH(NOLOCK)
				WHERE	Phone = @Phone
					AND IdCountry = @IdCountry
					AND Estatus = 1;
			   
				IF((SELECT TOP 1 MessageCounter FROM DeliveryBackOffice.dbo.SenderReceiver WITH(NOLOCK) WHERE Phone = @Phone AND IdCountry =@IdCountry AND Estatus = 1) = @MaxValue)
				BEGIN
					UPDATE	SenderReceiver
					SET		MessageCounter = (SELECT TOP 1 MessageCounter FROM DeliveryBackOffice.dbo.SenderReceiver WITH(NOLOCK) WHERE Phone = @Phone AND IdCountry = @IdCountry AND Estatus = 1) +1
					WHERE	Phone = @Phone
						AND IdCountry = @IdCountry
						AND Estatus = 1;
				END

				IF((SELECT TOP 1 MailCounter FROM DeliveryBackOffice.dbo.SenderReceiver WITH(NOLOCK) WHERE Phone = @Phone AND IdCountry = @IdCountry AND Estatus = 1) = @MaxValue)
				BEGIN
					UPDATE	SenderReceiver
					SET		MailCounter = (SELECT TOP 1 MailCounter FROM DeliveryBackOffice.dbo.SenderReceiver WITH(NOLOCK) WHERE Phone = @Phone AND IdCountry = @IdCountry AND Estatus = 1) +1
					WHERE	Phone = @Phone
						AND IdCountry = @IdCountry
						AND Estatus = 1;
				END
			  
		END
		ELSE
		BEGIN

			ROLLBACK TRANSACTION

			SELECT
				'-1' 'StatusCode'
			   ,'Usuario no encontrado o se encuentra inactivo.' 'Description' 
			   ,'' 'LoginToken'
		END

	END TRY
	BEGIN CATCH

		ROLLBACK TRANSACTION

		SELECT
			'-1' 'StatusCode'
		   ,ERROR_MESSAGE() 'Description' 
		   ,'' 'LoginToken'

	END CATCH
END
-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2023-04-24>
-- Description:	<Genera o obtiene el token para login en Courier App>
-- =============================================
CREATE procedure [dbo].[GetCourierLoginToken]
	-- Add the parameters for the stored procedure here
    @Phone nvarchar(20),
	@NotificationEmail int,
	@IdCountry nvarchar(8)
as
begin
USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[GetCourierLoginToken]    Script Date: 17/06/2024 16:21:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2023-04-24>
-- Description:	<Genera o obtiene el token para login en Courier App>
-- =============================================
ALTER PROCEDURE [dbo].[GetCourierLoginToken]
    -- Add the parameters for the stored procedure here
    @Phone NVARCHAR(20)
  , @NotificationEmail INT
  , @IdCountry nvarchar(8)

AS
BEGIN
 	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set nocount on;
	--SET@IdCountry = 'GT';
    BEGIN TRANSACTION

	BEGIN TRY
		
		DECLARE @MaxValue INT;
		SET @MaxValue = (SELECT TOP 1 Value FROM ConfigParams WHERE Name = 'MaxNumMessagesAllowed')

		DECLARE @SenderReceiverId INT =
                ( 
					SELECT	TOP 1
							ID
					FROM	SenderReceiver
					WHERE	Phone LIKE '%' + @Phone + '%'
						AND ISNULL(IdCountry,'GT') = @IdCountry
						AND Estatus = 1
				); 

		DECLARE @Email AS NVARCHAR(50) =  
				( 
					SELECT	TOP 1
							Email
					FROM	SenderReceiver
					WHERE	Phone LIKE '%' + @Phone + '%'
							AND ISNULL(IdCountry,'GT') = @IdCountry
							AND Estatus = 1
				);

		IF @SenderReceiverId IS NOT NULL
		BEGIN 

			DECLARE @LoginToken NVARCHAR(6)

			SELECT 
					@LoginToken = LoginToken
			FROM	SenderReceiverLoginToken
			WHERE	SenderReceiverId = @SenderReceiverId
				AND RowStatus = 1
			
			IF @LoginToken IS NULL
			BEGIN
				SET @LoginToken = (SELECT ROUND(((999999 - 111111) * RAND() + 111111), 0))

				INSERT INTO SenderReceiverLoginToken (LoginToken, SenderReceiverId, RowStatus, TokenCreated, DateCreated)
				VALUES (@LoginToken, @SenderReceiverId, 1, 'SetCourierLoginToken', GETDATE())
			END

			COMMIT TRANSACTION

				DECLARE @DateToken DateTime;
				SET @DateToken = (SELECT Date_UpdateToken FROM SenderReceiver where Phone = @Phone AND ISNULL(IdCountry,'GT') = @IdCountry AND Estatus = 1)

				IF(@DateToken IS NULL)
				BEGIN
					UPDATE SenderReceiver
					SET		Date_UpdateToken = GETDATE()
					WHERE	Phone = @Phone
						AND ISNULL(IdCountry,'GT') = @IdCountry
						AND Estatus = 1;						
				END

				--Manejo de reinicio de columnas contadores de mensajes
				IF((SELECT Convert(Date,@DateToken)) <> (SELECT Convert(Date,GETDATE())))
				BEGIN
					UPDATE	SenderReceiver
					SET		MessageCounter = 0,
							MailCounter = 0,
							Date_UpdateToken = GETDATE()
					WHERE	Phone = @Phone
						AND ISNULL(IdCountry,'GT') = @IdCountry
						AND Estatus = 1;
				END

				DECLARE @MCounter INT;
				SET @MCounter = (SELECT TOP 1 MessageCounter FROM SenderReceiver WHERE Phone = @Phone AND ISNULL(IdCountry,'GT') = @IdCountry AND Estatus = 1)

				IF(@IdCountry = 'GT' AND @NotificationEmail = 0)
				BEGIN
					IF(@MCounter < @MaxValue)
					BEGIN
						UPDATE	SenderReceiver
						SET		MessageCounter = @MCounter +1
						WHERE	Phone = @Phone
							AND ISNULL(IdCountry,'GT') = @IdCountry
							AND Estatus = 1;
					END
				END

				IF(@NotificationEmail = 1 OR @IdCountry <> 'GT')
				BEGIN
						DECLARE @ECounter INT;
						SET @ECounter = (SELECT TOP 1 MailCounter FROM SenderReceiver WHERE Phone = @Phone AND ISNULL(IdCountry,'GT') = @IdCountry AND Estatus = 1)

						DECLARE @MMail Varchar(100)
						SET @MMail = (SELECT TOP 1 Email FROM SenderReceiver WHERE Phone = @Phone AND ISNULL(IdCountry,'GT') = @IdCountry AND Estatus = 1)

						IF(@MMail = '')
						BEGIN
							SET @MMail = NULL
						END

						IF(@MMail IS NOT NULL)
						BEGIN
							UPDATE	SenderReceiver
							SET		MailCounter = @ECounter +1
							WHERE	Phone = @Phone
								AND ISNULL(IdCountry,'GT') =@IdCountry
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
				FROM	SenderReceiver 
				WHERE	Phone = @Phone
					AND ISNULL(IdCountry,'GT') = @IdCountry
					AND Estatus = 1;
			   
				IF((SELECT TOP 1 MessageCounter FROM SenderReceiver WHERE Phone = @Phone AND ISNULL(IdCountry,'GT') =@IdCountry AND Estatus = 1) = @MaxValue)
				BEGIN
					UPDATE	SenderReceiver
					SET		MessageCounter = (SELECT TOP 1 MessageCounter FROM SenderReceiver WHERE Phone = @Phone AND ISNULL(IdCountry,'GT') = @IdCountry AND Estatus = 1) +1
					WHERE	Phone = @Phone
						AND ISNULL(IdCountry,'GT') = @IdCountry
						AND Estatus = 1;
				END

				IF((SELECT TOP 1 MailCounter FROM SenderReceiver WHERE Phone = @Phone AND ISNULL(IdCountry,'GT') = @IdCountry AND Estatus = 1) = @MaxValue)
				BEGIN
					UPDATE	SenderReceiver
					SET		MailCounter = (SELECT TOP 1 MailCounter FROM SenderReceiver WHERE Phone = @Phone AND ISNULL(IdCountry,'GT') = @IdCountry AND Estatus = 1) +1
					WHERE	Phone = @Phone
						AND ISNULL(IdCountry,'GT') = @IdCountry
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
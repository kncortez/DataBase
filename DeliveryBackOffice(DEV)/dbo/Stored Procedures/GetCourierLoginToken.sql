-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2023-04-24>
-- Description:	<Genera o obtiene el token para login en Courier App>
-- =============================================
CREATE procedure [dbo].[GetCourierLoginToken]
	-- Add the parameters for the stored procedure here
    @Phone nvarchar(20)
as
begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set nocount on;

    BEGIN TRANSACTION

	BEGIN TRY

		DECLARE @SenderReceiverId INT =
                ( SELECT TOP 1
				ID
			FROM SenderReceiver
			WHERE Phone LIKE '%' + @Phone + '%'
			AND Estatus = 1);

		DECLARE @Email AS NVARCHAR(50) =  ( SELECT TOP 1
				Email
			FROM SenderReceiver
			WHERE Phone LIKE '%' + @Phone + '%'
			AND Estatus = 1);


		IF @SenderReceiverId IS NOT NULL
		BEGIN 
			DECLARE @LoginToken NVARCHAR(6)

			SELECT 
				@LoginToken = LoginToken
			FROM SenderReceiverLoginToken
			WHERE SenderReceiverId = @SenderReceiverId
			AND RowStatus = 1
			
			IF @LoginToken IS NULL
			BEGIN
				SET @LoginToken = (SELECT
						ROUND(((999999 - 111111) * RAND() + 111111), 0))

				INSERT INTO SenderReceiverLoginToken (LoginToken, SenderReceiverId, RowStatus, TokenCreated, DateCreated)
					VALUES (@LoginToken, @SenderReceiverId, 1, 'SetCourierLoginToken', GETDATE())
			END

			COMMIT TRANSACTION

			SELECT
				'200' 'StatusCode'
			   ,'Token obtenido correctamente.' 'Description' 
			   ,@LoginToken 'LoginToken'
			   ,@Email 'Email'
			   
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
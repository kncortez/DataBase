-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <01/07/2022>
-- Description:	<Save or update Token Log>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_setTokenLog]
	@idToken AS NVARCHAR(75),
	@idUser AS INT,  -- This is from Table Internal User
	@idSystem AS INT,
	@idHub AS INT,
	@idModule AS INT,
	@idCountry AS NVARCHAR(2),
	@ip AS NVARCHAR(30)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @rusIdUser AS INT; -- Table RegisterUser.UsrIdUser

	BEGIN TRANSACTION
	BEGIN TRY
		-- Get RegisterUserId from InternalUser table
		SET @rusIdUser = (
			SELECT [IU].[RegisterUserID]
			FROM [dbo].[InternalUser] IU WITH(NOLOCK)
			WHERE [IU].[IdUser] = @idUser
		)
		-- Verify if TknIdToken record already exists in TokenLog table
		IF (SELECT COUNT(TL.TknIdToken) FROM TokenLog TL WHERE TL.TknIdToken = @idToken AND TL.TknIdUser = @rusIdUser) > 0
			-- If record already exists update rowStatus -> 1, TknTokenUpdated = @idToken, TokDateUpdated = SYSDATETIME
			BEGIN
			UPDATE [dbo].[TokenLog]
				SET
					[TknRowStatus] = 1,
					[TknTokenUpdated] = @idToken,
					[TknDateUpdated] = SYSDATETIME()
				WHERE 
					[TknIdToken] = @idToken AND
					[TknIdUser] = @rusIdUser;
			END
		ELSE
			-- If record doesn't exists add a new one
			BEGIN
			INSERT INTO [dbo].[TokenLog]
									([TknIdToken],
									 [TknIdUser],
									 [TknIdSystem],
									 [TknIdHub],
									 [TknIdModule],
									 [TknIdCountry],
									 [TknIP],
									 [TknRowStatus],
									 [TknTokenCreated],
									 [TknDateCreated])
			VALUES 
									(@idToken,
									 @rusIdUser,
									 @idSystem,
									 @idHub,
									 @idModule,
									 @idCountry,
									 @ip,
									 1, 
									 @idToken, 
									 SYSDATETIME())
			END
			-- Then update RowStatus -> 0 in all tokens for same user, system, hub, module and country
			BEGIN
			UPDATE [dbo].[TokenLog]
				SET 
					[TknRowStatus] = 0
				WHERE 
					[TknIdUser] = @rusIdUser AND
					[TknIdSystem] = @idSystem AND 
					[TknIdHub] = @idHub AND
					[TknIdModule] = @idModule AND
					[TknIdCountry] = @idCountry AND
					[TknIdToken] != @idToken
			END

			--IF(@@TRANCOUNT > 0)
				COMMIT TRANSACTION

			SELECT
				1 [spResult],
				'Success' 'Description'
	END TRY
	BEGIN CATCH
        SELECT 0 [spResult],
               ERROR_NUMBER() AS [ErrorNumber],
               ERROR_SEVERITY() AS [ErrorSeverity],
               ERROR_STATE() AS [ErrorState],
               ERROR_PROCEDURE() AS [ErrorProcedure],
               ERROR_LINE() AS [ErrorLine],
               ERROR_MESSAGE() AS [ErrorMessage];
		ROLLBACK TRANSACTION
	END CATCH
END
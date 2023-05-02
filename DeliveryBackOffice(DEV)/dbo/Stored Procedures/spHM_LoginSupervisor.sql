-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2023-03-28>
-- Description:	<Login de usuario supervisor para api movil>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_LoginSupervisor]
	@IdUser INT,
	@Username VARCHAR(50),
	@Password VARCHAR(200)
AS
BEGIN
	BEGIN  TRANSACTION
	BEGIN TRY
		DECLARE @StatusOrderId TINYINT
		DECLARE @Exists BIT = 0
		DECLARE @IsValidPassword BIT = 0
		DECLARE @IsValidRol BIT = 0

		SELECT
			@Exists = 1
		   ,@IsValidPassword =
			CASE
				WHEN u.USR_Password = @Password THEN 1
				ELSE 0
			END
		   ,@IsValidRol =
			CASE
				WHEN EXISTS (SELECT
								1
							FROM InternalUser iu
							INNER JOIN RegisterUser ru
								ON iu.RegisterUserID = ru.UsrIdUser
								AND ru.UsrRowStatus = 1
							INNER JOIN RolByUserBySystem rus
								ON ru.UsrIdUser = rus.RusIdUser
							INNER JOIN CatRol cr
								ON rus.RusIdRol = cr.RolIdRol
							INNER JOIN CatSystem cs
								ON rus.RusIdSystem = cs.SysIdSystem
							WHERE iu.IdUser = @IdUser
							AND iu.Username = @Username
							AND iu.RowStatus = 1
							AND rus.RusRowStatus = 1
							AND cr.RolName = 'Supervisor') THEN 1
				ELSE 0
			END
		FROM DenariusUser_Dev.dbo.LGN_User u
		WHERE u.USR_IdUser = @IdUser
		AND u.USR_Username = @Username

		IF (@Exists = 1)
		BEGIN

			IF (@IsValidPassword = 1)
			BEGIN

				IF (@IsValidRol = 1)
				BEGIN

					SELECT
						200 AS 'StatusCode'
					   ,'Credenciales correctas.' AS 'Description'

					COMMIT TRANSACTION
				END
				ELSE 
				BEGIN
					ROLLBACK TRANSACTION

					SELECT
						403 AS 'StatusCode'
					   ,'El usuario ingresado no posee los permisos necesarios.' AS 'Description'

				END
			END
			ELSE 
			BEGIN
				ROLLBACK TRANSACTION

				SELECT
					401 AS 'StatusCode'
				   ,'El usuario o la contraseña no coinciden, por favor revise la información.' AS 'Description'

			END
		END
		ELSE 
		BEGIN
			ROLLBACK TRANSACTION

			SELECT
				404 AS 'StatusCode'
			   ,'El usuario ingresado no ha sido encontrado.' AS 'Description'

		END
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		
		SELECT
			0 AS 'StatusCode'
		   ,ERROR_MESSAGE() AS 'Description'
	END CATCH
END
-- =============================================
-- Author:		<Andrés Ruíz>
-- Create date: <07-02-2023>
-- Description:	< Proceso para obtener información general de bloqueos de un usuario >
-- =============================================

--DECLARE
CREATE PROCEDURE [dbo].[spHW_SetNewUserPassword] 
	@UserRegisterUserId BIGINT,
	@ClientRegisterUserId BIGINT,
	@NewAccountPassword NVARCHAR(200),
	@Token NVARCHAR(600)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Roles permitidos para ejecutar proceso
	DECLARE @AcceptedRoles TABLE (
		RoleId INT
	)

	DECLARE @TelemarketingRole INT = ( SELECT TOP 1 CR.RolIdRol FROM [DeliveryBackOffice].[dbo].[CatRol] CR WITH(NOLOCK) WHERE CR.RolName = 'Ventas telemercadeo' )

	INSERT INTO @AcceptedRoles
		(RoleId)
	VALUES
		(@TelemarketingRole)

	-- Indicativo si actualizo correctamente la contraseña del usuario
	DECLARE @UpdatedPassword TABLE (
		DataUpdated BIGINT
	);

	-- Roles del usuario solicitando ejecutar el proceso
	DECLARE @UserRoles TABLE (
		RoleId INT
	);

	-- Obtener los roles del usuario solicitando ejecutar el proceso
	INSERT INTO @UserRoles
		(RoleId)
	SELECT 
		RBUBS.RusIdRol 
	FROM 
		[DeliveryBackOffice].[dbo].[RolByUserBySystem] RBUBS WITH(NOLOCK)
	WHERE
		RBUBS.RusIdUser = @UserRegisterUserId
		AND
		RBUBS.RusRowStatus = 1;

	BEGIN TRANSACTION
	BEGIN TRY

		-- Validar que usuario solicitando cambio tenga permisos
		IF(
			EXISTS
				(
					SELECT 
						TOP 1
							1
					FROM
						@AcceptedRoles AR
						INNER JOIN
							@UserRoles UR
							ON
								AR.RoleId = UR.RoleId
				)
		)
		BEGIN

			-- Validar que cliente contenga indicativo de cambio de contraseña activo
			IF
			(
				(
					SELECT
						TOP 1
							RU.ChangePassword
					FROM
						[DeliveryBackOffice].[dbo].[RegisterUser] RU WITH(NOLOCK)
					WHERE
						RU.UsrIdUser = @ClientRegisterUserId
				)
				= 1
			)
			BEGIN

				UPDATE
					[DeliveryBackOffice].[dbo].[RegisterUser]
				SET
					UsrLastPassword = @NewAccountPassword,
					UsrPasswordExpiration = DATEADD(DAY, 1, GETDATE()),
					UsrDateUpdated = GETDATE(),
					UsrTokenUpdated = @Token
				OUTPUT inserted.UsrIdUser INTO @UpdatedPassword(DataUpdated)
				WHERE
					UsrIdUser = @ClientRegisterUserId

				IF ( EXISTS (SELECT TOP 1 1 FROM @UpdatedPassword) )
				BEGIN
	
					COMMIT TRANSACTION;

					SELECT
						200 'resultCode',
						'Contraseña reactivada exitosamente' 'resultMessage'

				END
				ELSE
				BEGIN
	
					ROLLBACK TRANSACTION;

					SELECT
						204 'resultCode',
						'Contraseña no pudo ser actualizada' 'resultMessage'

				END

			END
			ELSE
			BEGIN
	
				ROLLBACK TRANSACTION;

				SELECT
					204 'resultCode',
					'Proceso no realizado ya que usuario no tiene cambio de contraseña' 'resultMessage'

			END

		END
		ELSE
		BEGIN
	
			ROLLBACK TRANSACTION;

			SELECT
				204 'resultCode',
				'Proceso no realizaro por falta de permisos' 'resultMessage'

		END
	END TRY
	BEGIN CATCH

		ROLLBACK TRANSACTION;

		SELECT
			500 'resultCode',
			ERROR_MESSAGE() 'resultMessage'

	END CATCH

END
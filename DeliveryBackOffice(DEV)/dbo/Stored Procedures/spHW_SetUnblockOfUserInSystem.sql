-- =============================================
-- Author:		<Andrés Ruíz>
-- Create date: <08-02-2023>
-- Description:	< Proceso para desbloquear usuario de sistema >
-- =============================================

--DECLARE
CREATE PROCEDURE [dbo].[spHW_SetUnblockOfUserInSystem] 
	@UserRegisterUserId BIGINT,
	@TargetRegisterUserId BIGINT,
	@TargetSystemName NVARCHAR(200) = 'Hermes Web',
	@Token NVARCHAR(600)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @TargetSystem INT = ( SELECT TOP 1 CS.SysIdSystem FROM [DeliveryBackOffice].[dbo].[CatSystem] CS WITH(NOLOCK) WHERE CS.SysNameSystem = @TargetSystemName )

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
	DECLARE @UpdatedData TABLE (
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

			UPDATE
				[DeliveryBackOffice].[dbo].[UserSystemRestriction]
			SET
				UstStatus = 'ACTIVE',
				UstRetries = 0
			OUTPUT inserted.UstIdRestriction INTO @UpdatedData (DataUpdated)
			WHERE
				UstIdUser = @TargetRegisterUserId
				AND
				UstIdSystem = @TargetSystem

			IF(EXISTS(SELECT TOP 1 1 FROM @UpdatedData))
			BEGIN

				COMMIT TRANSACTION;

				SELECT
					200 'resultCode',
					'Cuenta desbloqueada exitosamente' 'resultMessage'

			END
			ELSE
			BEGIN
	
				ROLLBACK TRANSACTION;

				SELECT
					204 'resultCode',
					'No se pudo desbloquear la cuenta, revise la información' 'resultMessage'

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
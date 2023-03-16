-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2023-02-17>
-- Description:	<Marcar guías para inspección>
-- =============================================
CREATE PROCEDURE [dbo].[SetGuideAbandoned]
	@IdUser INT,
	@Username VARCHAR(50),
	@Password VARCHAR(200),
	@NameSystem VARCHAR(100),
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT,
	@Token NVARCHAR(50)
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
				WHEN ru.UsrLastPassword = @Password THEN 1
				ELSE 0
			END
		   ,@IsValidRol =
			CASE
				WHEN EXISTS (SELECT
							1
						FROM RolByUserBySystem rus
						INNER JOIN CatRol cr
							ON rus.RusIdRol = cr.RolIdRol
						INNER JOIN CatSystem cs
							ON rus.RusIdSystem = cs.SysIdSystem
						WHERE ru.UsrIdUser = rus.RusIdUser
						AND rus.RusRowStatus = 1
						AND cr.RolName = 'Supervisor'
						AND cs.SysNameSystem = @NameSystem) THEN 1
				ELSE 0
			END
		FROM InternalUser iu
		INNER JOIN RegisterUser ru
			ON iu.RegisterUserID = ru.UsrIdUser
				AND ru.UsrRowStatus = 1
		WHERE iu.IdUser = @IdUser
		AND iu.Username = @Username
		AND iu.RowStatus = 1

		IF (@Exists = 1)
		BEGIN

			IF (@IsValidPassword = 1)
			BEGIN

				IF (@IsValidRol = 1)
				BEGIN

					SET @StatusOrderId = (SELECT StatusOrderId FROM StatusOrder WHERE OrderDescription = 'Paquete abandonado')

					-- registrar checkpoint histórico de paquete abandonado
					INSERT INTO [dbo].[DeliveryOrderDetail]
					   ([Guide_Serie]
					   ,[Guide_Number]
					   ,[StatusOrderId]
					   ,[UserCreated]
					   ,[DateCreated]
					   ,[DateCreatedInSystem]
					   ,[Observations]
					   ,[Temperature_Celsius])
					 VALUES
						   (@GuideSerie
						   ,@GuideNumber
						   ,@StatusOrderId
						   ,@Token
						   ,GETDATE()
						   ,GETDATE()
						   ,NULL
						   ,NULL)

					-- actualizar estado de la guía
					UPDATE DeliveryOrder
					SET StatusOrderId = @StatusOrderId
					WHERE Guide_Serie = @GuideSerie
					AND Guide_Number = @GuideNumber


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
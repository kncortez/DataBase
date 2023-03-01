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

		IF EXISTS (SELECT
				1
			FROM InternalUser iu
			INNER JOIN RegisterUser ru
				ON iu.RegisterUserID = ru.UsrIdUser
				AND ru.UsrRowStatus = 1
			INNER JOIN RolByUserBySystem rus
				ON ru.UsrIdUser = rus.RusIdUser
				AND rus.RusRowStatus = 1
			INNER JOIN CatRol cr
				ON rus.RusIdRol = cr.RolIdRol
			INNER JOIN CatSystem cs
				ON rus.RusIdSystem = cs.SysIdSystem
			WHERE iu.IdUser = @IdUser
			AND iu.Username = @Username
			AND ru.UsrLastPassword = @Password
			AND cr.RolName = 'Supervisor'
			AND cs.SysNameSystem = @NameSystem
			AND iu.RowStatus = 1)
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
				404 AS 'StatusCode'
			   ,'El usuario no ha sido encontrado.' AS 'Description'

		END
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		
		SELECT
			0 AS 'StatusCode'
		   ,ERROR_MESSAGE() AS 'Description'
	END CATCH
END
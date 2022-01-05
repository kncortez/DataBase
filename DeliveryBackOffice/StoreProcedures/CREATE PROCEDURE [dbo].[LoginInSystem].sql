USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[LoginInSystem]    Script Date: 5/01/2022 14:47:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-01-04>
-- Description:	<Iniciar sesión en el sistema>
-- =============================================
CREATE PROCEDURE [dbo].[LoginInSystem] @IdUser INT,
@Username VARCHAR(50),
@Password VARCHAR(50),
@IdCountry VARCHAR(2),
@IdSystem INT,
@IP NVARCHAR(30),
@Referrer VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @RegisterUserID INT = -1
	DECLARE @UstAccessRetries INT
	DECLARE @UstRetries INT
	DECLARE @UstStatus VARCHAR(10)
	DECLARE @UsrLastPassword VARCHAR(200)
	DECLARE @UstIdRestriction BIGINT
	DECLARE @Token NVARCHAR(75)
	DECLARE @VpCodeOfReference INT
	DECLARE @StationId INT
	DECLARE @StationType INT
	DECLARE @StationName VARCHAR(200)
	DECLARE @StationDetail VARCHAR(200)

	SELECT
		@RegisterUserID = ust.UstIdUser
	   ,@UstAccessRetries = ust.UstAccessRetries
	   ,@UstRetries = ust.UstRetries
	   ,@UstStatus = ust.UstStatus
	   ,@UsrLastPassword = ru.UsrLastPassword
	   ,@UstIdRestriction = ust.UstIdRestriction
	FROM InternalUser iu
	INNER JOIN RegisterUser ru
		ON iu.RegisterUserID = ru.UsrIdUser
			AND ru.UsrRowStatus = 1
	INNER JOIN RolByUserBySystem rus
		ON ru.UsrIdUser = rus.RusIdUser
			AND rus.RusIdSystem = @IdSystem
			AND rus.RusRowStatus = 1
	INNER JOIN UserSystemRestriction ust
		ON ust.UstIdUser = rus.RusIdUser
			AND ust.UstIdSystem = rus.RusIdSystem
			AND ust.UstRowStatus = 1
	WHERE iu.IdUser = @IdUser
	AND iu.Username = @Username
	AND iu.RowStatus = 1


	IF @RegisterUserID <> -1
	BEGIN
		IF @UstStatus = 'ACTIVE'
		BEGIN
			IF @UsrLastPassword = @Password
			BEGIN
				--Contraseña correcta, se reinicia contador
				UPDATE UserSystemRestriction
				SET UstRetries = 0
				   ,UstOperationDate = GETDATE()
				WHERE UstIdRestriction = @UstIdRestriction

				--Tabla 0 
				SELECT
					200 AS 'StatusCode'
				   ,'Ingreso exitoso' AS 'Description'

				--Crear y guardar token
				SET @Token = (SELECT
						CONVERT(VARCHAR(32), HASHBYTES('MD5', CONCAT(@Username, @Password, SYSDATETIME())), 2))


				INSERT INTO [dbo].[TokenLog] ([TknIdToken]
				, [TknIdUser]
				, [TknIdSystem]
				, [TknIdHub]
				, [TknIdModule]
				, [TknIdCountry]
				, [TknIP]
				, [TknRowStatus]
				, [TknTokenCreated]
				, [TknDateCreated]
				, [TknTokenUpdated]
				, [TknDateUpdated]
				, [TknReferrer])
					VALUES (@Token, @RegisterUserID, @IdSystem, NULL, NULL, @IdCountry, @IP, 1, @Token, GETDATE(), NULL, NULL, @Referrer)

				--Tabla 1 Token
				IF @@rowcount > 0
					SELECT
						@Token Token
				ELSE
					SELECT
						NULL Token

				--Tabla 2 Accesos a los Módulos
				SELECT
					RUS.[RusIdRol]
				   ,RUS.[RusIdSystem]
				   ,RUS.[RusIdUser]
				   ,INU.IdEmployee
				   ,INU.IdUser
				   ,INU.Username
				   ,RMS.RmsIdModule
				   ,MDL.ModIdModuleParent
				   ,MDL.ModName
				   ,MDL.ModPath
				   ,MDL.ModOrder
				   ,MDL.ModMetadata
				FROM [DeliveryBackOffice].[dbo].InternalUser INU
				JOIN [DeliveryBackOffice].[dbo].[RolByUserBySystem] RUS
					ON INU.RegisterUserID = RUS.RusIdUser
						AND INU.RowStatus = 'TRUE'
				JOIN [DeliveryBackOffice].[dbo].RolByModuleBySystem RMS
					ON RMS.RmsIdRol = RUS.RusIdRol
						AND RUS.RusIdSystem = RMS.RmsIdSystem
						AND RUS.RusRowStatus = 'TRUE'
				JOIN CatModule MDL
					ON RMS.RmsIdModule = MDL.ModIdModule
						AND MDL.ModRowStatus = 'TRUE'
				WHERE INU.IdUser = @IdUser
				AND INU.Username = @Username
				AND RUS.RusIdSystem = @IdSystem

				--Tabla 3 Roles
				SELECT
					rus.RusIdUser
				   ,rus.RusIdRol
				   ,rus.StationId
				   ,cr.RolName
				   ,cr.RolDescription
				   ,cr.RolAdminBrothers
				   ,cr.RolAdminClient
				   ,cr.RolAdminInternal
				FROM dbo.RolByUserBySystem rus
				INNER JOIN InternalUser IU
					ON rus.RusIdUser = IU.RegisterUserID
						AND IU.RowStatus = 1
				INNER JOIN CatRol cr
					ON rus.RusIdRol = cr.RolIdRol
						AND cr.RolRowStatus = 1
				WHERE rus.RusRowStatus = 1
				AND IU.IdUser = @IdUser

				--Tabla 4 Advisor
				SELECT
					IU.IdUser
				   ,ius.SaleAdvisorID
				FROM InternalUser IU
				INNER JOIN dbo.SaleAdvisorbyUser ius
					ON ius.UserId = IU.IdUser
				WHERE ius.RowStatus = 1
				AND IU.IdUser = @IdUser

				--Tabla 5 CodeOfReference y el StationId
				SELECT
					@StationId = cs.IdStation
				   ,@VpCodeOfReference = cs.CodeOfReference
				   ,@StationType = cs.StationType
				   ,@StationName = IIF(cs.StationType = 1, 'HUB ', '') + cs.StationName
				   ,@StationDetail = IIF(cs.StationType = 1,
					--CONVERT(VARCHAR(50),HBL.IdHubLogistic)
					'', CONVERT(VARCHAR(50), CONVERT(VARCHAR(50), VPC.CodeOfReference) + ' ' + VPC.Address))
				FROM DeliveryBackOffice.dbo.InternalUser iu
				JOIN DeliveryBackOffice.dbo.RegisterUser ru
					ON iu.RegisterUserID = ru.UsrIdUser
						AND ru.UsrRowStatus = 1
				JOIN DeliveryBackOffice.dbo.RolByUserBySystem rus
					ON ru.UsrIdUser = rus.RusIdUser
						AND rus.RusRowStatus = 1
				JOIN DeliveryBackOffice.dbo.CatStation cs
					ON rus.StationId = cs.IdStation
						AND cs.RowStatus = 1
				LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC
					ON VPC.CodeOfReference = cs.CodeOfReference
						AND cs.StationType = 2
				WHERE iu.IdUser = @IdUser
				AND iu.Username = @Username
				AND rus.RusIdSystem = @IdSystem
				AND iu.RowStatus = 1

				IF @StationId IS NULL
					SELECT
						@StationId = -1
					   ,@VpCodeOfReference = 999
				ELSE
				IF @StationType = 1
					SET @VpCodeOfReference = 999

				SELECT
					@VpCodeOfReference VpCodeOfReference
				   ,@StationId StationId
				   ,@StationName StationName
				   ,@StationDetail StationDetail

			END
			ELSE
			--Contraseña incorrecta, se aumenta contador
			BEGIN
				SET @UstRetries = @UstRetries + 1

				IF @UstRetries >= @UstAccessRetries
					SET @UstStatus = 'BLOCKED'

				UPDATE UserSystemRestriction
				SET UstRetries = @UstRetries
				   ,UstStatus = @UstStatus
				   ,UstOperationDate = GETDATE()
				WHERE UstIdRestriction = @UstIdRestriction

				SELECT
					400 AS 'StatusCode'
				   ,CONCAT('La contraseña es incorrecta, intento ', @UstRetries, ' de ', @UstAccessRetries) AS 'Description'
			END
		END
		ELSE
			--Usuario bloqueado
			SELECT
				401 AS 'StatusCode'
			   ,'El usuario se encuentra bloqueado' AS 'Description'
	END
	ELSE
		--Usuario no encontrado
		SELECT
			404 AS 'StatusCode'
		   ,'El usuario no ha sido encontrado' AS 'Description'
END

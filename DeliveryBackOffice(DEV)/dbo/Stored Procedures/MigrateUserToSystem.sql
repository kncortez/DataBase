
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-09-20>
-- Description:	< Migrar información de usuarios internos de Denarius a tablas de Forza Delivery >
-- =============================================

CREATE PROCEDURE [dbo].[MigrateUserToSystem]
    @UserCode NVARCHAR(50),
    @UserName NVARCHAR(50),
    @SystemId INT,
    @Role NVARCHAR(50),
	@StationId INT,
    @Token NVARCHAR(50) = ''
    
AS
BEGIN

	-- Variables de control de flujo
	DECLARE @UserExistsDENARIUS AS TABLE (
		UserCode BIGINT,
		UserName NVARCHAR(50),
		PersonFirstNames NVARCHAR(100),
		PersonLastNames NVARCHAR(100),
		PersonGender NVARCHAR(2),
		PersonBirthDay DATE,
		PersonIdentification NVARCHAR(50),
		PersonNationality NVARCHAR(100),
		PersonPhone NVARCHAR(15),
		UserPassword NVARCHAR(50),
		UserEmail NVARCHAR(50)
	);
	DECLARE @PersonExistsDELIVERY AS TABLE (
		PersonId BIGINT
	);
	DECLARE @RegisterUserExistsDELIVERY AS TABLE (
		RegisterUserId BIGINT
	);
	DECLARE @InternalUserExistsDELIVERY AS TABLE (
		InternalUserId BIGINT
	);
	DECLARE @UserRestrictionExistsDELIVERY AS TABLE (
		restrictionUserId BIGINT
	);
	DECLARE @RolByUserExistsDELIVERY AS TABLE (
		RolByUserId BIGINT
	);

	BEGIN TRANSACTION
	BEGIN TRY

		IF( NOT EXISTS (SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatSystem] CS WITH(NOLOCK) WHERE CS.SysIdSystem = @SystemId AND CS.SysRowStatus = 1) )
		BEGIN
			;THROW 50005, N'Sistema no existe en el catálogo, revise el sistema.', 1;
		END
		IF( NOT EXISTS (SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatRol] CR WITH(NOLOCK) WHERE CR.RolName = @Role COLLATE Latin1_General_CI_AI AND CR.RolRowStatus = 1) )
		BEGIN
			;THROW 50005, N'Rol no existe en el catálogo, revise el sistema.', 1;
		END
		IF( NOT EXISTS (SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatStation] CS WITH(NOLOCK) WHERE CS.IdStation = @StationId AND CS.RowStatus = 1) )
		BEGIN
			;THROW 50005, N'Estación no existe en el catálogo, revise el sistema.', 1;
		END
		
		DECLARE @RoleAsId INT = (SELECT TOP 1 CR.RolIdRol FROM [DeliveryBackOffice].[dbo].[CatRol] CR WITH(NOLOCK) WHERE CR.RolName = @Role COLLATE Latin1_General_CI_AI AND CR.RolRowStatus = 1)

		PRINT 'OBTENER DATOS DE PERSONA DE DENARIUS'
		INSERT INTO @UserExistsDENARIUS
			(
				UserCode
				, UserName
				, PersonFirstNames
				, PersonLastNames
				, PersonGender
				, PersonBirthDay
				, PersonIdentification
				, PersonNationality
				, PersonPhone
				, UserPassword
				, UserEmail
			)
		SELECT
			TOP 1
				TRY_CONVERT(BIGINT,LGTIE.CodeEmployee)
				, LGNU.USR_Username
				, LTRIM(RTRIM(CONCAT(LGTIE.FirstName,' ', LGTIE.SecondName)))
				, LTRIM(RTRIM(CONCAT(LGTIE.LastName1,' ', LGTIE.LastName2)))
				, LGTIE.Sex
				, LGTIE.DateBrith
				, IIF(LTRIM(RTRIM(ISNULL(LGTIE.DPI,''))) != '', LGTIE.DPI, IIF(LTRIM(RTRIM(ISNULL(LGTIE.Cedula,''))) != '', LGTIE.Cedula, LGTIE.PassportNumber))
				, LGTIE.IdCountry
				, IIF(LTRIM(RTRIM(ISNULL(LGTIE.CellPhone, ''))) != '', LTRIM(RTRIM(ISNULL(LGTIE.CellPhone, ''))), NULL)
				, LGNU.USR_Password
				, CONCAT(LGNU.USR_Username, '@forzadelivery.com')
		FROM
			[DenariusUser_Dev].[dbo].[LGN_User] LGNU WITH(NOLOCK)
			INNER JOIN
				[DenariusDesktop_Dev].[dbo].[LGT_INF_Employee] LGTIE WITH(NOLOCK)
				ON
					LGNU.USR_IdEmployee = LGTIE.IdEmployee
		WHERE
			LGTIE.CodeEmployee = @UserCode
			AND
			LGNU.USR_Username = @UserName

		-- Verificar si existe usuario
		IF( NOT EXISTS(SELECT TOP 1 1 FROM @UserExistsDENARIUS) )
		BEGIN
	
			PRINT 'NO SE ENCONTRO DATOS DE PERSONA EN DENARIUS'
			;THROW 50005, N'Usuario no existe con información de denarius, no hay datos para migrar.', 1;
		
		END
		ELSE
		BEGIN

			PRINT 'PROCESO DE MIGRACIÓN DE USUARIO A TABLAS FORZA DELIVERY'
			-- Corregir posibles escenarios incorrectos de pais
			UPDATE
				@UserExistsDENARIUS
			SET
				PersonNationality = IIF(
											PersonNationality = 'GX',
											'GT',
											PersonNationality
										)
									
			PRINT 'REVISAR SI PERSONA YA EXISTE EN TABLAS FORZA DELIVERY'
			PRINT 'VERIFICA SI EL DPI YA EXISTE'
			-- Revisar si existe persona dentro del sistema
			INSERT INTO @PersonExistsDELIVERY
				(PersonId)
			SELECT
				TOP 1
					PRSN.PerIdPerson
			FROM
				[DeliveryBackOffice].[dbo].[Person] PRSN WITH(NOLOCK)
				INNER JOIN
					@UserExistsDENARIUS UED
					ON
						PRSN.PerIdentification = UED.PersonIdentification

			-- Si no existe, tratar de generar persona previo a dar error
			IF ( NOT EXISTS (SELECT TOP 1 1 FROM @PersonExistsDELIVERY) )
			BEGIN

				PRINT 'PERSONA NO EXISTE Y SE PROCEDE A GENERAR REGISTRO NUEVO'
				INSERT INTO [DeliveryBackOffice].[dbo].[Person]
					(PerFirstName, PerLastName, PerGender, PerBirthdate, PerIdentification, PerNationality, PerRowStatus, PerTokenCreated, PerDateCreated)
				OUTPUT inserted.PerIdPerson INTO @PersonExistsDELIVERY(PersonId)
				SELECT
					TOP 1
						UED.PersonFirstNames, UED.PersonLastNames, UED.PersonGender, UED.PersonBirthDay, UED.PersonIdentification, UED.PersonNationality, 1, @Token, GETDATE()
				FROM
					@UserExistsDENARIUS UED

			END

			-- Verificar si existe persona
			IF ( NOT EXISTS (SELECT TOP 1 1 FROM @PersonExistsDELIVERY) )
			BEGIN
	
				PRINT 'NO SE PUDO RECUPERAR INFORMACIÓN DE PERSONA'
				;THROW 50005, N'No se pudo ingresar información de persona en el sistema, verifique la información ingresada.', 1;
		
			END
			ELSE 
			BEGIN 
		
				PRINT 'REGISTRAR USUARIO EN TABLAS FORZA DELIVERY [RegisterUser]'
				-- Revisar si existe usuario dentro del sistema
				INSERT INTO @RegisterUserExistsDELIVERY
					(RegisterUserId)
				SELECT
					TOP 1
						RU.UsrIdUser
				FROM
					[DeliveryBackOffice].[dbo].[RegisterUser] RU WITH(NOLOCK)
					INNER JOIN
						@PersonExistsDELIVERY PED
						ON
							RU.UsrIdPerson = PED.PersonId
				WHERE
					RU.UsrRowStatus = 1
				
				-- Si no existe, tratar de generar usuario previo a dar error
				IF ( NOT EXISTS (SELECT TOP 1 1 FROM @RegisterUserExistsDELIVERY) )
				BEGIN
			
					PRINT 'USUARIO NO EXISTE Y SE PROCEDE A GENERAR UNO [RegisterUser]'
					INSERT INTO [DeliveryBackOffice].[dbo].[RegisterUser]
						(UsrIdPerson, UsrNickName, UsrLastPassword, UsrEmail, Phone, UsrPasswordExpiration, UsrDeviceType, UsrRowStatus, UsrTokenCreated, UsrDateCreated)
					OUTPUT inserted.UsrIdUser INTO @RegisterUserExistsDELIVERY(RegisterUserId)
					SELECT
						TOP 1
							PED.PersonId, UED.UserName, UED.UserPassword, UED.UserEmail, UED.PersonPhone, DATEADD(DAY, 90, CAST(GETDATE() AS DATE)), 'WEB', 1, @Token, GETDATE()
					FROM
						@PersonExistsDELIVERY PED
						CROSS JOIN
							@UserExistsDENARIUS UED

				END
			
				-- Verificar si existe usuario registrado
				IF ( NOT EXISTS (SELECT TOP 1 1 FROM @RegisterUserExistsDELIVERY))
				BEGIN
			
					PRINT 'NO SE PUDO RECUPERAR INFORMACIÓN DE USUARIO [RegisterUser]'
					;THROW 50005, 'No se pudo ingresar información de persona en el sistema, verifique la información ingresada.', 1;

				END
				ELSE
				BEGIN
			
					PRINT 'REGISTRAR USUARIO COMO USUARIO INTERNO [InternalUser]'
					-- Revisar si existe usuario dentro del sistema
					INSERT INTO @InternalUserExistsDELIVERY
						(InternalUserId)
					SELECT
						TOP 1
							IU.IdUser
					FROM
						[DeliveryBackOffice].[dbo].[InternalUser] IU WITH(NOLOCK)
						INNER JOIN
							@UserExistsDENARIUS UED
							ON
								IU.IdUser = UED.UserCode
					UNION
					SELECT
						TOP 1
							IU.IdUser
					FROM
						[DeliveryBackOffice].[dbo].[InternalUser] IU WITH(NOLOCK)
						INNER JOIN
							@RegisterUserExistsDELIVERY RUED
							ON
								RUED.RegisterUserId = IU.RegisterUserID
						INNER JOIN
							@UserExistsDENARIUS UED
							ON
								IU.Username = UED.UserName
							
					-- Si no existe, tratar de generar usuario interno previo a dar error
					IF ( NOT EXISTS (SELECT TOP 1 1 FROM @InternalUserExistsDELIVERY) )
					BEGIN
				
						PRINT 'USUARIO NO EXISTE Y SE PROCEDE A GENERAR UNO [InternalUser]'
						INSERT INTO [DeliveryBackOffice].[dbo].[InternalUser]
							(IdUser, Username, RegisterUserID, RowStatus, TokenCreated, DateCreated)
						OUTPUT inserted.IdUser INTO @InternalUserExistsDELIVERY(InternalUserId)
						SELECT
							TOP 1
								UED.UserCode, UED.UserName, RUED.RegisterUserId, 1, @Token, GETDATE()
						FROM
							@RegisterUserExistsDELIVERY RUED
							CROSS JOIN
								@UserExistsDENARIUS UED

					END
				
				
					IF ( NOT EXISTS (SELECT TOP 1 1 FROM @InternalUserExistsDELIVERY) )
					BEGIN
			
						PRINT 'NO SE PUDO RECUPERAR INFORMACIÓN DE USUARIO [InternalUser]'
						;THROW 50005, 'No se pudo ingresar información de usuaro interno en el sistema, verifique la información ingresada.', 1;

					END
					ELSE
					BEGIN

						UPDATE
							IU
						SET
							RegisterUserID = RUED.RegisterUserId
						FROM
							[DeliveryBackOffice].[dbo].[InternalUser] IU WITH(NOLOCK)
							INNER JOIN
								@InternalUserExistsDELIVERY IUED
								ON
									IU.IdUser = IUED.InternalUserId
							CROSS JOIN
								@RegisterUserExistsDELIVERY RUED

						PRINT 'REGISTRAR USUARIO BAJO ROL ESPECIFICADO EN SISTEMA INDICADO [RolByUserBySystem]'
						INSERT INTO @RolByUserExistsDELIVERY
							(RolByUserId)
						SELECT
							TOP 1
								RBUBA.RusIdUser
						FROM
							[DeliveryBackOffice].[dbo].[RolByUserBySystem] RBUBA WITH(NOLOCK)
							INNER JOIN
								@RegisterUserExistsDELIVERY RUED
								ON
									RBUBA.RusIdUser = RUED.RegisterUserId
						WHERE
							RBUBA.RusIdSystem = @SystemId
							AND
							RBUBA.RusIdRol = @RoleAsId
							AND
							RBUBA.RusRowStatus = 1

						IF( NOT EXISTS (SELECT TOP 1 1 FROM @RolByUserExistsDELIVERY))
						BEGIN
					
							PRINT 'REGISTRO NO EXISTE Y SE PROCEDE A APLICAR CONFIGURACIÓN [RolByUserBySystem]'
							INSERT INTO [DeliveryBackOffice].[dbo].[RolByUserBySystem]
								(RusIdRol, RusIdSystem, RusIdUser, StationId, RusRowStatus, RusTokenCreated, RusDateCreated)
							OUTPUT inserted.RusIdUser INTO @RolByUserExistsDELIVERY(RolByUserId)
							SELECT
								TOP 1
									@RoleAsId, @SystemId, RUED.RegisterUserId, @StationId, 1, @Token, GETDATE()
							FROM
								@RegisterUserExistsDELIVERY RUED

						END
					
						IF( NOT EXISTS (SELECT TOP 1 1 FROM @RolByUserExistsDELIVERY))
						BEGIN
					
							PRINT 'NO SE PUDO REGISTRAR USUARIO BAJO ROL ESPECIFICADO EN SISTEMA [RolByUserBySystem]'
							;THROW 50005, N'No se pudo registrar al usuario con el rol especificado.', 1;

						END
						ELSE
						BEGIN
					
							PRINT 'REGISTRAR RESTRICCIONES DE INGRESO DE USUARIO [UserSystemRestriction]'
							INSERT INTO @UserRestrictionExistsDELIVERY
								(restrictionUserId)
							SELECT
								TOP 1
									USR.UstIdRestriction
							FROM
								[DeliveryBackOffice].[dbo].[UserSystemRestriction] USR WITH(NOLOCK)
								INNER JOIN
									@RegisterUserExistsDELIVERY RUED
									ON
										USR.UstIdUser = RUED.RegisterUserId
							WHERE
								USR.UstIdSystem = @SystemId
								AND
								USR.UstRowStatus = 1
							
							IF( NOT EXISTS (SELECT TOP 1 1 FROM @UserRestrictionExistsDELIVERY))
							BEGIN
						
								PRINT 'REGISTRO NO EXISTE Y SE PROCEDE A APLICAR CONFIGURACIÓN [UserSystemRestriction]'
								INSERT INTO [DeliveryBackOffice].[dbo].[UserSystemRestriction]
									(UstIdUser, UstIdSystem, UstAccessRetries, UstRetries, UstOperationDate, UstStatus, UstRowStatus, UstTokenCreated, UstDateCreated)
								OUTPUT inserted.UstIdRestriction INTO @UserRestrictionExistsDELIVERY(restrictionUserId)
								SELECT
									TOP 1
										RUED.RegisterUserId, @SystemId, 10, 0, GETDATE(), 'ACTIVE', 1, @Token, GETDATE()
								FROM
									@RegisterUserExistsDELIVERY RUED

							END
						
							IF( NOT EXISTS (SELECT TOP 1 1 FROM @UserRestrictionExistsDELIVERY))
							BEGIN
							
								PRINT 'NO SE PUDO REGISTRAR LAS RESTRICCIONES DEL USUARIO BAJO EN SISTEMA [UserSystemRestriction]'
								;THROW 50005, N'No se pudo asignar las restricciones del usuario.', 1;

							END
							ELSE
							BEGIN
							
								PRINT 'COMMIT';
								SELECT
									CAST(1 AS BIT) 'blnResult'
									,'Usuario registrado exitosamente con datos de denarius' 'resultMessage'
									,(SELECT TOP 1 RUED.RegisterUserId FROM @RegisterUserExistsDELIVERY RUED) 'resultNumber'
									,0 'resultSeverity'
									,0 'resultState'
									,ERROR_PROCEDURE() 'resultProcedure'
									,0 'resultLine';

								COMMIT TRANSACTION;

							END

						END
					END

				END
			END

		END

	END TRY
	BEGIN CATCH

		PRINT 'ROLLBACK';
		ROLLBACK TRANSACTION;

		SELECT
			CAST(0 AS BIT) 'blnResult'
			,ERROR_MESSAGE() 'resultMessage'
			,ERROR_NUMBER() 'resultNumber'
			,ERROR_SEVERITY() 'resultSeverity'
			,ERROR_STATE() 'resultState'
			,ERROR_PROCEDURE() 'resultProcedure'
			,ERROR_LINE() 'resultLine';


	END CATCH
END;
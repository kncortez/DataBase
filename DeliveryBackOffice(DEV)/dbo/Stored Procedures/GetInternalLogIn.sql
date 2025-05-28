
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-09-22>
-- Last Update date: <2022-09-22>
-- Description:	< Login de portal web para usuarios internos >
-- =============================================
-- Author:	 <Brandon, Pedroza>
-- Modified: <2024-08-05>
-- Description:	<Se devuelve el id del pais de usuario, en apartado Profile>
-- =============================================
-- Author:	 <Brandon, Pedroza>
-- Modified: <2024-08-16>
-- Description:	<Se cambia el pais de usuario por pais de estacion asignada>
-- =============================================
CREATE PROCEDURE [dbo].[GetInternalLogIn]
	-- Add the parameters for the stored procedure here
	@UserCode BIGINT = 0,
	@UserName VARCHAR(200), 
	@Password VARCHAR(200), 
	@SystemName NVARCHAR(50) = 'Hermes Web'
AS
    BEGIN
        -- SET NOCOUNT ON added to prevent extra result sets from
        -- interfering with SELECT statements.
        SET NOCOUNT ON;

		DECLARE @User AS TABLE(
			UstStatus NVARCHAR(50),
			UsrStatus BIT,
			IdUser BIGINT
		);

		DECLARE @ErrorMessage AS TABLE(
			IdResult INT,
			Message NVARCHAR(200),
			Id NVARCHAR(50)
		);

        DECLARE @StatusRestrinct NVARCHAR(50);
        DECLARE @StatusUser BIT;
        DECLARE @IdUser BIGINT;

		-- POR DEFECTO TOMAR SISTEMA DE HERMES DESKTOP
        DECLARE @IdSystem INT = (
			SELECT 
				TOP 1 
					CS.SysIdSystem 
			FROM 
				[DeliveryBackOffice].[dbo].[CatSystem] CS WITH(NOLOCK) 
			WHERE 
				CS.SysNameSystem = 'Hermes Desktop' 
				AND 
				CS.SysRowStatus = 1
		); -- Hermes web

		-- OBTENER IDENTIFICADOR DEL SISTEMA INGRESADO
		SET @IdSystem = ISNULL(
			(
				SELECT 
					TOP 1 
						CS.SysIdSystem 
				FROM 
					[DeliveryBackOffice].[dbo].[CatSystem] CS WITH(NOLOCK) 
				WHERE 
					CS.SysNameSystem = @SystemName 
					AND 
					CS.SysRowStatus = 1
			)
		,1);
		
        -- VALIDAR USUARIO Y CONTRASEÑA
		-- VALIDAR EL TIPO DE USUARIO QUE INICIA SESIÓN.INI
		DECLARE @VERIFYUSER AS INT = 0;
		SET @VERIFYUSER = (
			SELECT 
				COUNT(iu.Username)
			FROM 
				DeliveryBackOffice.[dbo].RegisterUser ru WITH(NOLOCK)
				INNER JOIN 
					DeliveryBackOffice.[dbo].InternalUser iu WITH(NOLOCK)
					ON 
						ru.UsrIdUser = iu.RegisterUserID
			WHERE 
				iu.Username=@UserName
				AND 
				ru.UsrRowStatus = 1
		)
		
		--OBTIENE EL PAIS DE USUARIO
		DECLARE @IdCountry AS VARCHAR(2) ='GT';
		SELECT @IdCountry = ISNULL(PerCountryOrigin,'GT')
			FROM 
				DeliveryBackOffice.[dbo].RegisterUser ru WITH(NOLOCK)
				INNER JOIN 
					DeliveryBackOffice.[dbo].InternalUser iu WITH(NOLOCK)
					ON ru.UsrIdUser = iu.RegisterUserID
				INNER JOIN 
					DeliveryBackOffice.[dbo].Person per WITH(NOLOCK)
					ON ru.UsrIdPerson = per.PerIdPerson 
			WHERE 
				iu.Username=@UserName
				AND 
				ru.UsrRowStatus = 1		
				

         --VALIDAR EL TIPO DE USUARIO QUE INICIA SESIÓN.FIN

		INSERT INTO @User
			(UstStatus, UsrStatus, IdUser)
        SELECT 
			ISNULL(res.UstStatus, 'N/A') UstStatus, 
			ISNULL(usr.UsrRowStatus, 0) UsrStatus, 
			ISNULL(usr.UsrIdUser, 0) IdUser
        FROM 
			DeliveryBackOffice.[dbo].RegisterUser usr WITH(NOLOCK)
			INNER JOIN 
				DeliveryBackOffice.dbo.InternalUser iu  WITH(NOLOCK)
				ON 
					iu.RegisterUserID = usr.UsrIdUser 
			INNER JOIN 
				DeliveryBackOffice.[dbo].RolByUserBySystem rus  WITH(NOLOCK)
				ON 
					rus.RusIdUser = usr.UsrIdUser
			LEFT JOIN 
				DeliveryBackOffice.[dbo].UserSystemRestriction res  WITH(NOLOCK)
				ON 
					res.UstIdUser = rus.RusIdUser
					AND 
					res.UstIdSystem = rus.RusIdSystem
			LEFT JOIN 
				DeliveryBackOffice.[dbo].[RolByUserBySystem] RBUBA  WITH(NOLOCK)
				ON 
					RBUBA.RusIdUser = usr.UsrIdUser
					AND 
					RBUBA.RusRowStatus = 1
			WHERE 
				iu.IdUser=@UserCode 
				AND iu.Username=@UserName
				AND usr.UsrLastPassword = @Password
                AND rus.RusIdSystem = @IdSystem;
        -- insertar en tabla temporal posbibles mensajes de error

		INSERT INTO @ErrorMessage
			(IdResult, [Message], Id)
        SELECT
			IdResult,
			[Message],
			Id
        FROM
        (
            SELECT 400 AS IdResult, 
                   'Usuario o contraseña invalida' AS Message, 
                   'Invalid' AS Id
            UNION
            SELECT 403 AS IdResult, 
                   'Usuario bloqueado' AS Message, 
                   'Blocked' AS Id
            UNION
            SELECT 403 AS IdResult, 
                   'Usuario inactivo' AS Message, 
                   'Inactive' AS Id
            UNION
            SELECT 400 AS IdResult, 
                   'Cuenta pendiente de confirmación, se envió un nuevo link a su correo electrónico registrado, para poder confirmar su cuenta.' AS Message, 
                   'Confirmation' AS Id
        ) AS errror;
        IF
        (
            SELECT COUNT(*)
            FROM @User
        ) > 0  -- si encuentra registros quiere decir que hay conicidencia en usuario y contraseña
            BEGIN
                -- validar que el usuario no este bloqueado 

                SET @StatusRestrinct =
                (
                    SELECT TOP 1 UPPER(UstStatus)
                    FROM @User
                );
                SET @StatusUser =
                (
                    SELECT TOP 1 UsrStatus
                    FROM @User
                );
                SET @IdUser =
                (
                    SELECT TOP 1 IdUser
                    FROM @User
                );
                IF @StatusRestrinct = 'ACTIVE' --USUARIO sin restricciones
                            BEGIN
                                IF @StatusUser = 1 -- usuario activo
                                    BEGIN
                                        -- GENERAR TOKEN 
                                        DECLARE @Token AS NVARCHAR(50)=
                                        (
                                            SELECT CONVERT(VARCHAR(32), HASHBYTES('MD5', CONCAT(@UserName, @Password, SYSDATETIME())), 2) AS token
                                        );

                                        IF
                                        (
                                            SELECT COUNT(*)
                                            FROM [dbo].TokenLog tkn WITH(NOLOCK)
                                            WHERE tkn.TknIdToken = @Token
                                        ) = 0 --si el token no exite crearlo 
                                        BEGIN
                                                INSERT INTO [dbo].[TokenLog]
                                                (
													[TknIdToken], 
													[TknIdUser], 
													[TknIdSystem], 
													[TknIdHub], 
													[TknIdModule], 
													[TknIdCountry], 
													[TknIP], 
													[TknRowStatus], 
													[TknTokenCreated], 
													[TknDateCreated], 
													[TknTokenUpdated], 
													[TknDateUpdated]
                                                )
                                                VALUES
                                                (
													@Token, 
													@IdUser, 
													@IdSystem, 
													0, 
													0, 
													@IdCountry,--'GT', 
													NULL, 
													1, 
													@Token, 
													GETDATE(), 
													NULL, 
													NULL
                                                );
                                        END;

                                        -- obtener modulos a los que tiene acceso el usuario logueado
										/*tabla temporal ModIdModule*/
										DECLARE @TOTALSUBMODULES INT = 0;
										DECLARE @ITERATORSUBMODULES INT = 1;

										DECLARE @TBSUBMODULES TABLE (
											ITERATOR int Identity(1,1)
											, ModIdModule INT
											, SUBMODULES VARCHAR(MAX)
										);

										SELECT @TOTALSUBMODULES = (
											SELECT 
												COUNT(cmo.ModIdModule) 
											FROM 
												DeliveryBackOffice.[dbo].RegisterUser us WITH(NOLOCK)
												INNER JOIN 
													DeliveryBackOffice.[dbo].[RolByUserBySystem] RBUBA WITH(NOLOCK)
													ON 
														RBUBA.RusIdUser = us.UsrIdUser
												INNER JOIN 
													DeliveryBackOffice.[dbo].RolByModuleBySystem rms  WITH(NOLOCK)
													ON 
														rms.RmsIdRol = RBUBA.RusIdRol
												INNER JOIN 
													DeliveryBackOffice.[dbo].CatModule cmo  WITH(NOLOCK)
													ON cmo.ModIdModule = rms.RmsIdModule
												INNER JOIN 
													DeliveryBackOffice.[dbo].CatRol rol  WITH(NOLOCK)
													ON 
														rol.RolIdRol = rms.RmsIdRol
												INNER JOIN 
													DeliveryBackOffice.dbo.InternalUser iu  WITH(NOLOCK)
													ON 
														iu.RegisterUserID = us.UsrIdUser
                                            WHERE iu.UserName = @UserName 
												AND iu.IdUser=@UserCode
                                                AND iu.RowStatus = 1
                                                AND RBUBA.RusIdSystem = @IdSystem
												AND RBUBA.RusRowStatus = 1
                                                AND rms.RmsRowStatus = 1
                                                AND cmo.ModRowStatus = 1
												AND cmo.ModVisible = 1
												AND cmo.ModIdModuleParent IS NOT NULL
										)

										IF (@TOTALSUBMODULES) > 0
										BEGIN /*PARENT LIST*/
											INSERT INTO @TBSUBMODULES 
												(ModIdModule)
											SELECT 
												cmo.ModIdModule  
											FROM DeliveryBackOffice.[dbo].RegisterUser us WITH(NOLOCK)
												INNER JOIN 
													DeliveryBackOffice.[dbo].[RolByUserBySystem] RBUBA WITH(NOLOCK)
													ON 
														RBUBA.RusIdUser = us.UsrIdUser
                                                INNER JOIN 
												DeliveryBackOffice.[dbo].RolByModuleBySystem rms WITH(NOLOCK)
													ON 
														rms.RmsIdRol = RBUBA.RusIdRol
                                                INNER JOIN 
												DeliveryBackOffice.[dbo].CatModule cmo  WITH(NOLOCK)
													ON 
														cmo.ModIdModule = rms.RmsIdModule
                                                INNER JOIN 
													DeliveryBackOffice.[dbo].CatRol rol  WITH(NOLOCK)
													ON 
														rol.RolIdRol = rms.RmsIdRol
												INNER JOIN 
													DeliveryBackOffice.dbo.InternalUser iu  WITH(NOLOCK)
													ON 
														iu.RegisterUserID = us.UsrIdUser
                                            WHERE 
												iu.UserName = @UserName 
												AND iu.IdUser=@UserCode
                                                AND iu.RowStatus = 1
                                                AND RBUBA.RusIdSystem = @IdSystem
                                                AND rms.RmsRowStatus = 1
                                                AND cmo.ModRowStatus = 1
												AND cmo.ModVisible = 1
												AND cmo.ModIdModuleParent IS NULL
												AND cmo.ModIdModule in ( select ModIdModuleParent from DeliveryBackOffice.[dbo].CatModule WITH(NOLOCK) )
												AND RBUBA.RusRowStatus = 1;
												
											SELECT @TOTALSUBMODULES = COUNT(ModIdModule) FROM @TBSUBMODULES
											
										END 
										
										DECLARE @InformationTable TABLE(ModIdModule INT, Module NVARCHAR(150), Icon NVARCHAR(100), Path NVARCHAR(250))
										
										WHILE @TOTALSUBMODULES > 0
										BEGIN 
										    DECLARE @CHILDSMD VARCHAR(MAX) = '', @CHILDSMENU INT = 0,  @CHILDSMENU2 INT = 1; 
											DECLARE @TBSUBMODULES2 TABLE (ITERATOR2 int Identity(1,1), ModIdModuleDAD INT ,  ModIdModuleCHILD INT);
									        
											INSERT INTO @TBSUBMODULES2 
												(ModIdModuleDAD, ModIdModuleCHILD)											
											SELECT 
												(SELECT TMP.ModIdModule FROM @TBSUBMODULES AS TMP WHERE TMP.ITERATOR = @ITERATORSUBMODULES) AS ModIdModuleDAD , cmo.ModIdModule AS ModIdModuleCHILD  
											FROM DeliveryBackOffice.[dbo].RegisterUser us WITH(NOLOCK)
												INNER JOIN DeliveryBackOffice.[dbo].[RolByUserBySystem] RBUBA WITH(NOLOCK)
													ON RBUBA.RusIdUser = us.UsrIdUser
												INNER JOIN dbo.RolByModuleBySystem rms WITH(NOLOCK) 
													ON rms.RmsIdRol = RBUBA.RusIdRol
												INNER JOIN [dbo].CatModule cmo WITH(NOLOCK) 
													ON cmo.ModIdModule = rms.RmsIdModule
												-- AND 
												INNER JOIN [dbo].CatRol rol  WITH(NOLOCK)
													ON rol.RolIdRol = rms.RmsIdRol
												INNER JOIN DeliveryBackOffice.dbo.InternalUser iu WITH(NOLOCK) 
													ON iu.RegisterUserID = us.UsrIdUser
											WHERE 
												iu.UserName = @UserName 
												and 
												iu.IdUser=@UserCode
                                                AND RBUBA.RusIdSystem = @IdSystem
												AND RBUBA.RusRowStatus = 1
                                                AND rms.RmsRowStatus = 1
												AND iu.RowStatus = 1
												AND cmo.ModRowStatus = 1
												AND cmo.ModVisible = 1
												AND 
												cmo.ModIdModuleParent = (
													SELECT 
														TMP.ModIdModule 
													FROM 
														@TBSUBMODULES AS TMP 
													WHERE 
														TMP.ITERATOR = @ITERATORSUBMODULES
											)

											SELECT @CHILDSMENU = COUNT(1) FROM @TBSUBMODULES2											

											WHILE @CHILDSMENU > 0
											BEGIN 
												INSERT INTO @InformationTable (ModIdModule, Module, Icon, Path)										
												SELECT CMO.ModIdModuleParent,
														cmo.ModName, 
														cmo.ModMetadata, 
														cmo.ModPath 
												FROM [dbo].CatModule cmo WITH (NOLOCK)
												WHERE cmo.ModIdModule = (select TMP.ModIdModuleCHILD from @TBSUBMODULES2 AS TMP where TMP.ITERATOR2 = @CHILDSMENU2)
												AND cmo.ModIdModuleParent = (SELECT TMP.ModIdModule FROM @TBSUBMODULES AS TMP WHERE TMP.ITERATOR = @ITERATORSUBMODULES)

												SET @CHILDSMENU2 = @CHILDSMENU2 + 1;
												SET @CHILDSMENU= @CHILDSMENU - 1
											END 

											SET @ITERATORSUBMODULES = @ITERATORSUBMODULES + 1;
											SET @TOTALSUBMODULES = @TOTALSUBMODULES - 1;
										END 


										/*END SUBMODULOES*/
								SELECT 200 AS IdResult,
									   @Token AS Token

                                SELECT cmo.ModName AS Module, 
										cmo.ModMetadata AS Icon, 
										cmo.ModPath AS Path,
										rol.RolName AS Rol, 
										TMP.ModIdModule AS SubModule
								--(CASE WHEN len(COALESCE(TMP.ModIdModule,'')) > 0 then COALESCE(TMP.ModIdModule,'') else '' end ) AS SubModule
                                FROM DeliveryBackOffice.[dbo].RegisterUser us WITH(NOLOCK)
								INNER JOIN DeliveryBackOffice.[dbo].[RolByUserBySystem] RBUBA WITH(NOLOCK)
									ON RBUBA.RusIdUser = us.UsrIdUser
                                INNER JOIN dbo.RolByModuleBySystem rms WITH(NOLOCK) 
									ON rms.RmsIdRol = RBUBA.RusIdRol
                                INNER JOIN [dbo].CatModule cmo  WITH(NOLOCK)
									ON cmo.ModIdModule = rms.RmsIdModule
                                INNER JOIN [dbo].CatRol rol WITH(NOLOCK) 
									ON rol.RolIdRol = rms.RmsIdRol
								LEFT JOIN @TBSUBMODULES TMP 
									ON TMP.ModIdModule = cmo.ModIdModule 
                                INNER JOIN DeliveryBackOffice.dbo.InternalUser iu WITH (NOLOCK) ON iu.RegisterUserID = us.UsrIdUser
                                WHERE iu.UserName = @UserName AND iu.IdUser=@UserCode
                                    AND RBUBA.RusIdSystem = @IdSystem
                                    AND RBUBA.RusRowStatus = 1
                                    AND rms.RmsRowStatus = 1
                                    AND cmo.ModRowStatus = 1
                                    AND cmo.ModVisible = 1
                                    AND cmo.ModIdModuleParent IS NULL /*IS DAD*/

									--SELECT * FROM @TBSUBMODULES

					-- obtener las cuentas a las que tiene acceso el usuario
					IF EXISTS (SELECT TOP 1 * FROM @InformationTable ) 
					BEGIN 			
							SELECT	ModIdModule,
									Module,
									Icon,
									Path
							FROM @InformationTable
					END
					ELSE
					BEGIN
						SELECT -1 AS ModIdModule, 
								'No hay módulos' AS Modules
					END

                    SELECT us.UsrIdUser AS IdUser, 
							iu.Username AS UserName, 
							'Interno' AS TacName, 
							ro.RolName AS RolName, 
							COALESCE(CTMSP.Code, 'N/A') AS SalesPersonCode 
                        FROM DeliveryBackOffice.dbo.RegisterUser us WITH(NOLOCK)
						INNER JOIN DeliveryBackOffice.dbo.Person pe WITH(NOLOCK) 
							ON pe.PerIdPerson = us.UsrIdPerson
						INNER JOIN DeliveryBackOffice.[dbo].[RolByUserBySystem] RBUBA WITH(NOLOCK)
							ON RBUBA.RusIdUser = us.UsrIdUser
						INNER JOIN DeliveryBackOffice.dbo.CatRol ro WITH(NOLOCK) ON ro.RolIdRol = RBUBA.RusIdRol
						INNER JOIN DeliveryBackOffice.dbo.InternalUser iu WITH(NOLOCK) ON iu.RegisterUserID = UsrIdUser
						LEFT JOIN [DeliveryBackOffice].[dbo].[CatTMSalesPerson] CTMSP WITH(NOLOCK)
							ON CTMSP.RegisterUserId = us.UsrIdUser
							AND CTMSP.RowStatus = 1
					WHERE iu.UserName = @UserName AND iu.IdUser=@UserCode
						AND pe.PerRowStatus = 1
						AND RBUBA.RusIdSystem = @IdSystem
						AND RBUBA.RusRowStatus = 1
						AND iu.RowStatus = 1

                    -- obtener los datos del perfil asociado al usuario 


                    SELECT pe.PerFirstName AS FirstName, 
							pe.PerLastName AS LastName, 
							pe.PerGender AS Gender,
							COALESCE(pe.PerBirthdate,'') AS Birthdate,
							pe.PerIdentification AS Identification,  
							pe.PerNationality AS Nationality, 
							CONVERT(VARCHAR, us.UsrNickName) AS NickName, 
							COALESCE(us.Phone,'') AS Phone, 									 
							1 AS TAC
                    FROM DeliveryBackOffice.dbo.RegisterUser us WITH(NOLOCK)
                            INNER JOIN DeliveryBackOffice.dbo.Person pe WITH(NOLOCK) 
                                    ON pe.PerIdPerson = us.UsrIdPerson
                            INNER JOIN DeliveryBackOffice.dbo.InternalUser iu WITH(NOLOCK) 
                                    ON iu.RegisterUserID = us.UsrIdUser
					WHERE iu.UserName = @UserName AND iu.IdUser=@UserCode
						AND iu.RowStatus = 1
                        AND pe.PerRowStatus = 1


				IF (@VERIFYUSER > 0)
				BEGIN

		   			SELECT DISTINCT
							COALESCE( CS.StationName ,'') AS Name,
							COALESCE( RTRIM(LTRIM(CONCAT(pe.PerFirstName,' ', pe.PerLastName))),'') AS ContactName,   	  
							COALESCE(ru.Phone, '') AS Phone, 
							COALESCE(ru.UsrEmail, '') AS Email, 
							COALESCE(CS.CountryId,'GT') AS IdCountry,
							COALESCE(CS.IdStation,0)  AS Station
			        FROM  
			         DeliveryBackOffice.dbo.InternalUser iu WITH(NOLOCK) 
			        INNER JOIN DeliveryBackOffice.dbo.RegisterUser ru WITH(NOLOCK) 
                            on  ru.UsrIdUser = iu.RegisterUserID 
                    INNER JOIN DeliveryBackOffice.dbo.Person pe WITH(NOLOCK) ON pe.PerIdPerson = ru.UsrIdPerson
                    INNER JOIN DeliveryBackOffice.[dbo].[RolByUserBySystem] RBUBA WITH(NOLOCK)
						ON RBUBA.RusIdUser = ru.UsrIdUser
                    LEFT JOIN [DeliveryBackOffice].[dbo].[CatStation] CS WITH(NOLOCK)
						ON RBUBA.StationId = CS.IdStation
                    WHERE iu.UserName = @UserName AND iu.IdUser=@UserCode
                      AND ru.UsrRowStatus = 1
                      AND pe.PerRowStatus = 1
                      AND RBUBA.RusIdSystem = @IdSystem
                      AND RBUBA.RusRowStatus = 1
				
				END

                END;
                ELSE
                BEGIN

                    SELECT IdResult, 
							Message
                    FROM @ErrorMessage
                    WHERE Id = 'Inactive' 

                END;
        END;
        ELSE -- usuario bloqueado
        BEGIN
            IF((@StatusRestrinct = 'BLOCKED'))
                BEGIN
                    SELECT IdResult,
							Message 
                    FROM @ErrorMessage
                    WHERE Id = 'Blocked' 

                END;
                ELSE -- culaquier otro estado diferente de "ACTIVE" y "BLOCKED"
                BEGIN

                    SELECT IdResult,  
							Message 
                    FROM @ErrorMessage
                    WHERE Id = 'Inactive' 
                END;
        END;

                    
            END;
            ELSE -- usuario o contraseña invalido
            BEGIN

                -- incrementar en 1 los intentos fallidos de inicio de sesion 

                UPDATE [dbo].UserSystemRestriction
                  SET 
                      UstRetries = (UstRetries + 1), 
                      UstStatus = (IIF(UstRetries + 1 >= UstAccessRetries, 'BLOCKED', 'ACTIVE'))
                FROM [dbo].RegisterUser usr
                     LEFT JOIN [dbo].UserSystemRestriction res ON res.UstIdUser = usr.UsrIdUser
                                                                  AND res.UstIdSystem = @IdSystem
                WHERE usr.UsrEmail = @UserName;

                -- retornar mensaje de error

                SELECT IdResult, 
						Message 
                FROM @ErrorMessage
                WHERE Id = 'Invalid' 

            END;

        -- retornar resultado en formato json
    END;
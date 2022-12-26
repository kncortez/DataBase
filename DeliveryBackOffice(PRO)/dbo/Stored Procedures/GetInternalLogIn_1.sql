

-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-09-22>
-- Last Update date: <2022-09-22>
-- Description:	< Login de portal web para usuarios internos >
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

        DECLARE @jsonResult NVARCHAR(MAX);
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
				CS.SysNameSystem = 'Hermes Desktop' COLLATE Latin1_General_CI_AI 
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
					CS.SysNameSystem = @SystemName COLLATE Latin1_General_CI_AI 
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
					AND 
					rus.RusIdSystem = @IdSystem
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
				AND 
				iu.Username=@UserName
				AND 
				usr.UsrLastPassword = @Password;
        -- insertar en tabla temporal posbibles mensajes de error

	--	SELECT * FROM @User

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
                                            FROM [dbo].TokenLog tkn
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
													'GT', 
													NULL, 
													1, 
													@Token, 
													GETDATE(), 
													NULL, 
													NULL
                                                );
                                        END;

                                        DECLARE @JsonModules NVARCHAR(MAX);
                                        DECLARE @JsonAccounts NVARCHAR(MAX);
                                        DECLARE @JsonProfile NVARCHAR(MAX);
										DECLARE @JsonProfileEXP NVARCHAR(MAX) = '';

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
														AND
														RBUBA.RusIdSystem = @IdSystem
														AND 
														RBUBA.RusRowStatus = 1
												INNER JOIN 
													DeliveryBackOffice.[dbo].RolByModuleBySystem rms  WITH(NOLOCK)
													ON 
														rms.RmsIdRol = RBUBA.RusIdRol
														AND 
														rms.RmsRowStatus = 1
												INNER JOIN 
													DeliveryBackOffice.[dbo].CatModule cmo  WITH(NOLOCK)
													ON 
														cmo.ModIdModule = rms.RmsIdModule
														AND 
														cmo.ModRowStatus = 1
														AND 
														cmo.ModVisible = 1
														AND 
														cmo.ModIdModuleParent IS NOT NULL
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
												AND 
												iu.IdUser=@UserCode
                                                AND 
												iu.RowStatus = 1
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
														AND
														RBUBA.RusIdSystem = @IdSystem
														AND 
														RBUBA.RusRowStatus = 1
                                                INNER JOIN 
												DeliveryBackOffice.[dbo].RolByModuleBySystem rms WITH(NOLOCK)
													ON 
														rms.RmsIdRol = RBUBA.RusIdRol
														AND 
														rms.RmsRowStatus = 1
                                                INNER JOIN 
												DeliveryBackOffice.[dbo].CatModule cmo  WITH(NOLOCK)
													ON 
														cmo.ModIdModule = rms.RmsIdModule
														AND 
														cmo.ModRowStatus = 1
														AND 
														cmo.ModVisible = 1
														AND 
														cmo.ModIdModuleParent IS NULL
														AND 
														cmo.ModIdModule in ( select ModIdModuleParent from DeliveryBackOffice.[dbo].CatModule WITH(NOLOCK) )
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
												AND 
												iu.IdUser=@UserCode
                                                AND 
												iu.RowStatus = 1;
												
											SELECT @TOTALSUBMODULES = COUNT(ModIdModule) FROM @TBSUBMODULES
											
										END 

										
										WHILE @TOTALSUBMODULES > 0
										BEGIN 
										    DECLARE @CHILDSMD VARCHAR(MAX) = '', @CHILDSMENU INT = 0,  @CHILDSMENU2 INT = 1; 
											DECLARE @TBSUBMODULES2 TABLE (ITERATOR2 int Identity(1,1), ModIdModuleDAD INT ,  ModIdModuleCHILD INT);
									        
											INSERT INTO @TBSUBMODULES2 
												(ModIdModuleDAD, ModIdModuleCHILD)											
											SELECT 
												(SELECT TMP.ModIdModule FROM @TBSUBMODULES AS TMP WHERE TMP.ITERATOR = @ITERATORSUBMODULES) AS ModIdModuleDAD , cmo.ModIdModule AS ModIdModuleCHILD  
											FROM DeliveryBackOffice.[dbo].RegisterUser us WITH(NOLOCK)
												INNER JOIN 
													DeliveryBackOffice.[dbo].[RolByUserBySystem] RBUBA WITH(NOLOCK)
													ON 
														RBUBA.RusIdUser = us.UsrIdUser
														AND
														RBUBA.RusIdSystem = @IdSystem
														AND 
														RBUBA.RusRowStatus = 1
												INNER JOIN dbo.RolByModuleBySystem rms WITH(NOLOCK) ON rms.RmsIdRol = RBUBA.RusIdRol
												AND rms.RmsRowStatus = 1
												INNER JOIN [dbo].CatModule cmo WITH(NOLOCK) ON cmo.ModIdModule = rms.RmsIdModule
												AND cmo.ModRowStatus = 1
												AND cmo.ModVisible = 1
												-- AND 
												INNER JOIN [dbo].CatRol rol  WITH(NOLOCK)ON rol.RolIdRol = rms.RmsIdRol
												INNER JOIN DeliveryBackOffice.dbo.InternalUser iu WITH(NOLOCK) ON iu.RegisterUserID = us.UsrIdUser
											WHERE 
												iu.UserName = @UserName 
												and 
												iu.IdUser=@UserCode
												AND 
												iu.RowStatus = 1
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
												SELECT @CHILDSMD = @CHILDSMD  + ' {"Module":"' + cmo.ModName + '",' + '"Icon":"' + cmo.ModMetadata + '",' + '"Path":"' + cmo.ModPath + '"},'
                                            FROM [dbo].CatModule cmo 
												  WHERE cmo.ModIdModule = (select TMP.ModIdModuleCHILD from @TBSUBMODULES2 AS TMP where TMP.ITERATOR2 = @CHILDSMENU2)
												  AND cmo.ModIdModuleParent = (SELECT TMP.ModIdModule FROM @TBSUBMODULES AS TMP WHERE TMP.ITERATOR = @ITERATORSUBMODULES)

												SET @CHILDSMENU2 = @CHILDSMENU2 + 1;
												SET @CHILDSMENU= @CHILDSMENU - 1
											END 
											if (@CHILDSMD is not null and LEN(@CHILDSMD)>0)
											BEGIN	
													SET @CHILDSMD = LEFT(@CHILDSMD, LEN(@CHILDSMD) - 1) 
											END
											UPDATE @TBSUBMODULES
											SET SUBMODULES = @CHILDSMD
											WHERE ITERATOR = @ITERATORSUBMODULES
											SET @ITERATORSUBMODULES = @ITERATORSUBMODULES + 1;
											SET @TOTALSUBMODULES = @TOTALSUBMODULES - 1;
										END 

										/*END SUBMODULOES*/
                                        SET @JsonModules =
                                        (
                                            SELECT STUFF(
                                        (
                                            SELECT ',{"Module":"' + cmo.ModName + '",' + '"Icon":"' + cmo.ModMetadata + '",' + '"Path":"' + cmo.ModPath + '",' + '"Rol":"' + rol.RolName + 
											(case when len(isnull(TMP.SUBMODULES,'')) > 0 then 
											'",' + '"SubModule":['+COALESCE(TMP.SUBMODULES,'')+']}'
											else '"}' end )
                                            FROM DeliveryBackOffice.[dbo].RegisterUser us WITH(NOLOCK)
												INNER JOIN 
													DeliveryBackOffice.[dbo].[RolByUserBySystem] RBUBA WITH(NOLOCK)
													ON 
														RBUBA.RusIdUser = us.UsrIdUser
														AND
														RBUBA.RusIdSystem = @IdSystem
														AND 
														RBUBA.RusRowStatus = 1
                                                 INNER JOIN dbo.RolByModuleBySystem rms WITH(NOLOCK) ON rms.RmsIdRol = RBUBA.RusIdRol
                                                          AND rms.RmsRowStatus = 1
                                                 INNER JOIN [dbo].CatModule cmo  WITH(NOLOCK)ON cmo.ModIdModule = rms.RmsIdModule
                                                                                   AND cmo.ModRowStatus = 1
                                                                                   AND cmo.ModVisible = 1
																				   AND cmo.ModIdModuleParent IS NULL /*IS DAD*/
                                                 INNER JOIN [dbo].CatRol rol WITH(NOLOCK) ON rol.RolIdRol = rms.RmsIdRol
												 LEFT JOIN @TBSUBMODULES TMP ON TMP.ModIdModule = cmo.ModIdModule 
                                            INNER JOIN DeliveryBackOffice.dbo.InternalUser iu ON iu.RegisterUserID = us.UsrIdUser
                                            WHERE iu.UserName = @UserName AND iu.IdUser=@UserCode order by cmo.ModOrder FOR XML PATH(''), TYPE
                                        ).value('.', 'varchar(max)'), 1, 1, '')
                                        );
                                        
										-- obtener las cuentas a las que tiene acceso el usuario


                                        SET @JsonAccounts =
                                        (
                                            SELECT STUFF(
                                        (
                                            SELECT ',{"IdUser":"' + CONVERT(VARCHAR, us.UsrIdUser) + '",' + '"UserName":"' + iu.Username + '",' + '"TacName":"Interno",' + '"RolName":"' + ro.RolName + '"' + '}'
                                            FROM DeliveryBackOffice.dbo.RegisterUser us WITH(NOLOCK)
                                                 INNER JOIN DeliveryBackOffice.dbo.Person pe WITH(NOLOCK) ON pe.PerIdPerson = us.UsrIdPerson
                                                                               AND pe.PerRowStatus = 1
													INNER JOIN 
														DeliveryBackOffice.[dbo].[RolByUserBySystem] RBUBA WITH(NOLOCK)
														ON 
															RBUBA.RusIdUser = us.UsrIdUser
															AND
															RBUBA.RusIdSystem = @IdSystem
															AND 
															RBUBA.RusRowStatus = 1
                                                 INNER JOIN DeliveryBackOffice.dbo.CatRol ro WITH(NOLOCK) ON ro.RolIdRol = RBUBA.RusIdRol
												INNER JOIN DeliveryBackOffice.dbo.InternalUser iu WITH(NOLOCK) ON iu.RegisterUserID = UsrIdUser
												WHERE iu.UserName = @UserName AND iu.IdUser=@UserCode
													AND iu.RowStatus = 1 FOR XML PATH(''), TYPE
                                        ).value('.', 'varchar(max)'), 1, 1, '')
                                        );
                                        -- obtener los datos del perfil asociado al usuario 

                                        SET @JsonProfile =
                                        (
                                            SELECT STUFF(
                                        (
                                           SELECT ',{"FirstName":"' + pe.PerFirstName + '",' + '"LastName":"' + pe.PerLastName + '",' + '"Gender":"' + pe.PerGender + '",' +
                                         '"Birthdate":"' + CONVERT(VARCHAR, ISNULL(pe.PerBirthdate,'')) + '",' + '"Identification":"'
                                         + pe.PerIdentification + '",' + '"Nationality":"' + pe.PerNationality + '",' 
                                         + '"NickName":"' + CONVERT(VARCHAR, us.UsrNickName) + '",'
                                         + '"Phone":"' + ISNULL(us.Phone,'') + '",'
										 + '"TAC":"TRUE"}'
                                            FROM DeliveryBackOffice.dbo.RegisterUser us WITH(NOLOCK)
                                                    INNER JOIN DeliveryBackOffice.dbo.Person pe WITH(NOLOCK) ON pe.PerIdPerson = us.UsrIdPerson
                                                                                AND pe.PerRowStatus = 1
                                            INNER JOIN DeliveryBackOffice.dbo.InternalUser iu WITH(NOLOCK) ON iu.RegisterUserID = us.UsrIdUser
												WHERE iu.UserName = @UserName AND iu.IdUser=@UserCode
													    AND iu.RowStatus = 1
                                         FOR XML PATH(''), TYPE
                                        ).value('.', 'varchar(max)'), 1, 1, '')
                                        );

						      IF (@VERIFYUSER > 0)
							  BEGIN

                               SET @JsonProfileEXP = (SELECT STUFF((
		   							SELECT DISTINCT
											',{"Name":"' + ISNULL( CS.StationName ,'') + '",' +
											'"ContactName":"' + isnull( RTRIM(LTRIM(CONCAT(pe.PerFirstName,' ', pe.PerLastName))) , '')  + '",' +	  	  
											'"Phone":"' + isnull(ru.Phone, '')  + '",' +
											'"Email":"' + isnull(ru.UsrEmail, '')  + '",' +
											'"Station":' + CAST(ISNULL(CS.IdStation,0) AS NVARCHAR)+',' + '}' 
			        FROM  
			         DeliveryBackOffice.dbo.InternalUser iu WITH(NOLOCK) 
			        INNER JOIN DeliveryBackOffice.dbo.RegisterUser ru WITH(NOLOCK) on  ru.UsrIdUser = iu.RegisterUserID and ru.UsrRowStatus = 1
                    INNER JOIN DeliveryBackOffice.dbo.Person pe WITH(NOLOCK) ON pe.PerIdPerson = ru.UsrIdPerson
                                                AND pe.PerRowStatus = 1
					INNER JOIN  DeliveryBackOffice.[dbo].[RolByUserBySystem] RBUBA WITH(NOLOCK)
						ON 
							RBUBA.RusIdUser = ru.UsrIdUser
							AND
							RBUBA.RusIdSystem = @IdSystem
							AND 
							RBUBA.RusRowStatus = 1
					LEFT JOIN [DeliveryBackOffice].[dbo].[CatStation] CS WITH(NOLOCK)
						ON
							RBUBA.StationId = CS.IdStation
			         WHERE iu.UserName = @UserName AND iu.IdUser=@UserCode

		    FOR XML PATH(''), TYPE
		   ).value('.', 'varchar(max)'),1,1,''
		   			  )) 				
END

         SET @jsonResult =
                                        (
                                            SELECT STUFF(
                                        (
                                            SELECT '{"IdResult":200' + ',' + '"Token":"' + @Token + '",' + '"Modules":[' + ISNULL(@JsonModules,'No hay módulos') + '],' + '"Accounts":[' + @JsonAccounts + '],' + '"Profile":[' + CASE WHEN @VERIFYUSER > 0 THEN @JsonProfile + ',' + @JsonProfileEXP ELSE @JsonProfile END + ']' + '}' FOR XML PATH(''), TYPE
                                        ).value('.', 'varchar(max)'), 1, 1, '')
                                        );
                                    END;
                                    ELSE
                                    BEGIN
                                        SET @jsonResult =
                                        (
                                            SELECT STUFF(
                                        (
                                            SELECT '{"IdResult":' + CONVERT(VARCHAR, IdResult) + ',' + '"Message":"' + Message + '"}'
                                            FROM @ErrorMessage
                                            WHERE Id = 'Inactive' FOR XML PATH(''), TYPE
                                        ).value('.', 'varchar(max)'), 1, 1, '')
                                        );
                                    END;
                            END;
                            ELSE -- usuario bloqueado
                            BEGIN
                                IF((@StatusRestrinct = 'BLOCKED'))
                                    BEGIN
                                        SET @jsonResult =
                                        (
                                            SELECT STUFF(
                                        (
                                            SELECT '{"IdResult":' + CONVERT(VARCHAR, IdResult) + ',' + '"Message":"' + Message + '"}'
                                            FROM @ErrorMessage
                                            WHERE Id = 'Blocked' FOR XML PATH(''), TYPE
                                        ).value('.', 'varchar(max)'), 1, 1, '')
                                        );
                                    END;
                                    ELSE -- culaquier otro estado diferente de "ACTIVE" y "BLOCKED"
                                    BEGIN
                                        SET @jsonResult =
                                        (
                                            SELECT STUFF(
                                        (
                                            SELECT '{"IdResult":' + CONVERT(VARCHAR, IdResult) + ',' + '"Message":"' + Message + '"}'
                                            FROM @ErrorMessage
                                            WHERE Id = 'Inactive' FOR XML PATH(''), TYPE
                                        ).value('.', 'varchar(max)'), 1, 1, '')
                                        );
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
                SET @jsonResult =
                (
                    SELECT STUFF(
                (
                    SELECT '{"IdResult":' + CONVERT(VARCHAR, IdResult) + ',' + '"Message":"' + Message + '"}'
                    FROM @ErrorMessage
                    WHERE Id = 'Invalid' FOR XML PATH(''), TYPE
                ).value('.', 'varchar(max)'), 1, 1, '')
                );
            END;

        -- retornar resultado en formato json

        SELECT('[{' + @jsonResult + ']') jsonResult;
    END;
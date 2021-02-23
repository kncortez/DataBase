-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2020-12-30>
-- Update date: <2021-02-03>
-- Description:	<Login Portal Web>
-- =============================================

CREATE PROCEDURE [dbo].[spws_get_login_childmenus]
-- Add the parameters for the stored procedure here
@Username VARCHAR(200), 
@Password VARCHAR(200), 
@IP       VARCHAR(30), 
@IdSystem INT          = 1
AS
    BEGIN
        -- SET NOCOUNT ON added to prevent extra result sets from
        -- interfering with SELECT statements.
        SET NOCOUNT ON;
        DECLARE @jsonResult NVARCHAR(MAX);
        DECLARE @StatusRestrinct NVARCHAR(50);
        DECLARE @StatusUser BIT;
        DECLARE @IdUser BIGINT;
        DECLARE @StatusAccount CHAR(1);
        --	declare @Username as nvarchar(100)='a.cesarene@gmail.com'
        --	declare	@Password as nvarchar(100)='7hFMXRrKI3G0addPtjwAHA=='
        --	declare @IdSystem as int = 1 
        --	DECLARE	@IP AS NVARCHAR(30) ='localhost'
        -- validar usuario y contraseña

        SELECT ISNULL(res.UstStatus, 'N/A') UstStatus, 
               ISNULL(usr.UsrRowStatus, 0) UsrStatus, 
               ISNULL(usr.UsrIdUser, 0) IdUser, 
               ISNULL(ac.AccConfirm, 'N') StatusAccount
        INTO #User
        FROM [dbo].RegisterUser usr
             INNER JOIN [dbo].RolByUserBySystem rus ON rus.RusIdUser = usr.UsrIdUser
                                                       AND rus.RusIdSystem = @IdSystem
             LEFT JOIN [dbo].UserSystemRestriction res ON res.UstIdUser = rus.RusIdUser
                                                          AND res.UstIdSystem = rus.RusIdSystem
             LEFT JOIN [dbo].[RolByUserByAccount] rua ON rua.RuaIdUser = usr.UsrIdUser
                                                         AND rua.RuaRowStatus = 1
             INNER JOIN [dbo].Account ac ON ac.AccIdAccount = rua.RuaIdAccount
                                            AND ac.AccRowStatus = 1
        WHERE usr.UsrEmail = @UserName
              AND usr.UsrLastPassword = @Password;
        -- insertar en tabla temporal posbibles mensajes de error

        IF OBJECT_ID('tempdb.dbo.#errormessage', 'U') IS NOT NULL
            DROP TABLE #errormessage;
        SELECT *
        INTO #errormessage
        FROM
        (
            SELECT 500 AS IdResult, 
                   'Usuario o contraseña invalida' AS Message, 
                   'Invalid' AS Id
            UNION
            SELECT 500 AS IdResult, 
                   'Usuario bloqueado' AS Message, 
                   'Blocked' AS Id
            UNION
            SELECT 500 AS IdResult, 
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
            FROM #User
        ) > 0  -- si encuentra registros quiere decir que hay conicidencia en usuario y contraseña
            BEGIN
                -- validar que el usuario no este bloqueado 

                SET @StatusRestrinct =
                (
                    SELECT TOP 1 UPPER(UstStatus)
                    FROM #User
                );
                SET @StatusUser =
                (
                    SELECT TOP 1 UsrStatus
                    FROM #User
                );
                SET @IdUser =
                (
                    SELECT TOP 1 IdUser
                    FROM #User
                );
                SET @StatusAccount =
                (
                    SELECT TOP 1 StatusAccount
                    FROM #User
                );
                IF @StatusAccount = 'C'
    BEGIN
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
                                                ([TknIdToken], 
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
                                                (@Token, 
                                                 @IdUser, 
                                                 @IdSystem, 
                                                 0, 
                                                 0, 
                                                 'GT', 
                                                 @IP, 
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

                                        -- obtener modulos a los que tiene acceso el usuario logueado
										/*tabla temporal ModIdModule*/
										DECLARE @TOTALSUBMODULES INT = 0, @ITERATORSUBMODULES INT = 1;
										DECLARE @TBSUBMODULES TABLE (ITERATOR int Identity(1,1), ModIdModule INT , SUBMODULES VARCHAR(MAX));
										SELECT  @TOTALSUBMODULES = COUNT(cmo.ModIdModule) FROM RegisterUser us
                                                 INNER JOIN [dbo].[RolByUserByAccount] rua ON rua.RuaIdUser = us.UsrIdUser
                                                                                              AND rua.RuaRowStatus = 1
                                                 INNER JOIN dbo.RolByModuleBySystem rms ON rms.RmsIdRol = rua.RuaIdRol
                                                          AND rms.RmsRowStatus = 1
                                                 INNER JOIN [dbo].CatModule cmo ON cmo.ModIdModule = rms.RmsIdModule
                                                                                   AND cmo.ModRowStatus = 1
                                                                                   AND cmo.ModVisible = 1
																				   AND cmo.ModIdModuleParent IS NULL
                                                 INNER JOIN [dbo].CatRol rol ON rol.RolIdRol = rms.RmsIdRol
                                            WHERE us.UsrEmail = @UserName
                                                  AND us.UsrRowStatus = 1;
										IF (@TOTALSUBMODULES) > 0
										BEGIN /*PARENT LIST*/
											INSERT  INTO  @TBSUBMODULES (ModIdModule)
											SELECT distinct cmo.ModIdModule  FROM RegisterUser us
                                                 INNER JOIN [dbo].[RolByUserByAccount] rua ON rua.RuaIdUser = us.UsrIdUser
                                                                                              AND rua.RuaRowStatus = 1
                                                 INNER JOIN dbo.RolByModuleBySystem rms ON rms.RmsIdRol = rua.RuaIdRol
                                                          AND rms.RmsRowStatus = 1
                                                 INNER JOIN [dbo].CatModule cmo ON cmo.ModIdModule = rms.RmsIdModule
                                                                                   AND cmo.ModRowStatus = 1
                                                                                   AND cmo.ModVisible = 1
																				   AND cmo.ModIdModuleParent IS NULL
																				   AND cmo.ModIdModule in (
																				   select ModIdModuleParent from [dbo].CatModule 
																				   )
                                                 INNER JOIN [dbo].CatRol rol ON rol.RolIdRol = rms.RmsIdRol
                                            WHERE us.UsrEmail = @UserName
                                                  AND us.UsrRowStatus = 1;
											SELECT @TOTALSUBMODULES = COUNT(ModIdModule) FROM @TBSUBMODULES
										END 
										/*INSERT SUBMODULES*/
										WHILE @TOTALSUBMODULES > 0
										BEGIN 
										    DECLARE @CHILDSMD VARCHAR(MAX) = '', @CHILDSMENU INT = 0,  @CHILDSMENU2 INT = 1; 
											DECLARE @TBSUBMODULES2 TABLE (ITERATOR2 int Identity(1,1), ModIdModuleDAD INT ,  ModIdModuleCHILD INT);
									        
											INSERT INTO @TBSUBMODULES2 (ModIdModuleDAD, ModIdModuleCHILD)
										   SELECT (SELECT TMP.ModIdModule FROM @TBSUBMODULES AS TMP WHERE TMP.ITERATOR = @ITERATORSUBMODULES) AS ModIdModuleDAD , cmo.ModIdModule AS ModIdModuleCHILD  
										   FROM [dbo].CatModule cmo 
                                            WHERE cmo.ModIdModuleParent = (SELECT TMP.ModIdModule FROM @TBSUBMODULES AS TMP WHERE TMP.ITERATOR = @ITERATORSUBMODULES);
											SELECT @CHILDSMENU = COUNT(1) FROM @TBSUBMODULES2
											
											WHILE @CHILDSMENU > 0
											BEGIN 
												SELECT @CHILDSMD = @CHILDSMD  + ' {"Module":"' + cmo.ModName + '",' + '"Icon":"' + cmo.ModMetadata + '",' + '"Path":"' + cmo.ModPath + '"},'
                                            FROM [dbo].CatModule cmo 
												  WHERE cmo.ModIdModule = (select TMP.ModIdModuleCHILD from @TBSUBMODULES2 AS TMP where TMP.ITERATOR2 = @CHILDSMENU2)

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
                                            FROM RegisterUser us
                                                 INNER JOIN [dbo].[RolByUserByAccount] rua ON rua.RuaIdUser = us.UsrIdUser
                                                                                              AND rua.RuaRowStatus = 1
                                                 INNER JOIN dbo.RolByModuleBySystem rms ON rms.RmsIdRol = rua.RuaIdRol
                                                          AND rms.RmsRowStatus = 1
                                                 INNER JOIN [dbo].CatModule cmo ON cmo.ModIdModule = rms.RmsIdModule
                                                                                   AND cmo.ModRowStatus = 1
                                                                                   AND cmo.ModVisible = 1
																				   AND cmo.ModIdModuleParent IS NULL /*IS DAD*/
                                                 INNER JOIN [dbo].CatRol rol ON rol.RolIdRol = rms.RmsIdRol
												 LEFT JOIN @TBSUBMODULES TMP ON TMP.ModIdModule = cmo.ModIdModule 
                                            WHERE us.UsrEmail = @UserName
                                                  AND us.UsrRowStatus = 1 order by cmo.ModOrder FOR XML PATH(''), TYPE
                                        ).value('.', 'varchar(max)'), 1, 1, '')
                                        );
                                        -- obtener las cuentas a las que tiene acceso el usuario

                                        SET @JsonAccounts =
                                        (
                                            SELECT STUFF(
                                        (
                                            SELECT ',{"IdAccount":"' + CONVERT(VARCHAR, ac.AccIdAccount) + '",' + '"AccountName":"' + ac.AccName + '",' + '"TacName":"' + ta.TacName + '",' + '"IdCustomer":"' + CONVERT(VARCHAR, ISNULL(ac.IdCustomer, 0)) + '
"}'
                                            FROM RegisterUser us
                                                 INNER JOIN [dbo].Person pe ON pe.PerIdPerson = us.UsrIdPerson
                                                                               AND pe.PerRowStatus = 1
                                                 INNER JOIN [dbo].[RolByUserByAccount] rua ON rua.RuaIdUser = us.UsrIdUser
                                                                                              AND rua.RuaRowStatus = 1
                                                 INNER JOIN [dbo].CatRol ro ON ro.RolIdRol = rua.RuaIdRol
                                                 INNER JOIN [dbo].Account ac ON ac.AccIdAccount = rua.RuaIdAccount
                                                                                AND ac.AccRowStatus = 1
                                                 INNER JOIN [dbo].CatTypeAccount ta ON ta.TacIdTypeAccount = ac.AccIdTypeAccount
                                            WHERE us.UsrEmail = @UserName
                                                  AND us.UsrRowStatus = 1 FOR XML PATH(''), TYPE
                                        ).value('.', 'varchar(max)'), 1, 1, '')
                                        );
                                        -- obtener los datos del perfil asociado al usuario 

                                        SET @JsonProfile =
                                        (
                                            SELECT STUFF(
                                        (
                                            SELECT ',{"FirstName":"' + pe.PerFirstName + '",' + '"LastName":"' + pe.PerLastName + '",' + '"Gender":"' + pe.PerGender + '",' + '"Birthdate":"' + CONVERT(VARCHAR, pe.PerBirthdate) + '",' + '"Identification":"'
 + pe.PerIdentification + '",' + '"Nationality":"' + pe.PerNationality + '",' + '"NickName":"' + CONVERT(VARCHAR, us.UsrNickName) + '"}'
                                            FROM RegisterUser us
                                                 INNER JOIN [dbo].Person pe ON pe.PerIdPerson = us.UsrIdPerson
                                                                               AND pe.PerRowStatus = 1
                                            WHERE us.UsrEmail = @UserName
                                                  AND us.UsrRowStatus = 1 FOR XML PATH(''), TYPE
                                        ).value('.', 'varchar(max)'), 1, 1, '')
                                        );
         SET @jsonResult =
                                        (
                                            SELECT STUFF(
                                        (
                                            SELECT '{"IdResult":200' + ',' + '"Token":"' + @Token + '",' + '"Modules":[' + @JsonModules + '],' + '"Accounts":[' + @JsonAccounts + '],' + '"Profile":[' + @JsonProfile + ']' + '}' FOR XML PATH(''), TYPE
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
                                            FROM #errormessage
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
                                            FROM #errormessage
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
                                            FROM #errormessage
                                            WHERE Id = 'Inactive' FOR XML PATH(''), TYPE
                                        ).value('.', 'varchar(max)'), 1, 1, '')
                                        );
                                    END;
                            END;
                    END;
                    ELSE
                    BEGIN
                        SET @jsonResult =
                        (
                            SELECT STUFF(
                        (
                            SELECT '{"IdResult":' + CONVERT(VARCHAR, IdResult) + ',' + '"Message":"' + Message + '"}'
                            FROM #errormessage
                            WHERE Id = 'Confirmation' FOR XML PATH(''), TYPE
                        ).value('.', 'varchar(max)'), 1, 1, '')
                        );
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
                    FROM #errormessage
                    WHERE Id = 'Invalid' FOR XML PATH(''), TYPE
                ).value('.', 'varchar(max)'), 1, 1, '')
                );
            END;

        -- destruir tablas temporales

        IF OBJECT_ID('tempdb.dbo.#User', 'U') IS NOT NULL
            DROP TABLE #User;
        IF OBJECT_ID('tempdb.dbo.#errormessage', 'U') IS NOT NULL
            DROP TABLE #errormessage;

        -- retornar resultado en formato json

        SELECT('[{' + @jsonResult + ']') jsonResult;
    END;
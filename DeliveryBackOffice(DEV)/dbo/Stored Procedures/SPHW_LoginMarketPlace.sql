-- =============================================
-- Author:		<Author,Edelman Vásquez>
-- Create date: <Create Date,2023-08-21>
-- Description:	<Description, inicio de sesión de usuarios individuales y de Express Center, en sitio de Market place.>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_LoginMarketPlace] 
    @Username VARCHAR(200)
  , @Password VARCHAR(200)
  , @IP VARCHAR(30)
  , @IdSystem INT = 1
AS
BEGIN
PRINT 'TEST';
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    DECLARE @jsonResult NVARCHAR(MAX);
    DECLARE @StatusRestrinct NVARCHAR(50);
    DECLARE @StatusUser BIT;
    DECLARE @IdUser BIGINT;
    DECLARE @StatusAccount CHAR(1);
    DECLARE @PasswordExpired BIT;
    DECLARE @VisitPointValid BIT = 0;

    --VALIDAR EL TIPO DE USUARIO QUE INICIA SESIÓN.INI
    DECLARE @VERIFYUSER AS INT = 0;
    SET @VERIFYUSER =
    (
        SELECT COUNT(iu.IdEmployee)
        FROM RegisterUser           ru
            INNER JOIN InternalUser iu
                ON ru.UsrIdUser = iu.RegisterUserID
        WHERE ru.UsrEmail = @Username
              AND ru.UsrRowStatus = 1
    );

    --VALIDAR EL TIPO DE USUARIO QUE INICIA SESIÓN.FIN
	PRINT 'TEST1';

    SELECT ISNULL(res.UstStatus, 'N/A') UstStatus
         , ISNULL(usr.UsrRowStatus, 0)  UsrStatus
         , ISNULL(usr.UsrIdUser, 0)     IdUser
         , ISNULL(ac.AccConfirm, 'N')   StatusAccount
         , (CASE
                WHEN ISNULL(usr.ChangePassword, 0) = 1
                     AND ISNULL(usr.UsrPasswordExpiration, CAST(GETDATE() AS DATE)) <= CAST(GETDATE() AS DATE) THEN
                    1
                ELSE
                    0
            END
           )                            PasswordExpired
    INTO #User
    FROM [dbo].RegisterUser                   usr WITH (NOLOCK)
        INNER JOIN [dbo].RolByUserBySystem    rus WITH (NOLOCK)
            ON rus.RusIdUser = usr.UsrIdUser
               AND rus.RusIdSystem = @IdSystem
        LEFT JOIN [dbo].UserSystemRestriction res WITH (NOLOCK)
            ON res.UstIdUser = rus.RusIdUser
               AND res.UstIdSystem = rus.RusIdSystem
        LEFT JOIN [dbo].[RolByUserByAccount]  rua WITH (NOLOCK)
            ON rua.RuaIdUser = usr.UsrIdUser
               AND rua.RuaRowStatus = 1
        INNER JOIN [dbo].Account              ac WITH (NOLOCK)
            ON ac.AccIdAccount = rua.RuaIdAccount
               AND ac.AccRowStatus = 1
    WHERE usr.UsrEmail = @Username
          AND usr.UsrLastPassword = @Password;
    -- insertar en tabla temporal posbibles mensajes de error

    IF OBJECT_ID('tempdb.dbo.#errormessage', 'U') IS NOT NULL
        DROP TABLE #errormessage;
    SELECT *
    INTO #errormessage
    FROM
    (
        SELECT 500                             AS IdResult
             , 'Usuario o contraseña invalida' AS Message
             , 'Invalid'                       AS Id
        UNION
        SELECT 500                 AS IdResult
             , 'Usuario bloqueado' AS Message
             , 'Blocked'           AS Id
        UNION
        SELECT 500                AS IdResult
             , 'Usuario inactivo' AS Message
             , 'Inactive'         AS Id
        UNION
        SELECT 500                   AS IdResult
             , 'Contraseña expirada' AS Message
             , 'PasswordExpired'     AS Id
        UNION
        SELECT 400                                                                                                                            AS IdResult
             , 'Cuenta pendiente de confirmación, se envió un nuevo link a su correo electrónico registrado, para poder confirmar su cuenta.' AS Message
             , 'Confirmation'                                                                                                                 AS Id
    ) AS errror;
    IF
    (
        SELECT COUNT(*)FROM #User
    ) > 0 -- si encuentra registros quiere decir que hay conicidencia en usuario y contraseña
    BEGIN
        -- Validación de visit point para express center
		PRINT 'TEST3';
        IF (@VERIFYUSER > 0)
        BEGIN
            SET @VisitPointValid =
            (
                SELECT [VPC].[StatusClient]
                FROM [dbo].[RegisterUser]               RU
                    INNER JOIN [dbo].[VisitPointByUser] VP
                        ON [RU].[UsrIdUser] = [VP].[RegisterUserID]
                    INNER JOIN [dbo].[VisitPointClient] VPC
                        ON [VP].[IdVisitPointClient] = [VPC].[IdVisitPointClient]
                WHERE [RU].[UsrEmail] = @Username AND VP.RowStatus = 1
            );

            IF (@VisitPointValid = 0)
            BEGIN

                 SELECT 'IdResult' + CONVERT(VARCHAR, IdResult),
				        'Message'Message
                 FROM #errormessage
                     WHERE Id = 'Inactive'

                RETURN;
            END;

        END;
		PRINT 'TEST4';

        -- validar que el usuario no este bloqueado 

        SET @StatusRestrinct =
        (
            SELECT TOP 1 UPPER(UstStatus)FROM #User
        );
        SET @StatusUser =
        (
            SELECT TOP 1 UsrStatus FROM #User
        );
        SET @IdUser =
        (
            SELECT TOP 1 IdUser FROM #User
        );
        SET @StatusAccount =
        (
            SELECT TOP 1 StatusAccount FROM #User
        );
        SET @PasswordExpired =
        (
            SELECT TOP 1 PasswordExpired FROM #User
        );
        IF @StatusAccount = 'C'
        BEGIN
            IF @StatusRestrinct = 'ACTIVE' --USUARIO sin restricciones
            BEGIN
                IF @PasswordExpired = 0 --USUARIO sin restricciones
                BEGIN

                    IF @StatusUser = 1 -- usuario activo
                    BEGIN
                        -- GENERAR TOKEN 
                        DECLARE @Token AS NVARCHAR(50)
                            =
                                (
                                    SELECT CONVERT(
                                                      VARCHAR(32)
                                                    , HASHBYTES('MD5', CONCAT(@Username, @Password, SYSDATETIME()))
                                                    , 2
                                                  ) AS token
                                );
                        IF
                        (
                            SELECT COUNT(*)FROM [dbo].TokenLog tkn WHERE tkn.TknIdToken = @Token
                        ) = 0 --si el token no exite crearlo 
                        BEGIN

						PRINT 'TEST6';
                            INSERT INTO [dbo].[TokenLog]
                            (
                                [TknIdToken]
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
                            )
                            VALUES
                            (@Token, @IdUser, @IdSystem, 0, 0, 'GT', @IP, 1, @Token, GETDATE(), NULL, NULL);
                        END;

						PRINT 'TEST7';
                        DECLARE @JsonModules NVARCHAR(MAX);
                        DECLARE @JsonAccounts NVARCHAR(MAX);
                        DECLARE @JsonProfile NVARCHAR(MAX);
                        DECLARE @JsonProfileEXP NVARCHAR(MAX) = N'';

                        -- obtener modulos a los que tiene acceso el usuario logueado
                        /*tabla temporal ModIdModule*/
                        DECLARE @TOTALSUBMODULES    INT = 0
                              , @ITERATORSUBMODULES INT = 1;
                        DECLARE @TBSUBMODULES TABLE
                        (
                            ITERATOR INT IDENTITY(1, 1)
                          , ModIdModule INT
                          , SUBMODULES VARCHAR(MAX)
                        );
                        SELECT @TOTALSUBMODULES = COUNT(cmo.ModIdModule)
                        FROM RegisterUser                         us
                            INNER JOIN [dbo].[RolByUserByAccount] rua
                                ON rua.RuaIdUser = us.UsrIdUser
                                   AND rua.RuaRowStatus = 1
                            INNER JOIN dbo.RolByModuleBySystem    rms
                                ON rms.RmsIdRol = rua.RuaIdRol
                                   AND rms.RmsRowStatus = 1
                            INNER JOIN [dbo].CatModule            cmo
                                ON cmo.ModIdModule = rms.RmsIdModule
                                   AND cmo.ModRowStatus = 1
                                   AND cmo.ModVisible = 1
                                   AND cmo.ModIdModuleParent IS NOT NULL
                            INNER JOIN [dbo].CatRol               rol
                                ON rol.RolIdRol = rms.RmsIdRol
                        WHERE us.UsrEmail = @Username
                              AND us.UsrRowStatus = 1;
                        IF (@TOTALSUBMODULES) > 0
                        BEGIN /*PARENT LIST*/
                            INSERT INTO @TBSUBMODULES
                            (
                                ModIdModule
                            )
                            SELECT cmo.ModIdModule
                            FROM RegisterUser                         us
                                INNER JOIN [dbo].[RolByUserByAccount] rua
                                    ON rua.RuaIdUser = us.UsrIdUser
                                       AND rua.RuaRowStatus = 1
                                INNER JOIN dbo.RolByModuleBySystem    rms
                                    ON rms.RmsIdRol = rua.RuaIdRol
                                       AND rms.RmsRowStatus = 1
                                INNER JOIN [dbo].CatModule            cmo
                                    ON cmo.ModIdModule = rms.RmsIdModule
                                       AND cmo.ModRowStatus = 1
                                       AND cmo.ModVisible = 1
                                       AND cmo.ModIdModuleParent IS NULL
                                       AND cmo.ModIdModule IN
                                           (
                                               SELECT ModIdModuleParent FROM [dbo].CatModule
                                           )
                                INNER JOIN [dbo].CatRol               rol
                                    ON rol.RolIdRol = rms.RmsIdRol
                            WHERE us.UsrEmail = @Username
                                  AND us.UsrRowStatus = 1;

                            SELECT @TOTALSUBMODULES = COUNT(ModIdModule)
                            FROM @TBSUBMODULES;

                        END;
                        /*INSERT SUBMODULES*/
                        WHILE @TOTALSUBMODULES > 0
                        BEGIN
                            DECLARE @CHILDSMD    VARCHAR(MAX) = ''
                                  , @CHILDSMENU  INT          = 0
                                  , @CHILDSMENU2 INT          = 1;
                            DECLARE @TBSUBMODULES2 TABLE
                            (
                                ITERATOR2 INT
                              , ModIdModuleDAD INT
                              , ModIdModuleCHILD INT
                            );

                            DELETE @TBSUBMODULES2
                            WHERE 1 = 1;
                            INSERT INTO @TBSUBMODULES2
                            (
                                ITERATOR2
                              , ModIdModuleDAD
                              , ModIdModuleCHILD
                            )
                            SELECT ROW_NUMBER() OVER (ORDER BY cmo.ModIdModule ASC)
                                 , (
                                       SELECT TMP.ModIdModule
                                       FROM @TBSUBMODULES AS TMP
                                       WHERE TMP.ITERATOR = @ITERATORSUBMODULES
                                   )               AS ModIdModuleDAD
                                 , cmo.ModIdModule AS ModIdModuleCHILD
                            FROM RegisterUser                         us
                                INNER JOIN [dbo].[RolByUserByAccount] rua
                                    ON rua.RuaIdUser = us.UsrIdUser
                                       AND rua.RuaRowStatus = 1
                                INNER JOIN dbo.RolByModuleBySystem    rms
                                    ON rms.RmsIdRol = rua.RuaIdRol
                                       AND rms.RmsRowStatus = 1
                                INNER JOIN [dbo].CatModule            cmo
                                    ON cmo.ModIdModule = rms.RmsIdModule
                                       AND cmo.ModRowStatus = 1
                                       AND cmo.ModVisible = 1
                                -- AND 
                                INNER JOIN [dbo].CatRol               rol
                                    ON rol.RolIdRol = rms.RmsIdRol
                            WHERE us.UsrEmail = @Username
                                  AND us.UsrRowStatus = 1 --order by cmo.ModOrder
                                  AND cmo.ModIdModuleParent =
                                  (
                                      SELECT TMP.ModIdModule
                                      FROM @TBSUBMODULES AS TMP
                                      WHERE TMP.ITERATOR = @ITERATORSUBMODULES
                                  );
								  PRINT 'TEST8';
                            SELECT @CHILDSMENU = COUNT(1)
                            FROM @TBSUBMODULES2;
                            PRINT @CHILDSMENU;
                            WHILE @CHILDSMENU > 0
                            BEGIN
                                SELECT @CHILDSMD
                                    = @CHILDSMD + 'Module' + cmo.ModName + '",' + 'Icon' + cmo.ModMetadata
                                      + '",' + 'Path' + cmo.ModPath 
                                FROM [dbo].CatModule cmo
                                WHERE cmo.ModIdModule =
                                (
                                    SELECT TMP.ModIdModuleCHILD
                                    FROM @TBSUBMODULES2 AS TMP
                                    WHERE TMP.ITERATOR2 = @CHILDSMENU2
                                );

                                SET @CHILDSMENU2 = @CHILDSMENU2 + 1;
                                SET @CHILDSMENU = @CHILDSMENU - 1;
                            END;
                            IF (@CHILDSMD IS NOT NULL AND LEN(@CHILDSMD) > 0)
                            BEGIN
                                SET @CHILDSMD = LEFT(@CHILDSMD, LEN(@CHILDSMD) - 1);
                            END;
                            UPDATE @TBSUBMODULES
                            SET SUBMODULES = @CHILDSMD
                            WHERE ITERATOR = @ITERATORSUBMODULES;
                            SET @ITERATORSUBMODULES = @ITERATORSUBMODULES + 1;
                            SET @TOTALSUBMODULES = @TOTALSUBMODULES - 1;
                        END;

                        /*END SUBMODULOES*/
                     
                                                SELECT    cmo.ModName AS 'Module' ,
												          cmo.ModMetadata AS 'Icon',
													      cmo.ModPath AS 'Path',
                                                        CAST(ISNULL(rms.RmsModuleMenu, 1) AS NVARCHAR) AS 'MenuId',
                                                        CAST(ISNULL(cmo.ModGroup, 0) AS NVARCHAR) AS 'GroupId',
                                                        CAST(ISNULL(rms.RmsHasNewFunction, 0) AS NVARCHAR) AS 'NewFunction',
                                                        rol.RolName  'Rol',
                                                       CASE
                                                              WHEN LEN(ISNULL(TMP.SUBMODULES, '')) > 0 THEN
                                                                 COALESCE(TMP.SUBMODULES, '')
                                                              ELSE
                                                                  ''
                                                          END  AS SUBMODULES
                                                         
                                                FROM RegisterUser                         us
                                                    INNER JOIN [dbo].[RolByUserByAccount] rua
                                                        ON rua.RuaIdUser = us.UsrIdUser
                                                           AND rua.RuaRowStatus = 1
                                                    INNER JOIN dbo.RolByModuleBySystem    rms
                                                        ON rms.RmsIdRol = rua.RuaIdRol
                                                           AND rms.RmsRowStatus = 1
                                                    INNER JOIN [dbo].CatModule            cmo
                                                        ON cmo.ModIdModule = rms.RmsIdModule
                                                           AND cmo.ModRowStatus = 1
                                                           AND cmo.ModVisible = 1
                                                           AND cmo.ModIdModuleParent IS NULL /*IS DAD*/
                                                    INNER JOIN [dbo].CatRol               rol
                                                        ON rol.RolIdRol = rms.RmsIdRol
                                                    LEFT JOIN @TBSUBMODULES               TMP
                                                        ON TMP.ModIdModule = cmo.ModIdModule
                                                WHERE us.UsrEmail = @Username
                                                      AND us.UsrRowStatus = 1
                                                ORDER BY cmo.ModOrder
                                            
                       
                        -- obtener las cuentas a las que tiene acceso el usuario

                    
                                                SELECT   CONVERT(VARCHAR, ac.AccIdAccount) AS 'IdAccount',
                                                          ac.AccName AS 'AccountName' ,  
                                                        CASE
                                                             WHEN @VERIFYUSER != 0 THEN
                                                                 'Express'
                                                             ELSE
                                                                 ta.TacName
                                                         END  AS 'TacName', 
                                                        CONVERT(VARCHAR, ISNULL(ac.IdCustomer, 0))  AS 'IdCustomer',
                                                        ro.RolName 'RolName', 
                                                        ISNULL(ac.ImageProfile, 'N/D') AS  'ImageProfile',  
                                                        CONVERT(VARCHAR(1), ISNULL(ac.StarRating, 0)) AS 'StarRating',
                                                        IIF(ac.AccConfirm = 'C', '1', '0') AS 'VerifiedEmail',
                                                        CONVERT(VARCHAR, ISNULL(us.ChangePassword, 0)) AS 'ChangePassword',
                                                       CONVERT(VARCHAR, ISNULL(ro.RolAdminInternal, '0')) AS 'AdminInternal'
                                                FROM RegisterUser                         us
                                                    INNER JOIN [dbo].Person               pe
                                                        ON pe.PerIdPerson = us.UsrIdPerson
                                                           AND pe.PerRowStatus = 1
                                                    INNER JOIN [dbo].[RolByUserByAccount] rua
                                                        ON rua.RuaIdUser = us.UsrIdUser
                                                           AND rua.RuaRowStatus = 1
                                                    INNER JOIN [dbo].CatRol               ro
                                                        ON ro.RolIdRol = rua.RuaIdRol
                                                    INNER JOIN [dbo].Account              ac
                                                        ON ac.AccIdAccount = rua.RuaIdAccount
                                                           AND ac.AccRowStatus = 1
                                                    INNER JOIN [dbo].CatTypeAccount       ta
                                                        ON ta.TacIdTypeAccount = ac.AccIdTypeAccount
                                                WHERE us.UsrEmail = @Username
                                                      AND us.UsrRowStatus = 1
                                             
                        -- obtener los datos del perfil asociado al usuario 

                        -- MODIFICACIÓN 09/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
                        -- Determinar si ya ha aceptado los terminos y condiciones
                        DECLARE @ValTAC INT =
                                (
                                    SELECT [dbo].[FnValidateTermsAndConditions](@Username, 0, 1)
                                );

                        -- Valida el valor en la tabla; 1 = TRUE, si fuera 0 o NULL devuelve FALSE
                        DECLARE @TAC VARCHAR(5) = CASE
                                                      WHEN @ValTAC = 1 THEN
                                                          'TRUE'
                                                      ELSE
                                                          'FALSE'
                                                  END;
                        -- FIN MODIFICACIÓN

                       
                                                SELECT   pe.PerFirstName AS 'FirstName',
                                                         pe.PerLastName AS 'LastName',
														 pe.PerGender 'Gender',
                                                         CONVERT(VARCHAR, pe.PerBirthdate) AS 'Birthdate',
                                                         pe.PerIdentification AS 'Identification',
                                                         pe.PerNationality AS 'Nationality',
                                                         CONVERT(VARCHAR, us.UsrNickName) AS 'NickName', 
                                                       -- MODIFICACIÓN 01/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
                                                         CONVERT(VARCHAR, COALESCE(us.Phone, ' '))  AS 'Phone',
                                                         CONVERT(VARCHAR(1), ISNULL(us.VerifiedPhone, 'false')) AS 'VerifiedPhone',
                                                          @TAC AS 'TAC'
                                                -- FIN MODIFICACIÓN
                                                FROM RegisterUser           us
                                                    INNER JOIN [dbo].Person pe
                                                        ON pe.PerIdPerson = us.UsrIdPerson
                                                           AND pe.PerRowStatus = 1
                                                WHERE us.UsrEmail = @Username
                                                      AND us.UsrRowStatus = 1
                                          

                        -- MODIFICACIÓN 23/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
                        -- Variable para guardar el rol de express center del usuario
                        DECLARE @RolEXP NVARCHAR(MAX);

                        SET @RolEXP =
                        (
                            SELECT TOP 1
                                   cr.RolName
                            FROM RegisterUser                 ru
                                INNER JOIN RolByUserByAccount rb
                                    ON ru.UsrIdUser = rb.RuaIdUser
                                INNER JOIN CatRol             cr
                                    ON rb.RuaIdRol = cr.RolIdRol
                            WHERE ru.UsrEmail = @Username
                        );

                        IF (@RolEXP LIKE 'ADMINISTRACION%')
                        BEGIN
                            SET @RolEXP = N'Admin';
                        END;
                        ELSE
                        BEGIN
                            SET @RolEXP = N'Encargado';
                        END;
                        -- FIN MODIFICACIÓN

                        IF (@VERIFYUSER > 0)
                        BEGIN
                           
                                                
                                                    SELECT 
													        DescriptionOfClient AS 'Name',
                                                            ISNULL(ContactName, '') AS 'ContactName',
                                                            ISNULL(VPC.Phone, '') AS 'Phone',
                                                            ISNULL(Email, '') AS 'Email',
														    ISNULL(CONVERT(VARCHAR, TWS.IdTownship), '') AS 'IdTownship',
                                                            ISNULL(TWS.TownshipDescription, '') AS 'TownshipName',
                                                            ISNULL(CONVERT(VARCHAR, PRV.IdProvince), '') AS  'IdProvince',
                                                            ISNULL(PRV.ProvinceDescription, '') AS  'ProvinceName',
                                                            ISNULL(VPC.Address, '') AS  'Address',
                                                            ISNULL(TWS.HeaderCode, '') AS 'HeaderCode',
                                                            ISNULL(CONVERT(NVARCHAR(20), VPC.CodeOfReference), '') AS 'CodeOfReference',
                                                           -- MODIFICACIÓN 23/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
                                                            @RolEXP AS  'RolEXP'
                                                           -- FIN MODIFICACIÓN
                                                    FROM DeliveryBackOffice.dbo.VisitPointClient VPC
                                                        JOIN VisitPointByUser                    VPU
                                                            ON VPC.IdVisitPointClient = VPU.IdVisitPointClient
                                                               AND VPU.RowStatus = 1
                                                        JOIN RegisterUser                        ru
                                                            ON VPU.RegisterUserID = ru.UsrIdUser
                                                               AND ru.UsrRowStatus = 1
                                                        JOIN DeliveryBackOffice.dbo.Settlement   STL
                                                            ON VPC.IdSettlement = STL.IdSettlement
                                                        JOIN DeliveryBackOffice.dbo.Township     TWS
                                                            ON TWS.IdTownship = STL.IdTownship
                                                        JOIN DeliveryBackOffice.dbo.Province     PRV
                                                            ON PRV.IdProvince = TWS.IdProvince
                                                    WHERE IdKindOfVPClient = 1
                                                          AND ru.UsrEmail = @Username
                                                   
                             
                        END;

                      
                                                SELECT  200 AS 'IdResult' ,
												        @Token AS 'Token',
                                                        @JsonModules AS 'Modules' ,  
												        @JsonAccounts AS 'Accounts' ,
                                                      
                                                        CASE
                                                             WHEN @VERIFYUSER > 0 THEN
                                                                 @JsonProfile + ',' + @JsonProfileEXP
                                                             ELSE
                                                                 @JsonProfile
                                                         END AS 'Profile'
                                             
                        

						PRINT '@JsonModules'
						PRINT @JsonModules
						PRINT '@JsonAccounts'
						PRINT @JsonAccounts
						PRINT '@JsonProfile'
						PRINT @JsonProfile
						PRINT '@JsonProfileEXP'
						PRINT @JsonProfileEXP
                    END;
                    ELSE
                    BEGIN
                       
                                                SELECT  CONVERT(VARCHAR, IdResult) AS  'IdResult' ,
                                                         Message AS  'Message' 
                                                FROM #errormessage
                                                WHERE Id = 'Inactive'
                                      
                    END;

                END;
                ELSE
                BEGIN
                   
                        
                                            SELECT   CONVERT(VARCHAR, IdResult), 
											       '"Message":"'
                                                   AS Message 
                                            FROM #errormessage
                                            WHERE Id = 'PasswordExpired'
                                     
                   
                END;

            END;
            ELSE -- usuario bloqueado
            BEGIN
                IF ((@StatusRestrinct = 'BLOCKED'))
                BEGIN
                   
                     
                                            SELECT   CONVERT(VARCHAR, IdResult) AS 'IdResult',
											       'Message'
                                                   AS Message
                                            FROM #errormessage
                                            WHERE Id = 'Blocked'
                                         
                END;
                ELSE -- culaquier otro estado diferente de "ACTIVE" y "BLOCKED"
                BEGIN
                   
                                            SELECT  CONVERT(VARCHAR, IdResult) AS 'IdResult',  
                                                    Message  AS 'Message'
                                            FROM #errormessage
                                            WHERE Id = 'Inactive'
                                        
                END;
            END;
        END;
        ELSE
        BEGIN
          
                                    SELECT   CONVERT(VARCHAR, IdResult) AS 'IdResult',
									       'Message' AS Message
                                    FROM #errormessage
                                    WHERE Id = 'Confirmation'
                                   
        END;
    END;
    ELSE -- usuario o contraseña invalido
    BEGIN

        -- incrementar en 1 los intentos fallidos de inicio de sesion 

        UPDATE [dbo].UserSystemRestriction
        SET UstRetries = (UstRetries + 1)
          , UstStatus = (IIF(UstRetries + 1 >= UstAccessRetries, 'BLOCKED', 'ACTIVE'))
        FROM [dbo].RegisterUser                   usr
            LEFT JOIN [dbo].UserSystemRestriction res
                ON res.UstIdUser = usr.UsrIdUser
                   AND res.UstIdSystem = @IdSystem
        WHERE usr.UsrEmail = @Username;

        -- retornar mensaje de error
        
                             SELECT  CONVERT(VARCHAR, IdResult) AS 'IdResult',
							 Message AS 'Message' 
                             FROM #errormessage
                             WHERE Id = 'Invalid'
                         
    END;

    -- destruir tablas temporales

    IF OBJECT_ID('tempdb.dbo.#User', 'U') IS NOT NULL
        DROP TABLE #User;
    IF OBJECT_ID('tempdb.dbo.#errormessage', 'U') IS NOT NULL
        DROP TABLE #errormessage;

    -- retornar resultado en formato json

  ---  SELECT ('[{' + @jsonResult + ']') jsonResult;




END

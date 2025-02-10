
-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2020-12-30>
-- Update date: <2021-01-27>
-- Description:	<Login Portal Web>
-- =============================================
-- Author:		<Jerson Ochoa>
-- Update date: <2023-03-02>
-- Description:	<Validation for visit point status>
-- =============================================
-- =============================================
-- Author:		<Cristian Suazo>
-- Update date: <2025-02-05>
-- Description:	<Se pasa a tablas el json para contruirlo de lado del api, proyecto compatibilidad de bases de datos>
-- =============================================

CREATE PROCEDURE [dbo].[spws_get_login_new]
    -- Add the parameters for the stored procedure here
    @Username VARCHAR(200),
    @Password VARCHAR(200),
    @IP VARCHAR(30),
    @IdSystem INT = 1,
    @CountryId VARCHAR(2) = 'GT'
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
    DECLARE @CODPercentage NVARCHAR(10);


    DECLARE @CountryIdOrigin NVARCHAR(3) = (
                                               SELECT TOP 1
                                                   CASE
                                                       WHEN LEFT(UsrCurrency, 2) = 'HN' THEN
                                                           'HN'
                                                       ELSE
                                                           'GT'
                                                   END
                                               FROM dbo.RegisterUser WITH (NOLOCK)
                                               WHERE UsrEmail = @Username
                                           );




    DECLARE @CodeIsoMoney NVARCHAR(3) = (
                                            SELECT TOP 1
                                                CodeISO
                                            FROM [dbo].[CatCurrencyCOD]
                                            WHERE CodeISO LIKE '%' + @CountryId + '%'
                                        );

    SET @CODPercentage =
    (
        Select CONVERT(VARCHAR, ISNULL([Value], 0))
        From dbo.ConfigParams
        WHERE [Name] = 'MinCODCommissionAmount'
              AND ISNULL(IdCountry, 'GT') LIKE '%' + @CountryId + '%'
    )

    --VALIDAR EL TIPO DE USUARIO QUE INICIA SESIÓN.INI
    DECLARE @VERIFYUSER AS INT = 0;
    SET @VERIFYUSER =
    (
        SELECT COUNT(iu.IdEmployee)
        FROM RegisterUser ru WITH (NOLOCK)
            INNER JOIN InternalUser iu WITH (NOLOCK)
                ON ru.UsrIdUser = iu.RegisterUserID
        WHERE ru.UsrEmail = @Username
              AND ru.UsrRowStatus = 1
    );

    --VALIDAR EL TIPO DE USUARIO QUE INICIA SESIÓN.FIN
    PRINT 'TEST1';

    SELECT ISNULL(res.UstStatus, 'N/A') UstStatus,
           ISNULL(usr.UsrRowStatus, 0) UsrStatus,
           ISNULL(usr.UsrIdUser, 0) IdUser,
           ISNULL(ac.AccConfirm, 'N') StatusAccount,
           (CASE
                WHEN ISNULL(usr.ChangePassword, 0) = 1
                     AND ISNULL(usr.UsrPasswordExpiration, CAST(GETDATE() AS DATE)) <= CAST(GETDATE() AS DATE) THEN
                    1
                ELSE
                    0
            END
           ) PasswordExpired
    INTO #User
    FROM [dbo].RegisterUser usr WITH (NOLOCK)
        INNER JOIN [dbo].RolByUserBySystem rus WITH (NOLOCK)
            ON rus.RusIdUser = usr.UsrIdUser
               AND rus.RusIdSystem = @IdSystem
        LEFT JOIN [dbo].UserSystemRestriction res WITH (NOLOCK)
            ON res.UstIdUser = rus.RusIdUser
               AND res.UstIdSystem = rus.RusIdSystem
        LEFT JOIN [dbo].[RolByUserByAccount] rua WITH (NOLOCK)
            ON rua.RuaIdUser = usr.UsrIdUser
        INNER JOIN [dbo].Account ac WITH (NOLOCK)
            ON ac.AccIdAccount = rua.RuaIdAccount
    WHERE usr.UsrEmail = @Username
          AND usr.UsrLastPassword = @Password
          AND rua.RuaRowStatus = 1
          AND ac.AccRowStatus = 1;
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
               'Usuario de Express Center' AS Message,
               'UserEXC' AS Id
        UNION
        SELECT 500 AS IdResult,
               'Usuario inactivo' AS Message,
               'Inactive' AS Id
        UNION
        SELECT 500 AS IdResult,
               'Contraseña expirada' AS Message,
               'PasswordExpired' AS Id
        UNION
        SELECT 400 AS IdResult,
               'Cuenta pendiente de confirmación, se envió un nuevo link a su correo electrónico registrado, para poder confirmar su cuenta.' AS Message,
               'Confirmation' AS Id
        UNION
        SELECT 500 AS IdResult,
               'El usuario pertenece a otro país. Por favor, inicia sesión con una cuenta del mismo país al que ingresaste o contacta a soporte.' AS Message,
               'WrongCountry' AS Id
    ) AS errror;
    IF
    (
        SELECT COUNT(*) FROM #User
    ) > 0 -- si encuentra registros quiere decir que hay conicidencia en usuario y contraseña
    BEGIN
        --No permitir el logueo de un Express Center
        IF (@VERIFYUSER = 0)
        BEGIN
            -- Validación de visit point para express center
            PRINT 'TEST3';
            IF (@VERIFYUSER > 0)
            BEGIN
                SET @VisitPointValid =
                (
                    SELECT [VPC].[StatusClient]
                    FROM [dbo].[RegisterUser] RU WITH (NOLOCK)
                        INNER JOIN [dbo].[VisitPointByUser] VP WITH (NOLOCK)
                            ON [RU].[UsrIdUser] = [VP].[RegisterUserID]
                        INNER JOIN [dbo].[VisitPointClient] VPC WITH (NOLOCK)
                            ON [VP].[IdVisitPointClient] = [VPC].[IdVisitPointClient]
                    WHERE [RU].[UsrEmail] = @Username
                          AND VP.RowStatus = 1
                );

                IF (@VisitPointValid = 0)
                BEGIN

                    SELECT CONVERT(VARCHAR, IdResult) AS IdResult,
                           Message AS Message
                    FROM #errormessage
                    WHERE Id = 'Inactive'
                    RETURN;
                END;

            END;
            PRINT 'TEST4';

            -- validar que el usuario no este bloqueado 

            SET @StatusRestrinct =
            (
                SELECT TOP 1 UPPER(UstStatus) FROM #User
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
            IF @CountryIdOrigin = @CountryId
            BEGIN
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
                                    =   (
                                            SELECT CONVERT(
                                                              VARCHAR(32),
                                                              HASHBYTES(
                                                                           'MD5',
                                                                           CONCAT(@Username, @Password, SYSDATETIME())
                                                                       ),
                                                              2
                                                          ) AS token
                                        );
                                IF
                                (
                                    SELECT COUNT(*) FROM [dbo].TokenLog tkn WHERE tkn.TknIdToken = @Token
                                ) = 0 --si el token no exite crearlo 
                                BEGIN

                                    PRINT 'TEST6';
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
                                    (@Token, @IdUser, @IdSystem, 0, 0, 'GT', @IP, 1, @Token, GETDATE(), NULL, NULL);
                                END;

                                PRINT 'TEST7';
                                DECLARE @JsonModules NVARCHAR(MAX);
                                DECLARE @JsonAccounts NVARCHAR(MAX);
                                DECLARE @JsonProfile NVARCHAR(MAX);
                                DECLARE @JsonProfileEXP NVARCHAR(MAX) = N'';

                                -- obtener modulos a los que tiene acceso el usuario logueado
                                /*tabla temporal ModIdModule*/
                                DECLARE @TOTALSUBMODULES INT = 0,
                                        @ITERATORSUBMODULES INT = 1;

								DECLARE @TBSUBMODULESID TABLE
                                (
                                    ModIdModule INT
                                );

                                INSERT INTO @TBSUBMODULESID
                                (
                                    ModIdModule
                                )
                                SELECT cmo.ModIdModule
                                FROM RegisterUser us WITH (NOLOCK)
                                    INNER JOIN [dbo].[RolByUserByAccount] rua WITH (NOLOCK)
                                        ON rua.RuaIdUser = us.UsrIdUser
                                    INNER JOIN dbo.RolByModuleBySystem rms WITH (NOLOCK)
                                        ON rms.RmsIdRol = rua.RuaIdRol
                                    INNER JOIN [dbo].CatModule cmo WITH (NOLOCK)
                                        ON cmo.ModIdModule = rms.RmsIdModule
                                    INNER JOIN [dbo].CatRol rol WITH (NOLOCK)
                                        ON rol.RolIdRol = rms.RmsIdRol
                                WHERE us.UsrEmail = @Username
                                      AND rms.RmsRowStatus = 1
                                      AND rua.RuaRowStatus = 1
                                      AND cmo.ModRowStatus = 1
                                      AND cmo.ModVisible = 1
                                      AND us.UsrRowStatus = 1
                                      AND cmo.ModIdModuleParent IS NULL
                                      AND cmo.ModIdModule IN (
                                                                 SELECT ModIdModuleParent FROM [dbo].CatModule WITH (NOLOCK)
                                                             )

								DECLARE @TBSUBMODULES TABLE
                                (
                                    ModIdModule INT,
									ModIdModuleParent INT,
                                    Module NVARCHAR(100),
                                    Icon NVARCHAR(100),
                                    [Path] NVARCHAR(150)
                                )

								INSERT INTO @TBSUBMODULES
                                (
                                    ModIdModule,
									ModIdModuleParent,
                                    Module,
                                    Icon,
                                    [Path]
                                )
								SELECT cmo.ModIdModule,
									   cmo.ModIdModuleParent,
									   cmo.ModName,
									   cmo.ModMetadata,
                                       cmo.ModPath
								FROM [dbo].CatModule cmo WITH(NOLOCK)  
                                    WHERE cmo.ModIdModuleParent IN (SELECT ModIdModule FROM @TBSUBMODULESID)

                                /*END SUBMODULOES*/
								SELECT 200 AS IdResult,
									   'Informacion encontrada con exito' AS [Message],
									   @Token AS Token,
									   @CodeIsoMoney AS Currency

                                SELECT cmo.ModIdModule,
									   cmo.ModName AS [Name],
                                       cmo.ModMetadata AS [Icon],
                                       cmo.ModPath AS [Path],
                                       CAST(ISNULL(rms.RmsModuleMenu, 1) AS NVARCHAR) AS [MenuId],
                                       CAST(ISNULL(cmo.ModGroup, 0) AS NVARCHAR) AS [GroupId],
                                       CAST(ISNULL(rms.RmsHasNewFunction, 0) AS NVARCHAR) AS [NewFunction],
                                       rol.RolName AS [Rol]
									   --TMP.ModIdModuleParent AS IdModuleDad,
            --                           TMP.ModIdModule,
            --                           TMP.Module,
            --                           TMP.Icon,
            --                           TMP.[Path]
                                FROM RegisterUser us WITH (NOLOCK)
                                    INNER JOIN [dbo].[RolByUserByAccount] rua WITH (NOLOCK)
                                        ON rua.RuaIdUser = us.UsrIdUser
                                    INNER JOIN dbo.RolByModuleBySystem rms WITH (NOLOCK)
                                        ON rms.RmsIdRol = rua.RuaIdRol
                                    INNER JOIN [dbo].CatModule cmo WITH (NOLOCK)
                                        ON cmo.ModIdModule = rms.RmsIdModule
                                           AND cmo.ModIdModuleParent IS NULL -- IS DAD
                                    INNER JOIN [dbo].CatRol rol WITH (NOLOCK)
                                        ON rol.RolIdRol = rms.RmsIdRol
                                    --LEFT JOIN @TBSUBMODULES TMP
                                    --    ON TMP.ModIdModuleParent = cmo.ModIdModule
                                WHERE us.UsrEmail = @Username
                                      AND rua.RuaRowStatus = 1
                                      AND us.UsrRowStatus = 1
                                      AND rms.RmsRowStatus = 1
                                      AND cmo.ModRowStatus = 1
                                      AND cmo.ModVisible = 1
                                ORDER BY cmo.ModOrder

								SELECT ModIdModuleParent AS ModuleDad, 
									ModIdModule,									
                                    Module,
                                    Icon,
                                    [Path]
								FROM @TBSUBMODULES

                                -- obtener las cuentas a las que tiene acceso el usuario

                                SELECT CONVERT(VARCHAR, ac.AccIdAccount) AS IdAccount,
                                       ac.AccName AS AccountName,
                                       CASE
                                           WHEN @VERIFYUSER != 0 THEN
                                               'Express'
                                           ELSE
                                               ta.TacName
                                       END AS TacName,
                                       CONVERT(VARCHAR, ISNULL(ac.IdCustomer, 0)) AS IdCustomer,
                                       @CODPercentage AS CODPercentage,
                                       (
                                           SELECT TOP 1
                                               CONVERT(VARCHAR, ISNULL(InsuranceRate, 0))
                                           FROM dbo.RateHeader WITH (NOLOCK)
                                           WHERE RheId IN (
                                                              select RbcIdRate
                                                              from dbo.RatebyCustomer WITH (NOLOCK)
                                                              where RbcIdCustomer = ac.IdCustomer
                                                          )
                                       ) AS InsuranceRate,
                                       (
                                           SELECT TOP 1
                                               CONVERT(VARCHAR, ISNULL(InsuranceExempt, 0))
                                           FROM dbo.RateHeader WITH (NOLOCK)
                                           WHERE RheId IN (
                                                              select RbcIdRate
                                                              from dbo.RatebyCustomer WITH (NOLOCK)
                                                              where RbcIdCustomer = ac.IdCustomer
                                                          )
                                       ) AS InsuranceExempt,
                                       (
                                           SELECT TOP 1
                                               CONVERT(VARCHAR, ISNULL(CollectRate, 0))
                                           FROM dbo.RateHeader WITH (NOLOCK)
                                           WHERE RheId IN (
                                                              select RbcIdRate
                                                              from dbo.RatebyCustomer WITH (NOLOCK)
                                                              where RbcIdCustomer = ac.IdCustomer
                                                          )
                                       ) AS CashOnDeliveryCharge,
                                       ro.RolName AS RolName,
                                       ISNULL(ac.ImageProfile, '') AS ImageProfile,
                                       CONVERT(VARCHAR(1), ISNULL(ac.StarRating, 0)) AS StarRating,
                                       IIF(ac.AccConfirm = 'C', '1', '0') AS VerifiedEmail,
                                       CONVERT(VARCHAR, ISNULL(us.ChangePassword, 0)) AS ChangePassword,
                                       CONVERT(VARCHAR, ISNULL(ro.RolAdminInternal, '0')) AS AdminInternal
                                FROM RegisterUser us WITH (NOLOCK)
                                    INNER JOIN [dbo].Person pe WITH (NOLOCK)
                                        ON pe.PerIdPerson = us.UsrIdPerson
                                    INNER JOIN [dbo].[RolByUserByAccount] rua WITH (NOLOCK)
                                        ON rua.RuaIdUser = us.UsrIdUser
                                    INNER JOIN [dbo].CatRol ro WITH (NOLOCK)
                                        ON ro.RolIdRol = rua.RuaIdRol
                                    INNER JOIN [dbo].Account ac WITH (NOLOCK)
                                        ON ac.AccIdAccount = rua.RuaIdAccount
                                    INNER JOIN [dbo].CatTypeAccount ta WITH (NOLOCK)
                                        ON ta.TacIdTypeAccount = ac.AccIdTypeAccount
                                WHERE us.UsrEmail = @Username
                                      AND pe.PerRowStatus = 1
                                      AND us.UsrRowStatus = 1
                                      AND rua.RuaRowStatus = 1
                                      AND ac.AccRowStatus = 1;



                                -- obtener los datos del perfil asociado al usuario 

                                -- MODIFICACIÓN 09/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
                                -- Determinar si ya ha aceptado los terminos y condiciones
                                DECLARE @ValTAC INT
                                    =   (
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


                                SELECT pe.PerFirstName AS FirstName,
                                       pe.PerLastName AS LastName,
                                       pe.PerGender AS Gender,
                                       CONVERT(VARCHAR, pe.PerBirthdate) AS Birthdate,
                                       pe.PerIdentification AS Identification,
                                       pe.PerNationality AS Nationality,
                                       CONVERT(VARCHAR, us.UsrNickName) AS NickName,
                                       -- MODIFICACIÓN 01/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
                                       ISNULL(us.PrefixCallingCode, '') AS PrefixCallingCode,
                                       CONVERT(VARCHAR, COALESCE(us.Phone, ' ')) AS Phone,
                                       CONVERT(VARCHAR(1), ISNULL(us.VerifiedPhone, 'false')) AS VerifiedPhone,
                                       @TAC AS TAC
                                -- FIN MODIFICACIÓN
                                FROM RegisterUser us WITH (NOLOCK)
                                    INNER JOIN [dbo].Person pe WITH (NOLOCK)
                                        ON pe.PerIdPerson = us.UsrIdPerson
                                WHERE us.UsrEmail = @Username
                                      AND pe.PerRowStatus = 1
                                      AND us.UsrRowStatus = 1

                                RETURN;

                                -- MODIFICACIÓN 23/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
                                -- Variable para guardar el rol de express center del usuario
                                DECLARE @RolEXP NVARCHAR(MAX);

                                SET @RolEXP =
                                (
                                    SELECT TOP 1
                                        cr.RolName
                                    FROM RegisterUser ru WITH (NOLOCK)
                                        INNER JOIN RolByUserByAccount rb WITH (NOLOCK)
                                            ON ru.UsrIdUser = rb.RuaIdUser
                                        INNER JOIN CatRol cr WITH (NOLOCK)
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

                                    SELECT DescriptionOfClient AS Name,
                                           ISNULL(ContactName, '') AS ContactName,
                                           ISNULL(ru.PrefixCallingCode, '') AS PrefixCallingCode,
                                           ISNULL(VPC.Phone, '') AS Phone,
                                           ISNULL(Email, '') AS Email,
                                           ISNULL(CONVERT(VARCHAR, TWS.IdTownship), '') AS IdTownship,
                                           ISNULL(TWS.TownshipDescription, '') AS TownshipName,
                                           ISNULL(CONVERT(VARCHAR, PRV.IdProvince), '') AS IdProvince,
                                           ISNULL(PRV.ProvinceDescription, '') AS ProvinceName,
                                           ISNULL(VPC.Address, '') AS [Address],
                                           ISNULL(TWS.HeaderCode, '') AS HeaderCode,
                                           ISNULL(CONVERT(NVARCHAR(20), VPC.CodeOfReference), '') AS CodeOfReference,
                                           -- MODIFICACIÓN 23/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
                                           @RolEXP AS RolEXP
                                    -- FIN MODIFICACIÓN
                                    FROM DeliveryBackOffice.dbo.VisitPointClient VPC WITH (NOLOCK)
                                        INNER JOIN VisitPointByUser VPU WITH (NOLOCK)
                                            ON VPC.IdVisitPointClient = VPU.IdVisitPointClient
                                        INNER JOIN RegisterUser ru WITH (NOLOCK)
                                            ON VPU.RegisterUserID = ru.UsrIdUser
                                        INNER JOIN DeliveryBackOffice.dbo.Settlement STL WITH (NOLOCK)
                                            ON VPC.IdSettlement = STL.IdSettlement
                                        INNER JOIN DeliveryBackOffice.dbo.Township TWS WITH (NOLOCK)
                                            ON TWS.IdTownship = STL.IdTownship
                                        INNER JOIN DeliveryBackOffice.dbo.Province PRV WITH (NOLOCK)
                                            ON PRV.IdProvince = TWS.IdProvince
                                    WHERE IdKindOfVPClient = 1
                                          AND VPU.RowStatus = 1
                                          AND ru.UsrRowStatus = 1
                                          AND ru.UsrEmail = @Username

                                END;

                            END;
                            ELSE
                            BEGIN

                                SELECT CONVERT(VARCHAR, IdResult) AS IdResult,
                                       Message AS [Message]
                                FROM #errormessage
                                WHERE Id = 'Inactive'

                            END;

                        END;
                        ELSE
                        BEGIN

                            SELECT CONVERT(VARCHAR, IdResult) AS IdResult,
                                   Message
                            FROM #errormessage
                            WHERE Id = 'PasswordExpired'
                            FOR XML PATH(''), TYPE

                        END;

                    END;
                    ELSE -- usuario bloqueado
                    BEGIN
                        IF ((@StatusRestrinct = 'BLOCKED'))
                        BEGIN

                            SELECT CONVERT(VARCHAR, IdResult) AS IdResult,
                                   Message
                            FROM #errormessage
                            WHERE Id = 'Blocked'

                        END;
                        ELSE -- culaquier otro estado diferente de "ACTIVE" y "BLOCKED"
                        BEGIN

                            SELECT CONVERT(VARCHAR, IdResult) AS IdResult,
                                   Message
                            FROM #errormessage
                            WHERE Id = 'Inactive'

                        END;
                    END;
                END;
                ELSE
                BEGIN

                    SELECT CONVERT(VARCHAR, IdResult) AS IdResult,
                           Message
                    FROM #errormessage
                    WHERE Id = 'Confirmation'

                END;
            END;
            ELSE
            BEGIN
                SELECT CONVERT(VARCHAR, IdResult) AS 'IdResult',
                       Message
                FROM #errormessage
                WHERE Id = 'WrongCountry'
            END;
        END;
        ELSE
        BEGIN

            SELECT CONVERT(VARCHAR, IdResult) AS IdResult,
                   Message
            FROM #errormessage
            WHERE Id = 'UserEXC'

        END;
    END;
    ELSE -- usuario o contraseña invalido
    BEGIN

        -- incrementar en 1 los intentos fallidos de inicio de sesion 

        UPDATE [dbo].UserSystemRestriction
        SET UstRetries = (UstRetries + 1),
            UstStatus = (IIF(UstRetries + 1 >= UstAccessRetries, 'BLOCKED', 'ACTIVE'))
        FROM [dbo].RegisterUser usr WITH (NOLOCK)
            LEFT JOIN [dbo].UserSystemRestriction res WITH (NOLOCK)
                ON res.UstIdUser = usr.UsrIdUser
                   AND res.UstIdSystem = @IdSystem
        WHERE usr.UsrEmail = @Username;


        SELECT CONVERT(VARCHAR, IdResult) AS IdResult,
               Message
        FROM #errormessage
        WHERE Id = 'Invalid'

    END;

    -- destruir tablas temporales

    IF OBJECT_ID('tempdb.dbo.#User', 'U') IS NOT NULL
        DROP TABLE #User;
    IF OBJECT_ID('tempdb.dbo.#errormessage', 'U') IS NOT NULL
        DROP TABLE #errormessage;

-- retornar resultado en formato json

--SELECT ('' + @jsonResult + '') jsonResult;
END
-- =============================================
-- Author:		<Michael Espinoza>
-- Create date: <2021-08-24>
-- Update date: <2021-08-24>
-- Description:	<Login Portal Web Corporativo>
-- =============================================
-- =============================================
-- Author:		<Andres, Ruiz>
-- Update date: <2022-06-28>
-- Description:	< Devolver datos de COD de punto de visita sobre datos de cliente, si hubiese >
-- =============================================


CREATE PROCEDURE [dbo].[spws_GetCorporateLogIn]
-- Add the parameters for the stored procedure here
@UserCode BIGINT = 0,
@UserName VARCHAR(200), 
@Password VARCHAR(200), 
@IP       VARCHAR(30) = '', 
@IdSystem INT = 1
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

		--VALIDAR EL TIPO DE USUARIO QUE INICIA SESIÓN.INI
										DECLARE @VERIFYUSER AS INT = 0;
										SET @VERIFYUSER = (SELECT COUNT(iu.Username)  FROM DeliveryBackOffice.[dbo].RegisterUser ru 
                        INNER JOIN DeliveryBackOffice.[dbo].InternalUser iu ON ru.UsrIdUser = iu.RegisterUserID
                        WHERE iu.Username=@UserName
                        AND ru.UsrRowStatus = 1)

												
         --VALIDAR EL TIPO DE USUARIO QUE INICIA SESIÓN.FIN

        SELECT ISNULL(res.UstStatus, 'N/A') UstStatus, 
               ISNULL(usr.UsrRowStatus, 0) UsrStatus, 
               ISNULL(usr.UsrIdUser, 0) IdUser, 
               ISNULL(ac.AccConfirm, 'N') StatusAccount
        INTO #User
        FROM DeliveryBackOffice.[dbo].RegisterUser usr
			       INNER JOIN DeliveryBackOffice.dbo.InternalUser iu ON iu.RegisterUserID = usr.UsrIdUser 
             INNER JOIN DeliveryBackOffice.[dbo].RolByUserBySystem rus ON rus.RusIdUser = usr.UsrIdUser
                                                       AND rus.RusIdSystem = @IdSystem
             LEFT JOIN DeliveryBackOffice.[dbo].UserSystemRestriction res ON res.UstIdUser = rus.RusIdUser
                                                          AND res.UstIdSystem = rus.RusIdSystem
             LEFT JOIN DeliveryBackOffice.[dbo].[RolByUserByAccount] rua ON rua.RuaIdUser = usr.UsrIdUser
                                                         AND rua.RuaRowStatus = 1
             INNER JOIN DeliveryBackOffice.[dbo].Account ac ON ac.AccIdAccount = rua.RuaIdAccount
                                            AND ac.AccRowStatus = 1
        WHERE iu.IdUser=@UserCode AND iu.Username=@UserName
              AND usr.UsrLastPassword = @Password;
        -- insertar en tabla temporal posbibles mensajes de error

        IF OBJECT_ID('tempdb.dbo.#errormessage', 'U') IS NOT NULL
            DROP TABLE #errormessage;
        SELECT *
        INTO #errormessage
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
										DECLARE @JsonProfileEXP NVARCHAR(MAX) = '';

										

                                        -- obtener modulos a los que tiene acceso el usuario logueado
										/*tabla temporal ModIdModule*/
										DECLARE @TOTALSUBMODULES INT = 0, @ITERATORSUBMODULES INT = 1;
										DECLARE @TBSUBMODULES TABLE (ITERATOR int Identity(1,1), ModIdModule INT , SUBMODULES VARCHAR(MAX));
										SELECT  @TOTALSUBMODULES = COUNT(cmo.ModIdModule) FROM DeliveryBackOffice.[dbo].RegisterUser us
                                                 INNER JOIN DeliveryBackOffice.[dbo].[RolByUserByAccount] rua ON rua.RuaIdUser = us.UsrIdUser
                                                                                              AND rua.RuaRowStatus = 1
                                                 INNER JOIN DeliveryBackOffice.[dbo].RolByModuleBySystem rms ON rms.RmsIdRol = rua.RuaIdRol
                                                          AND rms.RmsRowStatus = 1
                                                 INNER JOIN DeliveryBackOffice.[dbo].CatModule cmo ON cmo.ModIdModule = rms.RmsIdModule
                                                                                   AND cmo.ModRowStatus = 1
                                                                                   AND cmo.ModVisible = 1
																				   AND cmo.ModIdModuleParent IS NOT NULL
                                                 INNER JOIN DeliveryBackOffice.[dbo].CatRol rol ON rol.RolIdRol = rms.RmsIdRol
                                                 INNER JOIN DeliveryBackOffice.dbo.InternalUser iu ON iu.RegisterUserID = us.UsrIdUser
                                            WHERE iu.UserName = @UserName AND iu.IdUser=@UserCode
                                                  AND iu.RowStatus = 1;
										
										IF (@TOTALSUBMODULES) > 0
										BEGIN /*PARENT LIST*/
											INSERT  INTO  @TBSUBMODULES (ModIdModule)
											SELECT cmo.ModIdModule  FROM DeliveryBackOffice.[dbo].RegisterUser us
                                                 INNER JOIN DeliveryBackOffice.[dbo].[RolByUserByAccount] rua ON rua.RuaIdUser = us.UsrIdUser
                                                                                              AND rua.RuaRowStatus = 1
                                                 INNER JOIN DeliveryBackOffice.[dbo].RolByModuleBySystem rms ON rms.RmsIdRol = rua.RuaIdRol
                                                          AND rms.RmsRowStatus = 1
                                                 INNER JOIN DeliveryBackOffice.[dbo].CatModule cmo ON cmo.ModIdModule = rms.RmsIdModule
                                                                                   AND cmo.ModRowStatus = 1
                                                                                   AND cmo.ModVisible = 1
																				   AND cmo.ModIdModuleParent IS NULL
																				   AND cmo.ModIdModule in (
																				   select ModIdModuleParent from DeliveryBackOffice.[dbo].CatModule 
																				   )
                                                 INNER JOIN DeliveryBackOffice.[dbo].CatRol rol ON rol.RolIdRol = rms.RmsIdRol
                                            INNER JOIN DeliveryBackOffice.dbo.InternalUser iu ON iu.RegisterUserID = us.UsrIdUser
                                            WHERE iu.UserName = @UserName AND iu.IdUser=@UserCode
                                                  AND iu.RowStatus = 1;
												
											SELECT @TOTALSUBMODULES = COUNT(ModIdModule) FROM @TBSUBMODULES
											
										END 
										/*INSERT SUBMODULES*/
										WHILE @TOTALSUBMODULES > 0
										BEGIN 
										    DECLARE @CHILDSMD VARCHAR(MAX) = '', @CHILDSMENU INT = 0,  @CHILDSMENU2 INT = 1; 
											DECLARE @TBSUBMODULES2 TABLE (ITERATOR2 int Identity(1,1), ModIdModuleDAD INT ,  ModIdModuleCHILD INT);
									        
										--	IF (@VERIFYUSER  > 0 )
											--BEGIN
											
											INSERT INTO @TBSUBMODULES2 (ModIdModuleDAD, ModIdModuleCHILD)											
										   SELECT (SELECT TMP.ModIdModule FROM @TBSUBMODULES AS TMP WHERE TMP.ITERATOR = @ITERATORSUBMODULES) AS ModIdModuleDAD , cmo.ModIdModule AS ModIdModuleCHILD  
										   FROM RegisterUser us
                                                 INNER JOIN [dbo].[RolByUserByAccount] rua ON rua.RuaIdUser = us.UsrIdUser
                                                                                              AND rua.RuaRowStatus = 1
                                                 INNER JOIN dbo.RolByModuleBySystem rms ON rms.RmsIdRol = rua.RuaIdRol
                                                          AND rms.RmsRowStatus = 1
                                                 INNER JOIN [dbo].CatModule cmo ON cmo.ModIdModule = rms.RmsIdModule
                                                                                   AND cmo.ModRowStatus = 1
                                                                                   AND cmo.ModVisible = 1
																				  -- AND 
                                                 INNER JOIN [dbo].CatRol rol ON rol.RolIdRol = rms.RmsIdRol
                                            INNER JOIN DeliveryBackOffice.dbo.InternalUser iu ON iu.RegisterUserID = us.UsrIdUser
                                            WHERE iu.UserName = @UserName and iu.IdUser=@UserCode
                                                  AND iu.RowStatus = 1 --order by cmo.ModOrder
												  AND cmo.ModIdModuleParent = (SELECT TMP.ModIdModule FROM @TBSUBMODULES AS TMP WHERE TMP.ITERATOR = @ITERATORSUBMODULES)
										
											--END
										--	ELSE 
										--	BEGIN
										--	PRINT 'VERIFYUSER  = 0 [USUARIO INDIVIDUAL]';
										--INSERT INTO @TBSUBMODULES2 (ModIdModuleDAD, ModIdModuleCHILD)											
										--   SELECT (SELECT TMP.ModIdModule FROM @TBSUBMODULES AS TMP WHERE TMP.ITERATOR = @ITERATORSUBMODULES) AS ModIdModuleDAD , cmo.ModIdModule AS ModIdModuleCHILD  
										--   FROM /*RegisterUser us
          --                                       INNER JOIN [dbo].[RolByUserByAccount] rua ON rua.RuaIdUser = us.UsrIdUser
          --                                                                                    AND rua.RuaRowStatus = 1
          --                                       INNER JOIN dbo.RolByModuleBySystem rms ON rms.RmsIdRol = rua.RuaIdRol
          --                                                AND rms.RmsRowStatus = 1
          --                                       INNER JOIN */[dbo].CatModule cmo /*ON cmo.ModIdModule = rms.RmsIdModule
          --                                                                         AND cmo.ModRowStatus = 1
          --                                                                         AND cmo.ModVisible = 1
										--										   AND */
          --                                       --INNER JOIN [dbo].CatRol rol ON rol.RolIdRol = rms.RmsIdRol
          --                                  WHERE /*us.UsrEmail = @UserName
          --                                        AND us.UsrRowStatus = 1 order by cmo.ModOrder*/
										--		  cmo.ModIdModuleParent = (SELECT TMP.ModIdModule FROM @TBSUBMODULES AS TMP WHERE TMP.ITERATOR = @ITERATORSUBMODULES)
												  
										--		  ;


										--	END
											
											SELECT @CHILDSMENU = COUNT(1) FROM @TBSUBMODULES2
											PRINT @CHILDSMENU
											WHILE @CHILDSMENU > 0
											BEGIN 
												SELECT @CHILDSMD = @CHILDSMD  + ' {"Module":"' + cmo.ModName + '",' + '"Icon":"' + cmo.ModMetadata + '",' + '"Path":"' + cmo.ModPath + '"},'
                                            FROM /*RegisterUser us
                                                 INNER JOIN [dbo].[RolByUserByAccount] rua ON rua.RuaIdUser = us.UsrIdUser
                                                                                              AND rua.RuaRowStatus = 1
                                                 INNER JOIN dbo.RolByModuleBySystem rms ON rms.RmsIdRol = rua.RuaIdRol
                                                          AND rms.RmsRowStatus = 1
                                                 INNER JOIN */[dbo].CatModule cmo --ON cmo.ModIdModule = rms.RmsIdModule
                                                                                   --AND cmo.ModRowStatus = 1
                                                                                   --AND cmo.ModVisible = 1
																				   --AND cmo.ModIdModuleParent IS NOT NULL
                                                 --INNER JOIN [dbo].CatRol rol ON rol.RolIdRol = rms.RmsIdRol
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
                                            INNER JOIN DeliveryBackOffice.dbo.InternalUser iu ON iu.RegisterUserID = us.UsrIdUser
                                            WHERE iu.UserName = @UserName AND iu.IdUser=@UserCode order by cmo.ModOrder FOR XML PATH(''), TYPE
                                        ).value('.', 'varchar(max)'), 1, 1, '')
                                        );
                                        
									
										-- obtener las cuentas a las que tiene acceso el usuario


                                        SET @JsonAccounts =
                                        (
                                            SELECT STUFF(
                                        (
                                            SELECT ',{"IdAccount":"' + CONVERT(VARCHAR, ac.AccIdAccount) + '",' + '"AccountName":"' + ac.AccName + '",' + '"TacName":"' + ta.TacName  + '",' + '"IdCustomer":"' + CONVERT(VARCHAR, ISNULL(ac.IdCustomer, 0)) + '"' + '}'
                                            FROM DeliveryBackOffice.dbo.RegisterUser us
                                                 INNER JOIN DeliveryBackOffice.dbo.Person pe ON pe.PerIdPerson = us.UsrIdPerson
                                                                               AND pe.PerRowStatus = 1
                                                 INNER JOIN DeliveryBackOffice.dbo.[RolByUserByAccount] rua ON rua.RuaIdUser = us.UsrIdUser
                                                                                              AND rua.RuaRowStatus = 1
                                                 INNER JOIN DeliveryBackOffice.dbo.CatRol ro ON ro.RolIdRol = rua.RuaIdRol
                                                 INNER JOIN DeliveryBackOffice.dbo.Account ac ON ac.AccIdAccount = rua.RuaIdAccount
                                                                                AND ac.AccRowStatus = 1
                                                 INNER JOIN DeliveryBackOffice.dbo.CatTypeAccount ta ON ta.TacIdTypeAccount = ac.AccIdTypeAccount
												                          INNER JOIN DeliveryBackOffice.dbo.InternalUser iu ON iu.RegisterUserID = UsrIdUser
												                          WHERE iu.UserName = @UserName AND iu.IdUser=@UserCode
													                            AND iu.RowStatus = 1 FOR XML PATH(''), TYPE
                                        ).value('.', 'varchar(max)'), 1, 1, '')
                                        );
                                        -- obtener los datos del perfil asociado al usuario 

										-- MODIFICACIÓN 09/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
										-- Determinar si ya ha aceptado los terminos y condiciones
										DECLARE @ValTAC INT = (SELECT [dbo].[FnValidateTermsAndConditions](@Username,@UserCode,2))

										-- Valida el valor en la tabla; 1 = TRUE, si fuera 0 o NULL devuelve FALSE
										DECLARE @TAC VARCHAR(5) = CASE WHEN @ValTAC = 1 THEN 'TRUE' ELSE 'FALSE' END
										-- FIN MODIFICACIÓN

                                        SET @JsonProfile =
                                        (
                                            SELECT STUFF(
                                        (
                                           SELECT ',{"FirstName":"' + pe.PerFirstName + '",' + '"LastName":"' + pe.PerLastName + '",' + '"Gender":"' + pe.PerGender + '",' +
                                         '"Birthdate":"' + CONVERT(VARCHAR, ISNULL(pe.PerBirthdate,'')) + '",' + '"Identification":"'
                                         + pe.PerIdentification + '",' + '"Nationality":"' + pe.PerNationality + '",' 
                                         + '"NickName":"' + CONVERT(VARCHAR, us.UsrNickName) + '",'
										 -- MODIFICACIÓN 01/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
                                         + '"Phone":"' + ISNULL(us.Phone,'') + '",'
										 + '"TAC":"' + @TAC
										 -- FIN MODIFICACIÓN
                                         + '"}'
                                                                                    FROM DeliveryBackOffice.dbo.RegisterUser us
                                                                                         INNER JOIN DeliveryBackOffice.dbo.Person pe ON pe.PerIdPerson = us.UsrIdPerson
                                                                                                                       AND pe.PerRowStatus = 1
                                                                                    INNER JOIN DeliveryBackOffice.dbo.InternalUser iu ON iu.RegisterUserID = us.UsrIdUser
												                                        WHERE iu.UserName = @UserName AND iu.IdUser=@UserCode
													                                          AND iu.RowStatus = 1
                                         FOR XML PATH(''), TYPE
                                        ).value('.', 'varchar(max)'), 1, 1, '')
                                        );

						      IF (@VERIFYUSER > 0)
							  BEGIN

                               SET @JsonProfileEXP = (SELECT STUFF((
		   	SELECT DISTINCT
			        ',{"Name":"' + ISNULL(VPC.DescriptionOfClient,'') + '",' +
		            '"ContactName":"' + isnull(VPC.ContactName, '')  + '",' +	  	  
		            '"Phone":"' + isnull(VPC.Phone, '')  + '",' +
			        '"Email":"' + isnull(cu.ContactEmail, '')  + '",' +
			        '"IdTownship":"' + isnull(convert(varchar,TWS.IdTownship), '')  + '",' +
			        '"TownshipName":"' + isnull(TWS.TownshipDescription, '')  + '",' +
			        '"IdProvince":"' + isnull(convert(varchar,PRV.IdProvince), '')  + '",' +
			        '"ProvinceName":"' + isnull(PRV.ProvinceDescription, '')  + '",' +
			        '"Address":"' + isnull(REPLACE(VPC.Address,'"',''), '')  + '",' +
					'"IdSettlement":"' + isnull(convert(varchar,STL.IdSettlement), '')  + '",' +
					'"IsTDA":"' + CASE WHEN dsc.TDA = 1 THEN 'TRUE' ELSE 'FALSE' END+ '",' +
                    '"HasSDD":"' + CASE WHEN dsc.SDD = 1 THEN 'TRUE' ELSE 'FALSE' END+ '",' +
					'"HUB":"' + ISNULL(dsc.Hub,'')+'",' +
			        '"HeaderCode":"' + isnull(TWS.HeaderCode, '')  + '",' +
					'"HasCredit":"'+ CONVERT(NVARCHAR,ISNULL(IIF(ISNULL(ccp.ConditionOfPayment,'Contado')='Contado','0','1'),'')) +'",'+
          '"HasRate":"'+ CONVERT(NVARCHAR,ISNULL(rc.[RbcRowStatus],'')) + '",'+
			        '"CodeOfReference":"' + isnull(convert (nvarchar(20) ,VPC.CodeOfReference), '') + '",' +
              '"ListCod":'+
                '[{'
								               +'"IdBank":"'+ ISNULL(CONVERT(varchar,ISNULL(vpconf.[CODAccountBankID], cu.[CODAccountBankID])), '')+ '",'
										           +'"BankDescription":"'+ CONVERT(NVARCHAR,  ISNULL(ISNULL(dbkconf.[Name], dbk.[Name]),''))+ '",'
								               +'"Acronym":"'+ CONVERT(NVARCHAR,  ISNULL(ISNULL(dbkconf.[Acronym], dbk.[Acronym]),''))+ '",'
								               +'"NameAccount":"'+ ISNULL(ISNULL(vpconf.CODAccountName,cu.[CODAccountName]),'')+ '",'
								               +'"TypeAccount":"'+ CONVERT(NVARCHAR, ISNULL(ISNULL(cbaconf.[BankAccountType], cba.[BankAccountType]),''))+ '",'
								               +'"NumberAcc":"'+ ISNULL(ISNULL(vpconf.CODAccountNumber,cu.[CODAccountNumber]),'')+ '",',
                               +'"DPI":"'+ISNULL(cu.[LegalSponsorDPI],'')+'"'
								               +'}]'
              +
		            '}' 
			        FROM  
			         DeliveryBackOffice.dbo.InternalUser iu 
			        JOIN DeliveryBackOffice.dbo.RegisterUser ru on  ru.UsrIdUser = iu.RegisterUserID and ru.UsrRowStatus = 1
			        JOIN DeliveryBackOffice.dbo.RolByUserByAccount rua ON rua.RuaIdUser = ru.UsrIdUser
			        JOIN DeliveryBackOffice.dbo.Account ac ON ac.AccIdAccount = rua.RuaIdAccount
			        JOIN DeliveryBackOffice.dbo.VisitPointClient vpc ON vpc.CustomerID = ac.IdCustomer
			        LEFT JOIN DeliveryBackOffice.dbo.Settlement STL on VPC.IdSettlement = STL.IdSettlement
					    LEFT JOIN DeliveryBackOffice.dbo.DumpServiceCoverage dsc ON dsc.IdSettlement = STL.IdSettlement AND dsc.RowStatus=1
			        LEFT JOIN DeliveryBackOffice.dbo.Township TWS on TWS.IdTownship = STL.IdTownship
			        LEFT JOIN DeliveryBackOffice.dbo.Province PRV ON PRV.IdProvince = TWS.IdProvince
              LEFT JOIN DeliveryBackOffice.dbo.Customer cu ON cu.IdCustomer = ac.IdCustomer AND cu.RowSatus = 1
							LEFT JOIN DeliveryBackOffice.dbo.DeliveryBank dbk ON cu.CODAccountBankID = dbk.Id_bank 
							AND dbk.Id_country = 'GT'
							AND dbk.Id_status = 1
							LEFT JOIN DeliveryBackOffice.dbo.CatBankAccountType cba ON cu.CODAccountTypeID = cba.IdBankAccountType
							AND cba.RowStatus = 1
							LEFT JOIN DeliveryBackOffice.dbo.RatebyCustomer rc ON cu.IdCustomer = rc.RbcIdCustomer
							AND rc.RbcRowStatus=1
							LEFT JOIN DeliveryBackOffice.dbo.CatConditionOfPayment ccp ON ccp.IdConditionOfPayment = cu.ConditionOfPaymentID
							LEFT JOIN DeliveryBackOffice.dbo.VisitPointByUser vpu ON vpu.RegisterUserID =ru.UsrIdUser
							-- Configuración del punto de visita
							LEFT JOIN DeliveryBackOffice.dbo.VisitPointConfiguration vpconf ON vpc.CodeOfReference = vpconf.VisitPointID
							LEFT JOIN DeliveryBackOffice.dbo.CatBankAccountType cbaconf ON vpconf.CODAccountBankTypeID = cbaconf.IdBankAccountType
							LEFT JOIN DeliveryBackOffice.dbo.DeliveryBank dbkconf ON vpconf.CODAccountBankID = dbkconf.Id_bank
			         WHERE iu.UserName = @UserName AND iu.IdUser=@UserCode AND vpu.IdVisitPointClient = vpc.IdVisitPointClient

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

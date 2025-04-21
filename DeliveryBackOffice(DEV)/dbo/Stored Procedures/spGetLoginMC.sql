-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2024-06-03>
-- Description:	<Login - Nuevo método para login Express Center, soporta multipaís.>
-- =============================================
-- Author:		<Oscar Rodriguez>
-- Create date: <2024-11-19>
-- Description:	<Se agrego devolucion de informacion de poblado de origen para login de express center>
-- =============================================

CREATE PROCEDURE [dbo].[spGetLoginMC]
    -- Add the parameters for the stored procedure here
    @Username VARCHAR(200)
  , @Password VARCHAR(200)
  , @IP VARCHAR(30)
  , @IdSystem INT = 1
  , @Station INT
AS
BEGIN

	SET NOCOUNT ON;
    DECLARE @StatusRestrinct NVARCHAR(50);
    DECLARE @StatusUser BIT;
    DECLARE @IdUser BIGINT;
    DECLARE @StatusAccount CHAR(1);
    DECLARE @PasswordExpired BIT;
    DECLARE @VisitPointValid BIT = 0;
	DECLARE @VERIFYUSER AS INT = 0;
	DECLARE @StationCorrect INT = 0;
	DECLARE @CreationGuideTutorial INT;

	DECLARE @User TABLE (
		UstStatus NVARCHAR(10),
		UsrStatus BIT,
		IdUser BIGINT,
		StatusAccount CHAR,
		PasswordExpired BIT
	);

	DECLARE @errormessage TABLE (
		IdResult INT,
		Message NVARCHAR(200),
		Id NVARCHAR(20)
	);

	DECLARE @ModulesTable TABLE (
		Module NVARCHAR(100),
		Icon NVARCHAR(50),
		Path NVARCHAR(200),
		MenuId NVARCHAR(10),
		GroupId NVARCHAR(10),
		NewFunction NVARCHAR(1),
		Rol NVARCHAR(50),
		SubModule VARCHAR(MAX)
	);

	DECLARE @AccountsTable TABLE (
		IdAccount NVARCHAR(20),
		AccountName NVARCHAR(100),
		TacName NVARCHAR(30),
		IdCustomer NVARCHAR (10),
		RolName NVARCHAR(50),
		ImageProfile NVARCHAR(600),
		StarRating NVARCHAR(4),
		VerifiedEmail NVARCHAR(1),
		ChangePassword NVARCHAR(1),
		AdminInternal NVARCHAR(1)
	);

	DECLARE @ProfileTable TABLE (
		FirstName NVARCHAR(100),
		LastName NVARCHAR(100),
		Gender NVARCHAR(2),
		Birthdate NVARCHAR(50),
		Identification NVARCHAR(50),
		Nationality NVARCHAR(100),
		NickName NVARCHAR(100),
		Phone NVARCHAR(30),
		VerifiedPhone NVARCHAR(1),
		TAC VARCHAR(5)
	);

	DECLARE @ProfileEXPTable TABLE (
		Name NVARCHAR(200),
		ContactName NVARCHAR(400),
		Phone NVARCHAR(100),
		Email NVARCHAR(400),
		IdTownship NVARCHAR(10),
		TownshipName NVARCHAR(100),
		IdProvince NVARCHAR(10),
		ProvinceName NVARCHAR(200),
		Address NVARCHAR(1200),
		HeaderCode NVARCHAR(10),
		CodeOfReference NVARCHAR(20),
		RolEXP NVARCHAR(MAX),
		CurrencyEXP NVARCHAR(5),
		Nationality NVARCHAR(50),
		IdSettlement NVARCHAR(50),
		SettlementName NVARCHAR(300)
	);

	--VALIDAR EL TIPO DE USUARIO QUE INICIA SESIÓN
    SET @VERIFYUSER =
    (
        SELECT COUNT(iu.IdEmployee)
        FROM RegisterUser           ru WITH(NOLOCK)
            INNER JOIN InternalUser iu WITH(NOLOCK)
                ON ru.UsrIdUser = iu.RegisterUserID
        WHERE ru.UsrEmail = @Username
              AND ru.UsrRowStatus = 1
    );

	--Validar que el usuario tenga permisos a la estación solicitada  
	SET @StationCorrect = (
		SELECT COUNT(*) FROM DeliveryBackOffice.DBO.CatStation CS WITH(NOLOCK)
		INNER JOIN DeliveryBackOffice.DBO.VisitPointClient VPC WITH(NOLOCK) ON  CS.CodeOfReference = VPC.CodeOfReference
		INNER JOIN DeliveryBackOffice.dbo.VisitPointByUser VPU WITH(NOLOCK) ON VPC.IdVisitPointClient = VPU.IdVisitPointClient
		INNER JOIN DeliveryBackOffice.dbo.RegisterUser RU WITH(NOLOCK) ON VPU.RegisterUserID = RU.UsrIdUser
		WHERE CS.IdStation = @Station AND RU.UsrEmail = @Username AND CS.RowStatus = 1
		AND VPU.RowStatus = 1 AND RU.UsrRowStatus = 1
	);

	INSERT INTO @User (UstStatus, UsrStatus, IdUser, StatusAccount, PasswordExpired)
	SELECT  ISNULL(res.UstStatus, 'N/A') UstStatus,
			ISNULL(usr.UsrRowStatus, 0) UsrStatus,
			ISNULL(usr.UsrIdUser, 0) IdUser,
			ISNULL(ac.AccConfirm, 'N') StatusAccount,
			(CASE
				WHEN ISNULL(usr.ChangePassword, 0) = 1
						AND ISNULL(usr.UsrPasswordExpiration, CAST(GETDATE() AS DATE)) <= CAST(GETDATE() AS DATE) THEN
					1
				ELSE
					0
			END) PasswordExpired
	FROM [DeliveryBackOffice].[dbo].RegisterUser usr WITH (NOLOCK)
		INNER JOIN [DeliveryBackOffice].[dbo].RolByUserBySystem rus WITH (NOLOCK)
			ON rus.RusIdUser = usr.UsrIdUser
		LEFT JOIN [DeliveryBackOffice].[dbo].UserSystemRestriction res WITH (NOLOCK)
			ON res.UstIdUser = rus.RusIdUser
				AND res.UstIdSystem = rus.RusIdSystem
		LEFT JOIN [DeliveryBackOffice].[dbo].[RolByUserByAccount] rua WITH (NOLOCK)
			ON rua.RuaIdUser = usr.UsrIdUser
				AND rua.RuaRowStatus = 1
		INNER JOIN [DeliveryBackOffice].[dbo].Account ac WITH (NOLOCK)
			ON ac.AccIdAccount = rua.RuaIdAccount
	WHERE usr.UsrEmail = @Username 
			AND rus.RusIdSystem = @IdSystem
			AND ac.AccRowStatus = 1
			AND usr.UsrLastPassword = @Password;

	-- insertar en tabla temporal posbibles mensajes de error
	INSERT INTO @errormessage (IdResult, Message, Id)
	SELECT 500                             AS IdResult,
		   'Usuario o contraseña invalida' AS Message,
		   'Invalid'                       AS Id
	UNION
	SELECT 500                 AS IdResult,
		   'Usuario bloqueado' AS Message,
		   'Blocked'           AS Id
	UNION
	SELECT 500                AS IdResult,
		   'Usuario inactivo' AS Message,
		   'Inactive'         AS Id
	UNION
	SELECT 500                   AS IdResult,
		   'Contraseña expirada' AS Message,
		   'PasswordExpired'     AS Id
	UNION
	SELECT 400                                                                                                                            AS IdResult,
		   'Cuenta pendiente de confirmación, se envió un nuevo link a su correo electrónico registrado, para poder confirmar su cuenta.' AS Message,
		   'Confirmation'																												  AS Id
	UNION
	SELECT 401                                               AS IdResult,
		   '¡Lo sentimos! No tienes acceso a la estación seleccionada. Por favor, verifica tus permisos o contacta a soporte.' AS Message,
		   'Station'										 AS Id

	IF @StationCorrect > 0
	BEGIN
		IF ( SELECT COUNT(*)FROM @User) > 0 -- si encuentra registros quiere decir que hay conicidencia en usuario y contraseña
		BEGIN
			-- Validación de visit point para express center
			IF (@VERIFYUSER > 0)
			BEGIN
				SET @VisitPointValid =
				(
					SELECT [VPC].[StatusClient]
					FROM [dbo].[RegisterUser]               RU WITH(NOLOCK)
						INNER JOIN [DeliveryBackOffice].[dbo].[VisitPointByUser] VP WITH(NOLOCK)
							ON [RU].[UsrIdUser] = [VP].[RegisterUserID]
						INNER JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH(NOLOCK)
							ON [VP].[IdVisitPointClient] = [VPC].[IdVisitPointClient]
					WHERE [RU].[UsrEmail] = @Username AND VP.RowStatus = 1
				);

				IF (@VisitPointValid = 0)
				BEGIN
					SELECT IdResult, Message FROM @errormessage WHERE Id = 'Inactive'
					RETURN;
				END;
			END;

			-- validar que el usuario no este bloqueado 
			SET @StatusRestrinct =
			( SELECT TOP 1 UPPER(UstStatus)FROM @User );
			SET @StatusUser =
			( SELECT TOP 1 UsrStatus FROM @User );
			SET @IdUser =
			( SELECT TOP 1 IdUser FROM @User );
			SET @StatusAccount =
			( SELECT TOP 1 StatusAccount FROM @User );
			SET @PasswordExpired =
			( SELECT TOP 1 PasswordExpired FROM @User );

			IF @StatusAccount = 'C'
			BEGIN
				IF @StatusRestrinct = 'ACTIVE' --USUARIO sin restricciones
				BEGIN
					IF @PasswordExpired = 0 --USUARIO sin restricciones
					BEGIN
						IF @StatusUser = 1 -- usuario activo
						BEGIN
							-- GENERAR TOKEN 
							DECLARE @Token AS NVARCHAR(50) =
							( SELECT CONVERT(VARCHAR(32), 
								HASHBYTES('MD5', CONCAT(@Username, @Password, SYSDATETIME()))
								, 2 ) AS token );

							IF ( SELECT COUNT(*)FROM [dbo].TokenLog tkn WITH(NOLOCK) WHERE tkn.TknIdToken = @Token ) = 0 --si el token no exite crearlo 
							BEGIN
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
							FROM RegisterUser                         us WITH(NOLOCK)
								INNER JOIN [dbo].[RolByUserByAccount] rua WITH(NOLOCK)
									ON rua.RuaIdUser = us.UsrIdUser
								INNER JOIN dbo.RolByModuleBySystem    rms WITH(NOLOCK)
									ON rms.RmsIdRol = rua.RuaIdRol
								INNER JOIN [dbo].CatModule            cmo WITH(NOLOCK)
									ON cmo.ModIdModule = rms.RmsIdModule
								INNER JOIN [dbo].CatRol               rol WITH(NOLOCK)
									ON rol.RolIdRol = rms.RmsIdRol
							WHERE us.UsrEmail = @Username
								  AND rms.RmsRowStatus = 1
								  AND rua.RuaRowStatus = 1
								  AND cmo.ModRowStatus = 1
								  AND cmo.ModVisible = 1
								  AND cmo.ModIdModuleParent IS NOT NULL
								  AND us.UsrRowStatus = 1;

							IF (@TOTALSUBMODULES) > 0
							BEGIN /*PARENT LIST*/
								INSERT INTO @TBSUBMODULES
								(
									ModIdModule
								)
								SELECT cmo.ModIdModule
								FROM RegisterUser                         us WITH(NOLOCK)
									INNER JOIN [dbo].[RolByUserByAccount] rua WITH(NOLOCK)
										ON rua.RuaIdUser = us.UsrIdUser
									INNER JOIN dbo.RolByModuleBySystem    rms WITH(NOLOCK)
										ON rms.RmsIdRol = rua.RuaIdRol
									INNER JOIN [dbo].CatModule            cmo WITH(NOLOCK)
										ON cmo.ModIdModule = rms.RmsIdModule
									INNER JOIN [dbo].CatRol               rol WITH(NOLOCK)
										ON rol.RolIdRol = rms.RmsIdRol
								WHERE us.UsrEmail = @Username
									  AND rua.RuaRowStatus = 1
									  AND rms.RmsRowStatus = 1
									  AND cmo.ModRowStatus = 1
									  AND cmo.ModVisible = 1
									  AND cmo.ModIdModuleParent IS NULL
									  AND cmo.ModIdModule IN
										(
											SELECT ModIdModuleParent FROM [dbo].CatModule
										)
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
								FROM RegisterUser                         us WITH(NOLOCK)
									INNER JOIN [dbo].[RolByUserByAccount] rua WITH(NOLOCK)
										ON rua.RuaIdUser = us.UsrIdUser
									INNER JOIN dbo.RolByModuleBySystem    rms WITH(NOLOCK)
										ON rms.RmsIdRol = rua.RuaIdRol
									INNER JOIN [dbo].CatModule            cmo WITH(NOLOCK)
										ON cmo.ModIdModule = rms.RmsIdModule
									INNER JOIN [dbo].CatRol               rol WITH(NOLOCK)
										ON rol.RolIdRol = rms.RmsIdRol
								WHERE us.UsrEmail = @Username
									  AND rua.RuaRowStatus = 1
									  AND rms.RmsRowStatus = 1
									  AND cmo.ModRowStatus = 1
									  AND cmo.ModVisible = 1
									  AND us.UsrRowStatus = 1 --order by cmo.ModOrder
									  AND cmo.ModIdModuleParent =
									  (
										  SELECT TMP.ModIdModule
										  FROM @TBSUBMODULES AS TMP
										  WHERE TMP.ITERATOR = @ITERATORSUBMODULES
									  );

								SELECT @CHILDSMENU = COUNT(1)
								FROM @TBSUBMODULES2;

								WHILE @CHILDSMENU > 0
								BEGIN
									SELECT @CHILDSMD
										= @CHILDSMD + '{"Module":"' + cmo.ModName + '",' + '"Icon":"' + cmo.ModMetadata
										  + '",' + '"Path":"' + cmo.ModPath + '"}|'
									FROM [dbo].CatModule cmo WITH(NOLOCK)
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
							INSERT INTO @ModulesTable (Module,Icon,Path,MenuId,GroupId,NewFunction,Rol,SubModule)
							SELECT 
								cmo.ModName					'Module',
								cmo.ModMetadata				'Icon',
								cmo.ModPath					'Path',
								CAST(ISNULL(rms.RmsModuleMenu, 1) AS NVARCHAR)	'MenuId',
								CAST(ISNULL(cmo.ModGroup, 0) AS NVARCHAR)		'GroupId',
								CAST(ISNULL(rms.RmsHasNewFunction, 0) AS NVARCHAR)	'NewFunction',
								rol.RolName					'Rol',
								(CASE
									WHEN LEN(ISNULL(TMP.SUBMODULES, '')) > 0 THEN
									COALESCE(TMP.SUBMODULES, '')	ELSE
									''	END ) 'SubModule'
							FROM RegisterUser                         us WITH(NOLOCK)
							INNER JOIN [dbo].[RolByUserByAccount] rua WITH(NOLOCK)
								ON rua.RuaIdUser = us.UsrIdUser
							INNER JOIN dbo.RolByModuleBySystem    rms WITH(NOLOCK)
								ON rms.RmsIdRol = rua.RuaIdRol
							INNER JOIN [dbo].CatModule            cmo WITH(NOLOCK)
								ON cmo.ModIdModule = rms.RmsIdModule
							INNER JOIN [dbo].CatRol               rol WITH(NOLOCK)
								ON rol.RolIdRol = rms.RmsIdRol
							LEFT JOIN @TBSUBMODULES               TMP
								ON TMP.ModIdModule = cmo.ModIdModule
							WHERE us.UsrEmail = @Username
									AND us.UsrRowStatus = 1
									AND rua.RuaRowStatus = 1
									AND rms.RmsRowStatus = 1
									AND cmo.ModRowStatus = 1
									AND cmo.ModVisible = 1
									AND cmo.ModIdModuleParent IS NULL /*IS DAD*/
							ORDER BY cmo.ModOrder

							-- obtener las cuentas a las que tiene acceso el usuario
							INSERT INTO @AccountsTable (IdAccount,AccountName,TacName,IdCustomer,RolName,ImageProfile,
														StarRating,VerifiedEmail,ChangePassword,AdminInternal)
							SELECT 
								CONVERT(VARCHAR, ac.AccIdAccount)		'IdAccount',
								ac.AccName								'AccountName',
								CASE
								WHEN @VERIFYUSER != 0 THEN	'Express'	
								ELSE
								ta.TacName
								END'TacName',
								CONVERT(VARCHAR, ISNULL(ac.IdCustomer, 0))	'IdCustomer',
								ro.RolName								'RolName',
								ISNULL(ac.ImageProfile, '')				'ImageProfile',
								CONVERT(VARCHAR(1), ISNULL(ac.StarRating, 0))	'StarRating',
								IIF(ac.AccConfirm = 'C', '1', '0')		'VerifiedEmail',
								CONVERT(VARCHAR, ISNULL(us.ChangePassword, 0))	'ChangePassword',
								CONVERT(VARCHAR, ISNULL(ro.RolAdminInternal, '0')) 'AdminInternal'
							FROM RegisterUser                         us WITH(NOLOCK)
							INNER JOIN [dbo].Person               pe WITH(NOLOCK)
								ON pe.PerIdPerson = us.UsrIdPerson
							INNER JOIN [dbo].[RolByUserByAccount] rua WITH(NOLOCK)
								ON rua.RuaIdUser = us.UsrIdUser
							INNER JOIN [dbo].CatRol               ro WITH(NOLOCK)
								ON ro.RolIdRol = rua.RuaIdRol
							INNER JOIN [dbo].Account              ac WITH(NOLOCK)
								ON ac.AccIdAccount = rua.RuaIdAccount
							INNER JOIN [dbo].CatTypeAccount       ta WITH(NOLOCK)
								ON ta.TacIdTypeAccount = ac.AccIdTypeAccount
							WHERE us.UsrEmail = @Username
								AND us.UsrRowStatus = 1
								AND pe.PerRowStatus = 1
								AND rua.RuaRowStatus = 1
								AND ac.AccRowStatus = 1

							-- obtener los datos del perfil asociado al usuario 
							-- Determinar si ya ha aceptado los terminos y condiciones
							DECLARE @ValTAC INT =
									(SELECT [dbo].[FnValidateTermsAndConditions](@Username, 0, 1) );

							-- Valida el valor en la tabla; 1 = TRUE, si fuera 0 o NULL devuelve FALSE
							DECLARE @TAC VARCHAR(5) = CASE
														  WHEN @ValTAC = 1 THEN
															  'TRUE'
														  ELSE
															  'FALSE'
													  END;
							-- FIN MODIFICACIÓN
							INSERT INTO @ProfileTable (FirstName,LastName,Gender,Birthdate,Identification,Nationality,
														NickName,Phone,VerifiedPhone,TAC)
							SELECT 
								pe.PerFirstName			'FirstName',
								pe.PerLastName			'LastName',
								pe.PerGender			'Gender',
								CONVERT(VARCHAR, pe.PerBirthdate)	'Birthdate',
								pe.PerIdentification	'Identification',
								pe.PerNationality		'Nationality',
								CONVERT(VARCHAR, us.UsrNickName)	'NickName',
								CONVERT(VARCHAR, COALESCE(us.Phone, ' '))	'Phone',
								CONVERT(VARCHAR(1), ISNULL(us.VerifiedPhone, 'false'))	'VerifiedPhone',
								@TAC					'TAC'
							FROM RegisterUser           us WITH(NOLOCK)
							INNER JOIN [dbo].Person pe WITH(NOLOCK)
								ON pe.PerIdPerson = us.UsrIdPerson
							WHERE us.UsrEmail = @Username
								AND us.UsrRowStatus = 1
								AND pe.PerRowStatus = 1

							-- Variable para guardar el rol de express center del usuario
							DECLARE @RolEXP NVARCHAR(MAX);

							SET @RolEXP =
							(
								SELECT TOP 1
									   cr.RolName
								FROM RegisterUser                 ru WITH(NOLOCK)
									INNER JOIN RolByUserByAccount rb WITH(NOLOCK)
										ON ru.UsrIdUser = rb.RuaIdUser
									INNER JOIN CatRol             cr WITH(NOLOCK)
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
							IF (@VERIFYUSER > 0)
							BEGIN

							INSERT INTO @ProfileEXPTable (Name,ContactName,Phone,Email,IdTownship,TownshipName,IdProvince,
															ProvinceName,Address,HeaderCode,CodeOfReference,RolEXP,CurrencyEXP,Nationality,IdSettlement,SettlementName)
							SELECT 
								DescriptionOfClient										'Name',
								ISNULL(ContactName, '')									'ContactName',
								ISNULL(VPC.Phone, '')									'Phone',
								ISNULL(Email, '')										'Email',
								ISNULL(CONVERT(VARCHAR, TWS.IdTownship), '')			'IdTownship',
								ISNULL(TWS.TownshipDescription, '')						'TownshipName',
								ISNULL(CONVERT(VARCHAR, PRV.IdProvince), '')			'IdProvince',
								ISNULL(PRV.ProvinceDescription, '')						'ProvinceName',
								ISNULL(VPC.Address, '')									'Address',
								ISNULL(TWS.HeaderCode, '')								'HeaderCode',
								ISNULL(CONVERT(NVARCHAR(20), VPC.CodeOfReference), '')	'CodeOfReference',
								@RolEXP													'RolEXP',
								ISNULL(CCC.CodeISO, 'GTQ')								'Currency',
								ISNULL(RH.CountryId,'GT')								'Nationality',
								ISNULL(STL.IdSettlement,'')								'IdSettlement',
								ISNULL(STL.Settlement,'')								'SettlementName'
							FROM DeliveryBackOffice.dbo.VisitPointClient		VPC WITH(NOLOCK)
							INNER JOIN DeliveryBackOffice.dbo.RatebyCustomer	RC WITH(NOLOCK)
								ON VPC.CustomerID = RC.RbcIdCustomer
							LEFT JOIN DeliveryBackOffice.dbo.KindOfVPClient		KOVPC WITH(NOLOCK)
								ON VPC.IdKindOfVPClient = KOVPC.IdKindOfVPClient
							INNER JOIN DeliveryBackOffice.dbo.RateHeader		RH WITH(NOLOCK)
								ON RC.RbcIdRate = RH.RheId 
							INNER JOIN DeliveryBackOffice.dbo.CatCurrencyCOD	CCC WITH(NOLOCK)
								ON CCC.IdCatCurrencyCOD = RH.IdCurrency 
								OR (RH.IdCurrency IS NULL AND CCC.IdCatCurrencyCOD = 1) --1 DEFAULT GT
							INNER JOIN VisitPointByUser							VPU WITH(NOLOCK)
								ON VPC.IdVisitPointClient = VPU.IdVisitPointClient
							INNER JOIN RegisterUser								ru WITH(NOLOCK)
								ON VPU.RegisterUserID = ru.UsrIdUser
							INNER JOIN DeliveryBackOffice.dbo.Settlement		STL WITH(NOLOCK)
								ON VPC.IdSettlement = STL.IdSettlement
							INNER JOIN DeliveryBackOffice.dbo.Township			TWS WITH(NOLOCK)
								ON TWS.IdTownship = STL.IdTownship
							INNER JOIN DeliveryBackOffice.dbo.Province			PRV WITH(NOLOCK)
								ON PRV.IdProvince = TWS.IdProvince
							WHERE KOVPC.KindOfVPName = 'Express Center'
								AND RC.RbcRowStatus = 1
								AND RH.RheRowStatus = 1
								AND CCC.RowStatus = 1
								AND ru.UsrEmail = @Username
								AND VPU.RowStatus = 1
								AND ru.UsrRowStatus = 1
								AND STL.SettlementSatus = 1

							END;
							IF @VERIFYUSER > 0
							BEGIN
								SELECT '200' AS 'IdResult', @Token AS 'Token'

								SELECT * FROM @ModulesTable

								SELECT * FROM @AccountsTable

								SELECT * FROM @ProfileTable

								SELECT * FROM @ProfileEXPTable;
							END;
							ELSE
							BEGIN
								SELECT '200' AS 'IdResult', @Token AS 'Token'

								SELECT * FROM @ModulesTable

								SELECT * FROM @AccountsTable

								SELECT * FROM @ProfileTable;
							END;

							--Tutorial
							DECLARE @IdAccount INT;
							SET @IdAccount =( SELECT TOP 1 IdAccount FROM @AccountsTable );
							SET @CreationGuideTutorial = (
								SELECT IdTutorial FROM DeliveryBackOffice.DBO.Tutorial WITH(NOLOCK)
								WHERE TutorialName = 'Creación de guías' AND RowStatus = 1
							);

							IF NOT EXISTS (
								SELECT * FROM DeliveryBackOffice.dbo.TutorialByAccount TBA WITH(NOLOCK)
								INNER JOIN DeliveryBackOffice.dbo.Account A WITH(NOLOCK) ON TBA.AccountId = A.AccIdAccount
								WHERE TBA.TutorialId = @CreationGuideTutorial AND A.AccIdAccount = @IdAccount AND TBA.RowStatus = 1 AND A.AccRowStatus = 1
							)
							BEGIN
								--INSERTAMOS VALOR EN TUTORIAL
								INSERT INTO DeliveryBackOffice.dbo.TutorialByAccount (TutorialId,AccountId,
											ToDisplay,RowStatus,DateCreated,TokenCreated,DateUpdated,TokenUpdated)
								VALUES
								(@CreationGuideTutorial,@IdAccount,2,1,GETDATE(),@Token,NULL,NULL)
							END;
						END;
						ELSE
						BEGIN
							SELECT IdResult, Message FROM @errormessage WHERE Id = 'Inactive'
						END;
					END;
					ELSE 
					BEGIN
						SELECT IdResult, Message FROM @errormessage WHERE Id = 'PasswordExpired'
					END;
				END;
				ELSE -- usuario bloqueado
				BEGIN
					IF ((@StatusRestrinct = 'BLOCKED'))
					BEGIN
						SELECT IdResult, Message FROM @errormessage WHERE Id = 'Blocked'
					END;
					ELSE -- culaquier otro estado diferente de "ACTIVE" y "BLOCKED"
					BEGIN
						SELECT IdResult, Message FROM @errormessage WHERE Id = 'Inactive'
					END;
				END;
			END;
			ELSE -- usuario o contraseña invalido
			BEGIN
				SELECT IdResult, Message FROM @errormessage  WHERE Id = 'Confirmation'
			END;
		END;
		ELSE -- usuario o contraseña invalido
		BEGIN
			-- incrementar en 1 los intentos fallidos de inicio de sesion 
			UPDATE [dbo].UserSystemRestriction
			SET UstRetries = (UstRetries + 1)
				, UstStatus = (IIF(UstRetries + 1 >= UstAccessRetries, 'BLOCKED', 'ACTIVE'))
			FROM [dbo].RegisterUser                   usr WITH(NOLOCK)
				LEFT JOIN [dbo].UserSystemRestriction res WITH(NOLOCK)
					ON res.UstIdUser = usr.UsrIdUser
						AND res.UstIdSystem = @IdSystem
			WHERE usr.UsrEmail = @Username;

			-- retornar mensaje de error
			SELECT IdResult, Message FROM @errormessage WHERE Id = 'Invalid'
		END;
	END;
	ELSE
	BEGIN
		-- retornar mensaje de error
		SELECT IdResult, Message FROM @errormessage WHERE Id = 'Station'
	END;
END;
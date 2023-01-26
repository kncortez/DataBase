
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2023-01-20>
-- Description:	< Obtener información de cliente a partir de correo electronico, usado principalmente para pantalla de venta de membresías a clientes individuales en plataforma web interna .>
-- =============================================
CREATE PROCEDURE [dbo].[GetClientDataByEmail]
	@UserId BIGINT, -- Register User, puede usarse para validar el rol que consulta la información
	@ClientUserEmail NVARCHAR(100) 
AS
BEGIN
	
	-- Variables globales estaticas
	DECLARE @NativeSystem INT = (
			SELECT 
				TOP 1 
					CS.SysIdSystem 
			FROM 
				[DeliveryBackOffice].[dbo].[CatSystem] CS WITH(NOLOCK) 
			WHERE 
				CS.SysNameSystem = 'Hermes web' COLLATE Latin1_General_CI_AI
		)
	DECLARE @StandardRole INT = (
			SELECT 
				TOP 1 
					CR.RolIdRol 
			FROM 
				[DeliveryBackOffice].[dbo].[CatRol] CR WITH(NOLOCK) 
			WHERE 
				CR.RolName = 'Nuevo estandar' COLLATE Latin1_General_CI_AI
		)
	DECLARE @PYMES INT = (
			SELECT
				TOP 1
					CTOB.IdTypeOfBusiness
			FROM
				[DeliveryBackOffice].[dbo].[CatTypeOfBusiness] CTOB WITH(NOLOCK)
			WHERE
				CTOB.TypeOfBusinessName = 'PYMES' COLLATE Latin1_General_CI_AI
		)
	DECLARE @InactiveMembeshipStatus INT = (
			SELECT
				TOP 1
					CSPS.IdCatSalesPackageStatus
			FROM
				[DeliveryBackOffice].[dbo].[CatSalesPackageStatus] CSPS WITH(NOLOCK)
			WHERE
				CSPS.SalesPackageStatusName = 'Inactiva' COLLATE Latin1_General_CI_AI
		)
	DECLARE @VoidedMembeshipStatus INT = (
			SELECT
				TOP 1
					CSPS.IdCatSalesPackageStatus
			FROM
				[DeliveryBackOffice].[dbo].[CatSalesPackageStatus] CSPS WITH(NOLOCK)
			WHERE
				CSPS.SalesPackageStatusName = 'Anulada' COLLATE Latin1_General_CI_AI
		)

	-- Validación de información
	DECLARE @CustomerInfo TABLE (
		IdCustomer INT,
		IdAccount BIGINT,
		IsAccountActive BIT,
		AccountActiveStatus NVARCHAR(50),
		CustomerName NVARCHAR(200),
		CustomerPhone NVARCHAR(200),
		CustomerEmail NVARCHAR(200),
		CustomerTypeId INT,
		CustomerTypeName NVARCHAR(200),
		IsPYMES BIT,
		HasMembership BIT,
		MembershipId INT,
		IsMembershipActive BIT,
		MembershipActiveStatus NVARCHAR(200),
		CatMembershipId INT,
		MembershipName NVARCHAR(200),
		MembershipExpirationDate DATE,
		MembershipLastPayment DATE,
		MemberSince DATE
	);

	BEGIN TRY

		-- Ingresar información obtenida
		INSERT INTO 
			@CustomerInfo
			(
				IdCustomer
				,IdAccount
				,IsAccountActive
				,AccountActiveStatus
				,CustomerName
				,CustomerPhone
				,CustomerEmail
				,CustomerTypeId
				,CustomerTypeName
				,IsPYMES
				,HasMembership
				,MembershipId
				,IsMembershipActive
				,MembershipActiveStatus
				,CatMembershipId
				,MembershipName
				,MembershipExpirationDate
				,MembershipLastPayment
				,MemberSince
			)	
		SELECT
			TOP 1
				Cu.IdCustomer
				,Acc.AccIdAccount
				,(
					CASE
						WHEN USR.UstStatus != 'ACTIVE' COLLATE Latin1_General_CI_AI THEN 0
						WHEN Acc.AccConfirm != 'C' COLLATE Latin1_General_CI_AI THEN 0
						ELSE 1
					END
				) 'IsActive'
				,(
					CASE
						WHEN USR.UstStatus != 'ACTIVE' COLLATE Latin1_General_CI_AI THEN 'Bloqueada'
						WHEN Acc.AccConfirm != 'C' COLLATE Latin1_General_CI_AI THEN 'Sin confirmar'
						ELSE 'Activa'
					END
				) 'ActiveStatus'
				,CONCAT(PRS.PerFirstName, PRS.PerLastName) 'CustomerName'
				,RU.Phone
				,RU.UsrEmail
				,Cu.IdCustomerType
				,CT.[Description]
				,(
					CASE
						WHEN Cu.TypeOfBusinessID = @PYMES THEN 1
						ELSE 0
					END
				) 'IsPYMES'
				,(
					CASE
						WHEN MMBRSHP.IdMembership IS NULL THEN 0
						ELSE 1
					END
				) 'HasMembership'
				,MMBRSHP.IdMembership
				,(
					CASE
						WHEN MMBRSHP.IdMembership IS NULL THEN 0
						WHEN GETDATE() >= MMBRSHP.ExpirationDate THEN 0
						WHEN MMBRSHP.CatMembershipStatusId = @InactiveMembeshipStatus THEN 0
						WHEN MMBRSHP.CatMembershipStatusId = @VoidedMembeshipStatus THEN 0
						WHEN MMBRSHP.RowStatus = 0 THEN 0
						ELSE 1
					END
				) 'IsMembershipActive'
				,(
					CASE
						WHEN MMBRSHP.IdMembership IS NULL THEN 'Sin membresía'
						WHEN GETDATE() >= MMBRSHP.ExpirationDate THEN 'Expirada'
						WHEN MMBRSHP.CatMembershipStatusId = @InactiveMembeshipStatus THEN 'Inactiva'
						WHEN MMBRSHP.CatMembershipStatusId = @VoidedMembeshipStatus THEN 'Anulada'
						WHEN MMBRSHP.RowStatus = 0 THEN 'Anulada'
						ELSE 'Activa'
					END
				) 'MembershipActiveStatus'
				,MMBRSHP.CatMembershipId
				,CM.MembershipName
				,CAST(MMBRSHP.ExpirationDate AS DATE)
				,CAST(ISNULL(MMBRSHP.LastPaymentDate, MMBRSHP.DateCreated) AS DATE) 'MembersgipLastPayment'
				,CAST(MMBRSHP.DateCreated AS DATE)
		FROM
			[DeliveryBackOffice].[dbo].[RegisterUser] RU WITH(NOLOCK) -- Usuario registrado
			INNER JOIN
				[DeliveryBackOffice].[dbo].[Person] PRS WITH(NOLOCK) -- Información que identifica al usuario
				ON
					RU.UsrIdPerson = PRS.PerIdPerson
			INNER JOIN
				[DeliveryBackOffice].[dbo].[UserSystemRestriction] USR WITH(NOLOCK) -- Restricción de usuario en sistema (Hermes web)
				ON
					RU.UsrIdUser = USR.UstIdUser
					AND
					USR.UstIdSystem = @NativeSystem
			INNER JOIN
				[DeliveryBackOffice].[dbo].[RolByUserByAccount] RBUBA WITH(NOLOCK) -- Rol de usuario en sistema (Se espera "Nuevo estandar")
				ON
					RU.UsrIdUser = RBUBA.RuaIdUser
					AND
					RBUBA.RuaIdRol = @StandardRole
			INNER JOIN
				[DeliveryBackOffice].[dbo].[Account] Acc WITH(NOLOCK) -- Cuenta del usuario
				ON
					RBUBA.RuaIdAccount = Acc.AccIdAccount
			INNER JOIN
				[DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK) -- Usuario como cliente
				ON
					Acc.IdCustomer = Cu.IdCustomer
			INNER JOIN
				[DeliveryBackOffice].[dbo].[CustomerType] CT WITH(NOLOCK) -- Tipo de cliente
				ON
					Cu.IdCustomerType = CT.IdCustomerType
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[Membership] MMBRSHP WITH(NOLOCK) -- Información de membresia, si tiene
				ON
					Cu.IdCustomer = MMBRSHP.CustomerId
					AND
					Acc.AccIdAccount = MMBRSHP.AccountId
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[CatMembership] CM WITH(NOLOCK)
				ON
					MMBRSHP.CatMembershipId = CM.IdCatMembership
		WHERE
			RU.UsrEmail = @ClientUserEmail COLLATE Latin1_General_CI_AI

		IF(EXISTS(SELECT TOP 1 1 FROM @CustomerInfo))
		BEGIN

			SELECT
				200 'resultCode',
				'Datos obtenidos satisfactoriamente' 'resultMessage'

			SELECT
				CI.IdCustomer
				,CI.IdAccount
				,CI.IsAccountActive
				,CI.AccountActiveStatus
				,CI.CustomerName
				,CI.CustomerPhone
				,CI.CustomerEmail
				,CI.CustomerTypeId
				,CI.CustomerTypeName
				,CI.IsPYMES
				,CI.HasMembership
				,CI.MembershipId
				,CI.IsMembershipActive
				,CI.MembershipActiveStatus
				,CI.CatMembershipId
				,CI.MembershipName
				,CI.MembershipExpirationDate
				,CI.MembershipLastPayment
				,CI.MemberSince
			FROM
				@CustomerInfo CI

		END
		ELSE
		BEGIN

			SELECT
				204 'resultCode',
				'Datos de usuario no existen' 'resultMessage'

		END

	END TRY
	BEGIN CATCH

		SELECT
			500 'resultCode',
			ERROR_MESSAGE() 'resultMessage'

	END CATCH

END;
-- =============================================
-- Author:		<Andrés Ruíz>
-- Create date: <07-02-2023>
-- Description:	< Proceso para obtener información general de bloqueos de un usuario >
-- =============================================
-- Author:		<Brandon Pedroza>
-- Modified:	<14-08-2024>
-- Description:	<Se agrega el prefijo al numero telefonico>
-- =============================================
--DECLARE
CREATE PROCEDURE [dbo].[spHW_GetStatusAccountData] 
	@AccountEmail NVARCHAR(200) = 'andres.ruiz@forzadelivery.com',
	@UserSystem NVARCHAR(200) = 'Hermes web'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @TargetSystem INT = (SELECT TOP 1 CS.SysIdSystem FROM [DeliveryBackOffice].[dbo].[CatSystem] CS WITH(NOLOCK) WHERE CS.SysNameSystem = @UserSystem COLLATE Latin1_General_CI_AI);

	DECLARE @AccountData TABLE(
		RegisterUserId BIGINT,
		AccountId BIGINT,
		CustomerId INT,
		AccountName NVARCHAR(600),
		AccountPhone NVARCHAR(600),
		AccountEmail NVARCHAR(600),
		AccountTypeName NVARCHAR(100),
		AccountTypeId INT,
		IsPasswordExpired BIT,
		IsAccountInactive BIT,
		IsAccountBlocked BIT
	);

	BEGIN TRY

		INSERT INTO @AccountData
			(
				RegisterUserId,
				AccountId,
				CustomerId,
				AccountName,
				AccountPhone,
				AccountEmail,
				AccountTypeName,
				AccountTypeId,
				IsPasswordExpired,
				IsAccountInactive,
				IsAccountBlocked
			)
		SELECT
			RU.UsrIdUser RegisterUserId,
			Acc.AccIdAccount AccountId,
			Cu.IdCustomer CustomerId,
			LTRIM(RTRIM(CONCAT(Prs.PerFirstName, ' ', Prs.PerLastName))) AccountName,
			ISNULL(Cu.CustomerPhone, CONCAT(ISNULL(RU.PrefixCallingCode,'+502'),ru.Phone)) AccountPhone,
			RU.UsrEmail AccountEmail,
			CT.[Description] AccountTypeName,
			CT.IdCustomerType AccountTypeId,
			(CASE WHEN RU.ChangePassword = 1 AND ISNULL(RU.UsrPasswordExpiration, CAST(GETDATE() AS DATE)) <= CAST(GETDATE() AS DATE) THEN 1 ELSE 0 END) IsPasswordExpired,
			(CASE WHEN Acc.AccConfirm != 'C' COLLATE Latin1_General_CI_AI THEN 1 ELSE 0 END) IsAccountInactive,
			(CASE WHEN USR.UstStatus != 'ACTIVE' COLLATE Latin1_General_CI_AI THEN 1 ELSE 0 END) IsAccountBlocked
		FROM
			[DeliveryBackOffice].[dbo].[RegisterUser] RU WITH(NOLOCK)
			INNER JOIN
				[DeliveryBackOffice].[dbo].[Person] Prs WITH(NOLOCK)
				ON
					RU.UsrIdPerson = Prs.PerIdPerson
			INNER JOIN
				[DeliveryBackOffice].[dbo].[RolByUserByAccount] RBUBA WITH(NOLOCK)
				ON
					RU.UsrIdUser = RBUBA.RuaIdUser
					AND
					RBUBA.RuaRowStatus = 1
			INNER JOIN
				[DeliveryBackOffice].[dbo].[Account] Acc WITH(NOLOCK)
				ON
					RBUBA.RuaIdAccount = Acc.AccIdAccount
			INNER JOIN
				[DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
				ON
					Acc.IdCustomer = Cu.IdCustomer
			INNER JOIN
				[DeliveryBackOffice].[dbo].[CustomerType] CT WITH(NOLOCK)
				ON
					Cu.IdCustomerType = CT.IdCustomerType
			INNER JOIN
				[DeliveryBackOffice].[dbo].[UserSystemRestriction] USR WITH(NOLOCK)
				ON
					RU.UsrIdUser = USR.UstIdUser
					AND
					USR.UstIdSystem = @TargetSystem
		WHERE
			RU.UsrEmail = @AccountEmail COLLATE Latin1_General_CI_AI

		IF(EXISTS(SELECT TOP 1 1 FROM @AccountData))
		BEGIN

			SELECT
				200 'resultCode',
				'Información obtenida exitosamente' 'resultMessage'

			SELECT
				AD.RegisterUserId,
				AD.AccountId,
				AD.CustomerId,
				AD.AccountName,
				AD.AccountPhone,
				AD.AccountEmail,
				AD.AccountTypeName,
				AD.AccountTypeId,
				AD.IsPasswordExpired,
				AD.IsAccountInactive,
				AD.IsAccountBlocked
			FROM
				@AccountData AD

		END
		ELSE
		BEGIN

			SELECT
				204 'resultCode',
				'No se pudo obtener la información solicitada' 'resultMessage'

			SELECT
				AD.RegisterUserId,
				AD.AccountId,
				AD.CustomerId,
				AD.AccountName,
				AD.AccountPhone,
				AD.AccountEmail,
				AD.AccountTypeName,
				AD.AccountTypeId,
				AD.IsPasswordExpired,
				AD.IsAccountInactive,
				AD.IsAccountBlocked
			FROM
				@AccountData AD

		END

	END TRY
	BEGIN CATCH

		SELECT
			500 'resultCode',
			ERROR_MESSAGE() 'resultMessage'

	END CATCH
END
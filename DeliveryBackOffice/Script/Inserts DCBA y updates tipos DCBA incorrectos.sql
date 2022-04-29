
DECLARE @IDCurrency INT = (SELECT TOP 1 CCCOD.IdCatCurrencyCOD FROM [DeliveryBackOffice].[dbo].[CatCurrencyCOD] CCCOD WHERE CCCOD.Name = 'QUETZAL');

-- DESDE CLIENTES

--SELECT -- Aquellas que no existe una cuenta como tal
--	*
--FROM
--	[DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
--	JOIN
--		[DeliveryBackOffice].[dbo].[CatBankAccountType] CBAT WITH(NOLOCK)
--		ON
--			Cu.CODAccountTypeID = CBAT.IdBankAccountType
--	LEFT JOIN
--		[DeliveryBackOffice].[dbo].[DeliveryCustomerBankAccount] DCBA WITH(NOLOCK)
--		ON
--			Cu.CODAccountBankID = DCBA.DCBA_Bank_Id
--			AND
--			Cu.CODAccountNumber = DCBA.DCBA_Num_account
--			AND
--			DCBA.DCBA_Id_estado = 1
--WHERE
--	Cu.CODAccountNumber IS NOT NULL
--	AND
--	DCBA.DCBA_Id IS NULL
--	AND
--	Cu.CODAccountBankID = 5 
--	AND
--	Cu.RowSatus = 1
--	AND
--	LEFT(LTRIM(RTRIM(Cu.CODAccountNumber)), 1)IN ('0','3','4')
--	AND
--	LEN(LTRIM(RTRIM(Cu.CODAccountNumber))) IN (10,14)
	
--INSERTAR NUEVOS DCBA
INSERT INTO [DeliveryBackOffice].[dbo].[DeliveryCustomerBankAccount] (DCBA_Id, DCBA_Bank_Id, DCBA_Customer_Id, DCBA_Num_account, DCBA_Nom_account, DCBA_Id_currency, DCBA_TokenCreated, DCBA_DateCreated, DCBA_Id_estado, DCBA_BankAccountType)
SELECT -- Aquellas que no existe una cuenta como tal
	(SELECT TOP 1 DCBAX.DCBA_Id FROM [DeliveryBackOffice].[dbo].[DeliveryCustomerBankAccount] DCBAX WITH(NOLOCK) ORDER BY DCBAX.DCBA_Id DESC) + ROW_NUMBER() OVER(ORDER BY Cu.CODAccountBankID ASC)
	,Cu.CODAccountBankID 'DCBA_Bank_Id'
	,-1 'DCBA_Customer_Id'
	,LTRIM(RTRIM(Cu.CODAccountNumber)) 'DCBA_Num_account'
	,Cu.CODAccountName 'DCBA_Nom_account'
	,1 'DCBA_Id_currency'
	,'SYS-ARUIZ' 'DCBA_TokenCreated'
	,GETDATE() 'DCBA_DateCreated'
	,1 'DCBA_Id_estado'
	,UPPER(CBAT.BankAccountType) 'DCBA_BankAccountType'
FROM
	[DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
	JOIN
		[DeliveryBackOffice].[dbo].[CatBankAccountType] CBAT WITH(NOLOCK)
		ON
			Cu.CODAccountTypeID = CBAT.IdBankAccountType
	LEFT JOIN
		[DeliveryBackOffice].[dbo].[DeliveryCustomerBankAccount] DCBA WITH(NOLOCK)
		ON
			Cu.CODAccountBankID = DCBA.DCBA_Bank_Id
			AND
			Cu.CODAccountNumber = DCBA.DCBA_Num_account
			AND
			DCBA.DCBA_Id_estado = 1
WHERE
	Cu.CODAccountNumber IS NOT NULL
	AND
	DCBA.DCBA_Id IS NULL
	AND
	Cu.CODAccountBankID = 5 
	AND
	Cu.RowSatus = 1
	AND
	(
		(LEFT(LTRIM(RTRIM(Cu.CODAccountNumber)), 1)IN ('3','4') AND LEN(LTRIM(RTRIM(Cu.CODAccountNumber))) = 10)
		OR
		(LEFT(LTRIM(RTRIM(Cu.CODAccountNumber)), 1)IN ('0') AND LEN(LTRIM(RTRIM(Cu.CODAccountNumber))) = 14)
	)
	
	

--SELECT -- Aquellas que existe una cuenta como tal pero el tipo es diferente
--	*
--FROM
--	[DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
--	JOIN
--		[DeliveryBackOffice].[dbo].[CatBankAccountType] CBAT WITH(NOLOCK)
--		ON
--			Cu.CODAccountTypeID = CBAT.IdBankAccountType
--	LEFT JOIN
--		[DeliveryBackOffice].[dbo].[DeliveryCustomerBankAccount] DCBA WITH(NOLOCK)
--		ON
--			Cu.CODAccountBankID = DCBA.DCBA_Bank_Id
--			AND
--			Cu.CODAccountNumber = DCBA.DCBA_Num_account
--			AND
--			DCBA.DCBA_Id_estado = 1
--WHERE
--	Cu.CODAccountNumber IS NOT NULL
--	AND
--	CBAT.BankAccountType != DCBA.DCBA_BankAccountType COLLATE Latin1_General_CI_AI
--	AND
--	Cu.CODAccountBankID = 5
--	AND
--	Cu.RowSatus = 1 
--	AND
--	LEFT(Cu.CODAccountNumber, 1)IN ('0','3','4')
--	AND
--	LEN(LTRIM(RTRIM(Cu.CODAccountNumber))) IN (10,14)

--ACTUALIZAR LOS EXISTENTES QUE NO COINCIDE EL TIPO
UPDATE DCBA
SET DCBA.DCBA_BankAccountType = CBAT.BankAccountType, DCBA.ACN_DateUpdate = GETDATE(), DCBA.DCBA_TokenUpdate = 'SYS-ARUIZ'
FROM -- Aquellas que existe una cuenta como tal pero el tipo es diferente
	[DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
	JOIN
		[DeliveryBackOffice].[dbo].[CatBankAccountType] CBAT WITH(NOLOCK)
		ON
			Cu.CODAccountTypeID = CBAT.IdBankAccountType
	LEFT JOIN
		[DeliveryBackOffice].[dbo].[DeliveryCustomerBankAccount] DCBA WITH(NOLOCK)
		ON
			Cu.CODAccountBankID = DCBA.DCBA_Bank_Id
			AND
			Cu.CODAccountNumber = DCBA.DCBA_Num_account
			AND
			DCBA.DCBA_Id_estado = 1
WHERE
	Cu.CODAccountNumber IS NOT NULL
	AND
	CBAT.BankAccountType != DCBA.DCBA_BankAccountType COLLATE Latin1_General_CI_AI
	AND
	Cu.CODAccountBankID = 5 
	AND
	Cu.RowSatus = 1
	AND
	(
		(LEFT(LTRIM(RTRIM(Cu.CODAccountNumber)), 1)IN ('3','4') AND LEN(LTRIM(RTRIM(Cu.CODAccountNumber))) = 10)
		OR
		(LEFT(LTRIM(RTRIM(Cu.CODAccountNumber)), 1)IN ('0') AND LEN(LTRIM(RTRIM(Cu.CODAccountNumber))) = 14)
	)

-- DESDE PUNTOS DE VISITA

--SELECT -- Aquellas que no existe una cuenta como tal
--	*
--FROM
--	[DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH(NOLOCK)
--	JOIN
--		[DeliveryBackOffice].[dbo].[VisitPointConfiguration] VPConfig WITH(NOLOCK)
--		ON
--			VPC.CodeOfReference = VPConfig.VisitPointID
--	JOIN
--		[DeliveryBackOffice].[dbo].[CatBankAccountType] CBAT WITH(NOLOCK)
--		ON
--			VPConfig.CODAccountBankTypeID = CBAT.IdBankAccountType
--	LEFT JOIN
--		[DeliveryBackOffice].[dbo].[DeliveryCustomerBankAccount] DCBA WITH(NOLOCK)
--		ON
--			VPConfig.CODAccountBankID = DCBA.DCBA_Bank_Id
--			AND
--			VPConfig.CODAccountNumber = DCBA.DCBA_Num_account
--			AND
--			DCBA.DCBA_Id_estado = 1
--WHERE
--	DCBA.DCBA_Id IS NULL
--	AND
--	VPConfig.CODAccountBankID = 5
--	AND
--	VPC.StatusClient = 1
--	AND
--	LEFT(VPConfig.CODAccountNumber, 1)IN ('0','3','4')
--	AND
--	LEN(LTRIM(RTRIM(VPConfig.CODAccountNumber))) IN (10,14)
	
--INSERTAR NUEVOS DCBA
INSERT INTO [DeliveryBackOffice].[dbo].[DeliveryCustomerBankAccount] (DCBA_Id, DCBA_Bank_Id, DCBA_Customer_Id, DCBA_Num_account, DCBA_Nom_account, DCBA_Id_currency, DCBA_TokenCreated, DCBA_DateCreated, DCBA_Id_estado, DCBA_BankAccountType)
SELECT -- Aquellas que no existe una cuenta como tal
	(SELECT TOP 1 DCBAX.DCBA_Id FROM [DeliveryBackOffice].[dbo].[DeliveryCustomerBankAccount] DCBAX WITH(NOLOCK) ORDER BY DCBAX.DCBA_Id DESC) + ROW_NUMBER() OVER(ORDER BY VPConfig.CODAccountBankID ASC)
	,VPConfig.CODAccountBankID 'DCBA_Bank_Id'
	,-1 'DCBA_Customer_Id'
	,LTRIM(RTRIM(VPConfig.CODAccountNumber)) 'DCBA_Num_account'
	,VPConfig.CODAccountName 'DCBA_Nom_account'
	,1 'DCBA_Id_currency'
	,'SYS-ARUIZ' 'DCBA_TokenCreated'
	,GETDATE() 'DCBA_DateCreated'
	,1 'DCBA_Id_estado'
	,UPPER(CBAT.BankAccountType) 'DCBA_BankAccountType'
FROM
	[DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH(NOLOCK)
	JOIN
		[DeliveryBackOffice].[dbo].[VisitPointConfiguration] VPConfig WITH(NOLOCK)
		ON
			VPC.CodeOfReference = VPConfig.VisitPointID
	JOIN
		[DeliveryBackOffice].[dbo].[CatBankAccountType] CBAT WITH(NOLOCK)
		ON
			VPConfig.CODAccountBankTypeID = CBAT.IdBankAccountType
	LEFT JOIN
		[DeliveryBackOffice].[dbo].[DeliveryCustomerBankAccount] DCBA WITH(NOLOCK)
		ON
			VPConfig.CODAccountBankID = DCBA.DCBA_Bank_Id
			AND
			VPConfig.CODAccountNumber = DCBA.DCBA_Num_account
			AND
			DCBA.DCBA_Id_estado = 1
WHERE
	DCBA.DCBA_Id IS NULL
	AND
	VPConfig.CODAccountBankID = 5
	AND
	VPC.StatusClient = 1
	AND
	(
		(LEFT(LTRIM(RTRIM(VPConfig.CODAccountNumber)), 1)IN ('3','4') AND LEN(LTRIM(RTRIM(VPConfig.CODAccountNumber))) = 10)
		OR
		(LEFT(LTRIM(RTRIM(VPConfig.CODAccountNumber)), 1)IN ('0') AND LEN(LTRIM(RTRIM(VPConfig.CODAccountNumber))) = 14)
	)


--SELECT -- Aquellas que existe una cuenta como tal pero el tipo es diferente
--	*
--FROM
--	[DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH(NOLOCK)
--	JOIN
--		[DeliveryBackOffice].[dbo].[VisitPointConfiguration] VPConfig WITH(NOLOCK)
--		ON
--			VPC.CodeOfReference = VPConfig.VisitPointID
--	JOIN
--		[DeliveryBackOffice].[dbo].[CatBankAccountType] CBAT WITH(NOLOCK)
--		ON
--			VPConfig.CODAccountBankTypeID = CBAT.IdBankAccountType
--	LEFT JOIN
--		[DeliveryBackOffice].[dbo].[DeliveryCustomerBankAccount] DCBA WITH(NOLOCK)
--		ON
--			VPConfig.CODAccountBankID = DCBA.DCBA_Bank_Id
--			AND
--			VPConfig.CODAccountNumber = DCBA.DCBA_Num_account
--			AND
--			DCBA.DCBA_Id_estado = 1
--WHERE
--	CBAT.BankAccountType != DCBA.DCBA_BankAccountType COLLATE Latin1_General_CI_AI
--	AND
--	VPConfig.CODAccountBankID = 5
--	AND
--	VPC.StatusClient = 1
--	AND
--	LEFT(VPConfig.CODAccountNumber, 1)IN ('0','3','4')
--	AND
--	LEN(LTRIM(RTRIM(VPConfig.CODAccountNumber))) IN (10,14)

	
--ACTUALIZAR LOS EXISTENTES QUE NO COINCIDE EL TIPO
UPDATE DCBA
SET DCBA.DCBA_BankAccountType = CBAT.BankAccountType, DCBA.ACN_DateUpdate = GETDATE(), DCBA.DCBA_TokenUpdate = 'SYS-ARUIZ'
FROM -- Aquellas que existe una cuenta como tal pero el tipo es diferente
	[DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH(NOLOCK)
	JOIN
		[DeliveryBackOffice].[dbo].[VisitPointConfiguration] VPConfig WITH(NOLOCK)
		ON
			VPC.CodeOfReference = VPConfig.VisitPointID
	JOIN
		[DeliveryBackOffice].[dbo].[CatBankAccountType] CBAT WITH(NOLOCK)
		ON
			VPConfig.CODAccountBankTypeID = CBAT.IdBankAccountType
	LEFT JOIN
		[DeliveryBackOffice].[dbo].[DeliveryCustomerBankAccount] DCBA WITH(NOLOCK)
		ON
			VPConfig.CODAccountBankID = DCBA.DCBA_Bank_Id
			AND
			VPConfig.CODAccountNumber = DCBA.DCBA_Num_account
			AND
			DCBA.DCBA_Id_estado = 1
WHERE
	CBAT.BankAccountType != DCBA.DCBA_BankAccountType COLLATE Latin1_General_CI_AI
	AND
	VPConfig.CODAccountBankID = 5
	AND
	VPC.StatusClient = 1
	AND
	(
		(LEFT(LTRIM(RTRIM(VPConfig.CODAccountNumber)), 1)IN ('3','4') AND LEN(LTRIM(RTRIM(VPConfig.CODAccountNumber))) = 10)
		OR
		(LEFT(LTRIM(RTRIM(VPConfig.CODAccountNumber)), 1)IN ('0') AND LEN(LTRIM(RTRIM(VPConfig.CODAccountNumber))) = 14)
	)

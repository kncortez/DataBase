
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-07-12>
-- Description:	< Busqueda de membresias o subscripciones las cuales deben ser renovadas >
-- =============================================

CREATE PROCEDURE [dbo].[GetSalePackageToRenew]
	@TypeProcess NVARCHAR(20) = 'MEMBERSHIP'
AS
BEGIN

	-- Variables estaticas globales
	DECLARE @SystemId INT = (SELECT TOP 1 CS.SysIdSystem FROM [DeliveryBackOffice].[dbo].[CatSystem] CS WITH(NOLOCK) WHERE CS.SysNameSystem = 'Hermes Charge Service' AND CS.SysRowStatus = 1)

	DECLARE @CorporateCustomer INT = (SELECT TOP 1 CT.IdCustomerType FROM [DeliveryBackOffice].[dbo].[CustomerType] CT WITH(NOLOCK) WHERE CT.[Description] = 'CORPORATIVO' );
	DECLARE @IndividualCustomer INT = (SELECT TOP 1 CT.IdCustomerType FROM [DeliveryBackOffice].[dbo].[CustomerType] CT WITH(NOLOCK) WHERE CT.[Description] = 'INDIVIDUAL' );
	
	DECLARE @ActiveStatus INT = (SELECT TOP 1 CSPS.IdCatSalesPackageStatus FROM [DeliveryBackOffice].[dbo].[CatSalesPackageStatus] CSPS WITH(NOLOCK) WHERE CSPS.SalesPackageStatusName = 'Activa' );
	DECLARE @InactiveStatus INT = (SELECT TOP 1 CSPS.IdCatSalesPackageStatus FROM [DeliveryBackOffice].[dbo].[CatSalesPackageStatus] CSPS WITH(NOLOCK) WHERE CSPS.SalesPackageStatusName = 'Inactiva' );
	DECLARE @VoidStatus INT = (SELECT TOP 1 CSPS.IdCatSalesPackageStatus FROM [DeliveryBackOffice].[dbo].[CatSalesPackageStatus] CSPS WITH(NOLOCK) WHERE CSPS.SalesPackageStatusName = 'Anulada' );

	-- Obtener datos
	IF(@TypeProcess = 'MEMBERSHIP' )
	BEGIN

		-- Membresias
		-- Clientes individuales
		SELECT
			Mmshp.IdMembership 'SalePackageId'
			,CM.MembershipName 'CatalogSalePackageId'
			,CONCAT('MP', RIGHT(CONCAT('000000000000000000',RIGHT(YEAR(GETDATE()), 2), RIGHT(CONCAT('00',DATEPART(DAY, GETDATE())),2),Mmshp.IdMembership,RIGHT(CONCAT('00',ISNULL((
				SELECT
					COUNT(1)
				FROM
					[DeliveryBackOffice].[dbo].[MembershipPaymentLog] MPLRejects WITH(NOLOCK)
				WHERE
					MPLRejects.MembershipId = Mmshp.IdMembership
					AND
					MPLRejects.DateCreated >= ISNULL(Mmshp.LastPaymentDate, Mmshp.DateCreated)
					AND
					LTRIM(RTRIM(ISNULL(MPLRejects.[TransactionOrder],''))) = 'REJECTED' 
					AND
					MPLRejects.RowStatus = 1
			),0)),1)),12)) 'SalePackageReference'
			,Mmshp.MembershipCost 'SalePackageCost'
			,Mmshp.InvoiceEmail 'LinkedEmail'
			,Mmshp.CustomerId 'CustomerId'
			,Mmshp.AccountId 'AccountId'
			,Mmshp.InvoiceName
			,Mmshp.TaxIdNumber
			,Mmshp.InvoiceEmail
			,Mmshp.FiscalAddress
			,CT.[Description] 'CustomerType'
			,'CARD' 'PaymentType'
			,CPV.TokenizedToken
			,CPV.TokenizedExpirationDate
			,CPV.TokenizedCVV
			,CPV.[Type] 'CardType'
			,ISNULL((
				SELECT
					COUNT(1)
				FROM
					[DeliveryBackOffice].[dbo].[MembershipPaymentLog] MPLRejects WITH(NOLOCK)
				WHERE
					MPLRejects.MembershipId = Mmshp.IdMembership
					AND
					MPLRejects.DateCreated >= ISNULL(Mmshp.LastPaymentDate, Mmshp.DateCreated)
					AND
					LTRIM(RTRIM(ISNULL(MPLRejects.[TransactionOrder],''))) = 'REJECTED' 
					AND
					MPLRejects.RowStatus = 1
			),0) 'RenewalAttempts'
			,FORMAT(Mmshp.LastPaymentDate,'MMyy') 'LastMonth'
			,FORMAT(DATEADD(DAY,CM.MembershipValidity,Mmshp.LastPaymentDate),'MMyy') 'RecentMonth'
			,@SystemId 'System'
			,Mmshp.CatMembershipId 'CatalogSalePackageAsInt'
		FROM
			[DeliveryBackOffice].[dbo].[Membership] Mmshp WITH(NOLOCK)
			INNER JOIN
				[DeliveryBackOffice].[dbo].[CatMembership] CM WITH(NOLOCK)
				ON
					Mmshp.CatMembershipId = CM.IdCatMembership
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[MembershipPaymentLog] MPLPaid WITH(NOLOCK)
				ON
					Mmshp.IdMembership = MPLPaid.MembershipId
					AND
					MPLPaid.DateCreated BETWEEN CAST(CAST(ISNULL(Mmshp.LastPaymentDate, Mmshp.DateCreated) AS DATE) AS DATETIME) AND Mmshp.ExpirationDate
					AND
					LTRIM(RTRIM(ISNULL(MPLPaid.[TransactionOrder],''))) <> 'REJECTED'
					AND
					MPLPaid.RowStatus = 1
			INNER JOIN
				[DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
				ON
					Mmshp.CustomerId = Cu.IdCustomer
					AND
					ISNULL(Cu.RowSatus,1) = 1
			INNER JOIN
				[DeliveryBackOffice].[dbo].[CustomerType] CT WITH(NOLOCK)
				ON
					Cu.IdCustomerType = CT.IdCustomerType
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[Account] Acc WITH(NOLOCK)
				ON
					Mmshp.AccountId = Acc.AccIdAccount
					AND
					ISNULL(Acc.AccRowStatus,1) = 1
			INNER JOIN
				[DeliveryBackOffice].[dbo].[CustomerPaymentValue] CPV WITH(NOLOCK)
				ON
					Mmshp.CustomerPaymentId = CPV.IdCustomerPaymentValue
					AND
					CPV.RowStatus = 1
		WHERE
			Mmshp.CatMembershipStatusId NOT IN (@VoidStatus)
			AND
			Mmshp.CustomerPaymentId IS NOT NULL
			AND
			(MPLPaid.IdMembershipPaymentLog IS NULL OR Mmshp.CatMembershipStatusId = @InactiveStatus OR GETDATE() >= Mmshp.ExpirationDate )
			AND
			Cu.IdCustomerType = @IndividualCustomer
			AND
			Mmshp.IsAutoRenewable = 1
			AND
			Mmshp.RowStatus = 1
		UNION
		-- Clientes corporativos
		SELECT
			Mmshp.IdMembership 'SalePackageId'
			,CM.MembershipName 'CatalogSalePackageId'
			,CONCAT('MP', RIGHT(CONCAT('000000000000000000',RIGHT(YEAR(GETDATE()), 2), RIGHT(CONCAT('00',DATEPART(DAY, GETDATE())),2),Mmshp.IdMembership,RIGHT(CONCAT('00',ISNULL((
				SELECT
					COUNT(1)
				FROM
					[DeliveryBackOffice].[dbo].[MembershipPaymentLog] MPLRejects WITH(NOLOCK)
				WHERE
					MPLRejects.MembershipId = Mmshp.IdMembership
					AND
					MPLRejects.DateCreated >= ISNULL(Mmshp.LastPaymentDate, Mmshp.DateCreated)
					AND
					LTRIM(RTRIM(ISNULL(MPLRejects.[TransactionOrder],''))) = 'REJECTED' 
					AND
					MPLRejects.RowStatus = 1
			),0)),1)),12)) 'SalePackageReference'
			,Mmshp.MembershipCost 'SalePackageCost'
			,Mmshp.InvoiceEmail 'LinkedEmail'
			,Mmshp.CustomerId 'CustomerId'
			,Mmshp.AccountId 'AccountId'
			,Mmshp.InvoiceName
			,Mmshp.TaxIdNumber
			,Mmshp.InvoiceEmail
			,Mmshp.FiscalAddress
			,CT.[Description] 'CustomerType'
			,IIF(CPV.IdCustomerPaymentValue IS NULL AND CCOP.IdConditionOfPayment IS NOT NULL, 'CRED', 'CARD') 'PaymentType'
			,CPV.TokenizedToken
			,CPV.TokenizedExpirationDate
			,CPV.TokenizedCVV
			,CPV.[Type] 'CardType'
			,ISNULL((
				SELECT
					COUNT(1)
				FROM
					[DeliveryBackOffice].[dbo].[MembershipPaymentLog] MPLRejects WITH(NOLOCK)
				WHERE
					MPLRejects.MembershipId = Mmshp.IdMembership
					AND
					MPLRejects.DateCreated >= ISNULL(Mmshp.LastPaymentDate, Mmshp.DateCreated)
					AND
					LTRIM(RTRIM(ISNULL(MPLRejects.[TransactionOrder],''))) = 'REJECTED' 
					AND
					MPLRejects.RowStatus = 1
			),0) 'RenewalAttempts'
			,FORMAT(Mmshp.LastPaymentDate,'MMyy') 'LastMonth'
			,FORMAT(DATEADD(DAY,CM.MembershipValidity,Mmshp.LastPaymentDate),'MMyy') 'RecentMonth'
			,@SystemId 'System'
			,Mmshp.CatMembershipId 'CatalogSalePackageAsInt'
		FROM
			[DeliveryBackOffice].[dbo].[Membership] Mmshp WITH(NOLOCK)
			INNER JOIN
				[DeliveryBackOffice].[dbo].[CatMembership] CM WITH(NOLOCK)
				ON
					Mmshp.CatMembershipId = CM.IdCatMembership
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[MembershipPaymentLog] MPLPaid WITH(NOLOCK)
				ON
					Mmshp.IdMembership = MPLPaid.MembershipId
					AND
					MPLPaid.DateCreated BETWEEN CAST(CAST(ISNULL(Mmshp.LastPaymentDate, Mmshp.DateCreated) AS DATE) AS DATETIME) AND Mmshp.ExpirationDate
					AND
					LTRIM(RTRIM(ISNULL(MPLPaid.[TransactionOrder],''))) <> 'REJECTED'
					AND
					MPLPaid.RowStatus = 1
			INNER JOIN
				[DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
				ON
					Mmshp.CustomerId = Cu.IdCustomer
					AND
					ISNULL(Cu.RowSatus,1) = 1
			INNER JOIN
				[DeliveryBackOffice].[dbo].[CustomerType] CT WITH(NOLOCK)
				ON
					Cu.IdCustomerType = CT.IdCustomerType
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[Account] Acc WITH(NOLOCK)
				ON
					Mmshp.AccountId = Acc.AccIdAccount
					AND
					ISNULL(Acc.AccRowStatus,1) = 1
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[CustomerPaymentValue] CPV WITH(NOLOCK)
				ON
					Mmshp.CustomerPaymentId = CPV.IdCustomerPaymentValue
					AND
					CPV.RowStatus = 1
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[CatConditionOfPayment] CCOP WITH(NOLOCK)
				ON
					Cu.ConditionOfPaymentID = CCOP.IdConditionOfPayment
					AND
					CCOP.RowStatus = 1
		WHERE
			Mmshp.CatMembershipStatusId NOT IN (@VoidStatus)
			AND
			(CPV.IdCustomerPaymentValue IS NOT NULL OR CCOP.ConditionOfPaymenAbbreviation LIKE 'CREDITO%')
			AND
			(MPLPaid.IdMembershipPaymentLog IS NULL OR Mmshp.CatMembershipStatusId = @InactiveStatus OR GETDATE() >= Mmshp.ExpirationDate )
			AND
			Cu.IdCustomerType = @CorporateCustomer
			AND
			Mmshp.IsAutoRenewable = 1
			AND
			Mmshp.RowStatus = 1

	END
	/*ELSE IF (@TypeProcess = 'SUBSCRIPTION' COLLATE Latin1_General_CI_AI)
	BEGIN

		-- Subscripciones
		-- Clientes individuales
		SELECT
			Sbsctptn.IdSubscription 'SalePackageId'
			,CS.SubscriptionName 'CatalogSalePackageId'
			,CONCAT('SP', RIGHT(CONCAT('000000000000000000',RIGHT(YEAR(GETDATE()), 2), RIGHT(CONCAT('00',DATEPART(DAY, GETDATE())),2),Sbsctptn.IdSubscription,RIGHT(CONCAT('00',ISNULL((
				SELECT
					COUNT(1)
				FROM
					[DeliveryBackOffice].[dbo].[SubscriptionPaymentLog] SPLRejects WITH(NOLOCK)
				WHERE
					SPLRejects.SubscriptionId = Sbsctptn.IdSubscription
					AND
					SPLRejects.DateCreated >= ISNULL(Sbsctptn.LastPaymentDate, Sbsctptn.DateCreated) 
					AND
					LTRIM(RTRIM(ISNULL(SPLRejects.[TransactionOrder],''))) = 'REJECTED' COLLATE Latin1_General_CI_AI
					AND
					SPLRejects.RowStatus = 1
			),0)),1)),12)) 'SalePackageReference'
			,Sbsctptn.SubscriptionCost 'SalePackageCost'
			,Mmbrshp.InvoiceEmail 'LinkedEmail'
			,Sbsctptn.CustomerId 'CustomerId'
			,Sbsctptn.AccountId 'AccountId'
			,Mmbrshp.InvoiceName
			,Mmbrshp.TaxIdNumber
			,Mmbrshp.InvoiceEmail
			,Mmbrshp.FiscalAddress
			,CT.[Description] 'CustomerType'
			,'CARD' 'PaymentType'
			,CPV.TokenizedToken
			,CPV.TokenizedExpirationDate
			,CPV.TokenizedCVV
			,CPV.[Type] 'CardType'
			,ISNULL((
				SELECT
					COUNT(1)
				FROM
					[DeliveryBackOffice].[dbo].[SubscriptionPaymentLog] SPLRejects WITH(NOLOCK)
				WHERE
					SPLRejects.SubscriptionId = Sbsctptn.IdSubscription
					AND
					SPLRejects.DateCreated >= ISNULL(Sbsctptn.LastPaymentDate, Sbsctptn.DateCreated)
					AND
					LTRIM(RTRIM(ISNULL(SPLRejects.[TransactionOrder],''))) = 'REJECTED' COLLATE Latin1_General_CI_AI
					AND
					SPLRejects.RowStatus = 1
			),0) 'RenewalAttempts'
			,FORMAT(Sbsctptn.LastPaymentDate,'MMyy') 'LastMonth'
			,FORMAT(DATEADD(DAY,CS.SubscriptionValidity,Sbsctptn.LastPaymentDate),'MMyy') 'RecentMonth'
			,@SystemId 'System'
			,Sbsctptn.CatSubscriptionId 'CatalogSalePackageAsInt'
		FROM
			[DeliveryBackOffice].[dbo].[Subscription] Sbsctptn WITH(NOLOCK)
			INNER JOIN
				[DeliveryBackOffice].[dbo].[CatSubscription] CS WITH(NOLOCK)
				ON
					Sbsctptn.CatSubscriptionId = CS.IdCatSubscription
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[Membership] Mmbrshp WITH(NOLOCK)
				ON
					Sbsctptn.MembershipId = Mmbrshp.IdMembership
					AND
					Mmbrshp.RowStatus = 1
					AND
					Mmbrshp.CatMembershipStatusId = @ActiveStatus
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[SubscriptionPaymentLog] SPLPaid WITH(NOLOCK)
				ON
					Sbsctptn.IdSubscription = SPLPaid.SubscriptionId
					AND
					SPLPaid.DateCreated BETWEEN CAST(CAST(ISNULL(Sbsctptn.LastPaymentDate, Sbsctptn.DateCreated) AS DATE) AS DATETIME) AND Sbsctptn.ExpirationDate
					AND
					LTRIM(RTRIM(ISNULL(SPLPaid.[TransactionOrder],''))) <> 'REJECTED'
					AND
					SPLPaid.RowStatus = 1
			INNER JOIN
				[DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
				ON
					Sbsctptn.CustomerId = Cu.IdCustomer
					AND
					ISNULL(Cu.RowSatus,1) = 1
			INNER JOIN
				[DeliveryBackOffice].[dbo].[CustomerType] CT WITH(NOLOCK)
				ON
					Cu.IdCustomerType = CT.IdCustomerType
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[Account] Acc WITH(NOLOCK)
				ON
					Sbsctptn.AccountId = Acc.AccIdAccount
					AND
					ISNULL(Acc.AccRowStatus,1) = 1
			INNER JOIN
				[DeliveryBackOffice].[dbo].[CustomerPaymentValue] CPV WITH(NOLOCK)
				ON
					Sbsctptn.CustomerPaymentId = CPV.IdCustomerPaymentValue
					AND
					CPV.RowStatus = 1
		WHERE
			Sbsctptn.CatSubscriptionStatusId NOT IN (@VoidStatus)
			AND
			Mmbrshp.IdMembership IS NOT NULL
			AND
			Sbsctptn.CustomerPaymentId IS NOT NULL
			AND
			(SPLPaid.IdSubscriptionPaymentLog IS NULL OR Sbsctptn.CatSubscriptionStatusId = @InactiveStatus OR GETDATE() >= Sbsctptn.ExpirationDate )
			AND
			Cu.IdCustomerType = @IndividualCustomer
			AND
			Sbsctptn.IsAutoRenewable = 1
			AND
			Sbsctptn.RowStatus = 1
		UNION
		-- Clientes corporativos
		SELECT
			Sbsctptn.IdSubscription 'SalePackageId'
			,CS.SubscriptionName 'CatalogSalePackageId'
			,CONCAT('SP', RIGHT(CONCAT('000000000000000000',RIGHT(YEAR(GETDATE()), 2), RIGHT(CONCAT('00',DATEPART(DAY, GETDATE())),2),Sbsctptn.IdSubscription,RIGHT(CONCAT('00',ISNULL((
				SELECT
					COUNT(1)
				FROM
					[DeliveryBackOffice].[dbo].[SubscriptionPaymentLog] SPLRejects WITH(NOLOCK)
				WHERE
					SPLRejects.SubscriptionId = Sbsctptn.IdSubscription
					AND
					SPLRejects.DateCreated >= ISNULL(Sbsctptn.LastPaymentDate, Sbsctptn.DateCreated) 
					AND
					LTRIM(RTRIM(ISNULL(SPLRejects.[TransactionOrder],''))) = 'REJECTED' COLLATE Latin1_General_CI_AI
					AND
					SPLRejects.RowStatus = 1
			),0)),1)),12)) 'SalePackageReference'
			,Sbsctptn.SubscriptionCost 'SalePackageCost'
			,Mmbrshp.InvoiceEmail 'LinkedEmail'
			,Sbsctptn.CustomerId 'CustomerId'
			,Sbsctptn.AccountId 'AccountId'
			,Mmbrshp.InvoiceName
			,Mmbrshp.TaxIdNumber
			,Mmbrshp.InvoiceEmail
			,Mmbrshp.FiscalAddress
			,CT.[Description] 'CustomerType'
			,IIF(CPV.IdCustomerPaymentValue IS NULL AND CCOP.IdConditionOfPayment IS NOT NULL, 'CRED', 'CARD') 'PaymentType'
			,CPV.TokenizedToken
			,CPV.TokenizedExpirationDate
			,CPV.TokenizedCVV
			,CPV.[Type] 'CardType'
			,ISNULL((
				SELECT
					COUNT(1)
				FROM
					[DeliveryBackOffice].[dbo].[SubscriptionPaymentLog] SPLRejects WITH(NOLOCK)
				WHERE
					SPLRejects.SubscriptionId = Sbsctptn.IdSubscription
					AND
					SPLRejects.DateCreated >= ISNULL(Sbsctptn.LastPaymentDate, Sbsctptn.DateCreated) 
					AND
					LTRIM(RTRIM(ISNULL(SPLRejects.[TransactionOrder],''))) = 'REJECTED' COLLATE Latin1_General_CI_AI
					AND
					SPLRejects.RowStatus = 1
			),0) 'RenewalAttempts'
			,FORMAT(Sbsctptn.LastPaymentDate,'MMyy') 'LastMonth'
			,FORMAT(DATEADD(DAY,CS.SubscriptionValidity,Sbsctptn.LastPaymentDate),'MMyy') 'RecentMonth'
			,@SystemId 'System'
			,Sbsctptn.CatSubscriptionId 'CatalogSalePackageAsInt'
		FROM
			[DeliveryBackOffice].[dbo].[Subscription] Sbsctptn WITH(NOLOCK)
			INNER JOIN
				[DeliveryBackOffice].[dbo].[CatSubscription] CS WITH(NOLOCK)
				ON
					Sbsctptn.CatSubscriptionId = CS.IdCatSubscription
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[Membership] Mmbrshp WITH(NOLOCK)
				ON
					Sbsctptn.MembershipId = Mmbrshp.IdMembership
					AND
					Mmbrshp.RowStatus = 1
					AND
					Mmbrshp.CatMembershipStatusId = @ActiveStatus
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[SubscriptionPaymentLog] SPLPaid WITH(NOLOCK)
				ON
					Sbsctptn.IdSubscription = SPLPaid.SubscriptionId
					AND
					SPLPaid.DateCreated BETWEEN CAST(CAST(ISNULL(Sbsctptn.LastPaymentDate, Sbsctptn.DateCreated) AS DATE) AS DATETIME) AND Sbsctptn.ExpirationDate
					AND
					LTRIM(RTRIM(ISNULL(SPLPaid.[TransactionOrder],''))) <> 'REJECTED'
					AND
					SPLPaid.RowStatus = 1
			INNER JOIN
				[DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
				ON
					Sbsctptn.CustomerId = Cu.IdCustomer
					AND
					ISNULL(Cu.RowSatus,1) = 1
			INNER JOIN
				[DeliveryBackOffice].[dbo].[CustomerType] CT WITH(NOLOCK)
				ON
					Cu.IdCustomerType = CT.IdCustomerType
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[Account] Acc WITH(NOLOCK)
				ON
					Sbsctptn.AccountId = Acc.AccIdAccount
					AND
					ISNULL(Acc.AccRowStatus,1) = 1
			INNER JOIN
				[DeliveryBackOffice].[dbo].[CustomerPaymentValue] CPV WITH(NOLOCK)
				ON
					Sbsctptn.CustomerPaymentId = CPV.IdCustomerPaymentValue
					AND
					CPV.RowStatus = 1
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[CatConditionOfPayment] CCOP WITH(NOLOCK)
				ON
					Cu.ConditionOfPaymentID = CCOP.IdConditionOfPayment
					AND
					CCOP.RowStatus = 1
		WHERE
			Sbsctptn.CatSubscriptionStatusId NOT IN (@VoidStatus)
			AND
			(CPV.IdCustomerPaymentValue IS NOT NULL OR CCOP.ConditionOfPaymenAbbreviation LIKE 'CREDITO%')
			AND
			Mmbrshp.IdMembership IS NOT NULL
			AND
			(SPLPaid.IdSubscriptionPaymentLog IS NULL OR Sbsctptn.CatSubscriptionStatusId = @InactiveStatus OR GETDATE() >= Sbsctptn.ExpirationDate )
			AND
			Cu.IdCustomerType = @CorporateCustomer
			AND
			Sbsctptn.IsAutoRenewable = 1
			AND
			Sbsctptn.RowStatus = 1

	END*/


END
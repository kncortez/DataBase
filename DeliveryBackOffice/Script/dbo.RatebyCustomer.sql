
DECLARE @NewMainRates INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifario de servicio estandar' COLLATE Latin1_General_CI_AI);
DECLARE @NewAlternativeRates INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifario destinos express center' COLLATE Latin1_General_CI_AI);

DECLARE @IndividualCustomerId INT = (SELECT TOP 1 CT.IdCustomerType FROM [DeliveryBackOffice].[dbo].[CustomerType] CT WITH(NOLOCK) WHERE CT.[Description] = 'INDIVIDUAL' COLLATE Latin1_General_CI_AI)
DECLARE @ProviderCustomerId INT = (SELECT TOP 1 CT.IdCustomerType FROM [DeliveryBackOffice].[dbo].[CustomerType] CT WITH(NOLOCK) WHERE CT.[Description] = 'REDISTRIBUIDOR' COLLATE Latin1_General_CI_AI)

-- Actualizar clientes existentes con nueva tarifa principal
UPDATE [DeliveryBackOffice].[dbo].[RatebyCustomer]
SET
	RbcIdRate = @NewMainRates
	,RbcTokenUpdated = 'SYS-ARUIZ'
	,RbcDateUpdated = GETDATE()
WHERE
	RbcId IN (
		SELECT
			DISTINCT
				RBC.RbcId
		FROM
			[DeliveryBackOffice].[dbo].[RatebyCustomer] RBC WITH(NOLOCK)
			INNER JOIN
				[DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
				ON
					RBC.RbcIdCustomer = Cu.IdCustomer
					AND
					Cu.IdCustomerType = @IndividualCustomerId
);

UPDATE [DeliveryBackOffice].[dbo].[RatebyCustomer]
SET
	RbcIdRate = @NewAlternativeRates
	,RbcTokenUpdated = 'SYS-ARUIZ'
	,RbcDateUpdated = GETDATE()
WHERE
	RbcId IN (
		SELECT
			DISTINCT
				RBC.RbcId
		FROM
			[DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH(NOLOCK)
			INNER JOIN
				[DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
				ON
					VPC.CustomerID = Cu.IdCustomer
					AND
					Cu.IdCustomerType = @ProviderCustomerId
			INNER JOIN
				[DeliveryBackOffice].[dbo].[RatebyCustomer] RBC WITH(NOLOCK)
				ON
					Cu.IdCustomer = RBC.RbcIdCustomer
		WHERE
			VPC.DescriptionOfClient LIKE 'FD%EXC%'
)

-- Ingresar usuarios individuales a tarifas alternas
INSERT INTO [DeliveryBackOffice].[dbo].[AlternativeRatebyCustomer]
	(RateId, CustomerId, RowStatus, TokenCreated, DateCreated)
SELECT
	DISTINCT
		@NewAlternativeRates, RbcIdCustomer, 1, 'SYS-ARUIZ', GETDATE()
FROM
	[DeliveryBackOffice].[dbo].[RatebyCustomer] RBC WITH(NOLOCK)
	INNER JOIN
		[DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
		ON
			RBC.RbcIdCustomer = Cu.IdCustomer
			AND
			Cu.IdCustomerType = @IndividualCustomerId

-- Ingresar usuarios Express center a tarifas alternas
INSERT INTO [DeliveryBackOffice].[dbo].[AlternativeRatebyCustomer]
	(RateId, CustomerId, RowStatus, TokenCreated, DateCreated)
SELECT
	DISTINCT
		@NewAlternativeRates, RbcIdCustomer, 1, 'SYS-ARUIZ', GETDATE()
FROM
	[DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH(NOLOCK)
	INNER JOIN
		[DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
		ON
			VPC.CustomerID = Cu.IdCustomer
			AND
			Cu.IdCustomerType = @ProviderCustomerId
	INNER JOIN
		[DeliveryBackOffice].[dbo].[RatebyCustomer] RBC WITH(NOLOCK)
		ON
			Cu.IdCustomer = RBC.RbcIdCustomer
WHERE
	VPC.DescriptionOfClient LIKE 'FD%EXC%'
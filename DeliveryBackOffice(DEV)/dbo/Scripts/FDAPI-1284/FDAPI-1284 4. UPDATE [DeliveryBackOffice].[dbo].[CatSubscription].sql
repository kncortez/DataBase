
DECLARE @TarifaPlanBasico INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifa suscripción Plan Básico' COLLATE Latin1_General_CI_AI);
DECLARE @TarifaPlanBasicoPlus INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifa suscripción Plan Básico Plus' COLLATE Latin1_General_CI_AI);
DECLARE @TarifaPlanGold INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifa suscripción Plan Gold' COLLATE Latin1_General_CI_AI);
DECLARE @TarifaPlanCorporativo INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifa suscripción Plan Corporativo' COLLATE Latin1_General_CI_AI);
	
DECLARE @TarifaPlanBasicoAlt INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifa suscripción Plan Básico destinos express center' COLLATE Latin1_General_CI_AI);
DECLARE @TarifaPlanBasicoPlusAlt INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifa suscripción Plan Básico Plus destinos express center' COLLATE Latin1_General_CI_AI);
DECLARE @TarifaPlanGoldAlt INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifa suscripción Plan Gold destinos express center' COLLATE Latin1_General_CI_AI);
DECLARE @TarifaPlanCorporativoAlt INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifa suscripción Plan Corporativo destinos express center' COLLATE Latin1_General_CI_AI);
	
/*
Plan Básico
Plan Básico +
Plan Gold
Plan Corporativo
*/

UPDATE 
	[DeliveryBackOffice].[dbo].[CatSubscription]
SET
	RateHeaderId = @TarifaPlanBasico
	,AlternativeRateHeaderId = @TarifaPlanBasicoAlt
	,TokenUpdated = 'SYS-ARUIZ'
	,DateUpdated = GETDATE()
WHERE
	SubscriptionName = 'Plan Básico'


UPDATE
	[DeliveryBackOffice].[dbo].[CatSubscription]
SET
	RateHeaderId = @TarifaPlanBasicoPlus
	,AlternativeRateHeaderId = @TarifaPlanBasicoPlusAlt
	,TokenUpdated = 'SYS-ARUIZ'
	,DateUpdated = GETDATE()
WHERE
	SubscriptionName = 'Plan Básico +'


UPDATE
	[DeliveryBackOffice].[dbo].[CatSubscription]
SET
	RateHeaderId = @TarifaPlanGold
	,AlternativeRateHeaderId = @TarifaPlanGoldAlt
	,TokenUpdated = 'SYS-ARUIZ'
	,DateUpdated = GETDATE()
WHERE
	SubscriptionName = 'Plan Gold'


UPDATE
	[DeliveryBackOffice].[dbo].[CatSubscription]
SET
	RateHeaderId = @TarifaPlanCorporativo
	,AlternativeRateHeaderId = @TarifaPlanCorporativoAlt
	,TokenUpdated = 'SYS-ARUIZ'
	,DateUpdated = GETDATE()
WHERE
	SubscriptionName = 'Plan Corporativo'

UPDATE
	SBS
SET
	SBS.RateHeaderId = CS.RateHeaderId
	,SBS.AlternativeRateHeaderId = CS.AlternativeRateHeaderId
	,SBS.TokenUpdated = 'SYS-ARUIZ'
	,SBS.DateUpdated = GETDATE()
FROM
	[DeliveryBackOffice].[dbo].[Subscription] SBS WITH(NOLOCK)
	INNER JOIN
		[DeliveryBackOffice].[dbo].[CatSubscription] CS WITH(NOLOCK)
		ON
			SBS.CatSubscriptionId = CS.IdCatSubscription
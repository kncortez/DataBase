USE [DeliveryBackOffice]
GO

ALTER TABLE [DeliveryBackOffice].[dbo].[CatMembership]
ADD NextSalesPackageBanner NVARCHAR(200) NULL
GO

EXECUTE sp_addextendedproperty N'MS_Description', 'Nombre de banner a desplegar cuando servicios de monto fijo esten proximos a acabarse', N'SCHEMA', N'dbo', N'TABLE', N'CatMembership', N'COLUMN', N'NextSalesPackageBanner'
GO

ALTER TABLE [DeliveryBackOffice].[dbo].[CatSubscription]
ADD NextSalesPackageBanner NVARCHAR(200) NULL
GO

EXECUTE sp_addextendedproperty N'MS_Description', 'Nombre de banner a desplegar cuando servicios de monto fijo esten proximos a acabarse', N'SCHEMA', N'dbo', N'TABLE', N'CatSubscription', N'COLUMN', N'NextSalesPackageBanner'
GO

DECLARE @ClubForza INT = (SELECT TOP 1 CM.IdCatMembership FROM [DeliveryBackOffice].[dbo].[CatMembership] CM WITH(NOLOCK) WHERE CM.MembershipName = 'Club Forza' COLLATE Latin1_General_CI_AI)

DECLARE @PlanBasico INT = (SELECT TOP 1 CS.IdCatSubscription FROM [DeliveryBackOffice].[dbo].[CatSubscription] CS WITH(NOLOCK) WHERE CS.SubscriptionName = 'Plan Básico' COLLATE Latin1_General_CI_AI)
DECLARE @PlanBasicoPlus INT = (SELECT TOP 1 CS.IdCatSubscription FROM [DeliveryBackOffice].[dbo].[CatSubscription] CS WITH(NOLOCK) WHERE CS.SubscriptionName = 'Plan Básico +' COLLATE Latin1_General_CI_AI)
DECLARE @PlanGold INT = (SELECT TOP 1 CS.IdCatSubscription FROM [DeliveryBackOffice].[dbo].[CatSubscription] CS WITH(NOLOCK) WHERE CS.SubscriptionName = 'Plan Gold' COLLATE Latin1_General_CI_AI)
DECLARE @PlanCorporativo INT = (SELECT TOP 1 CS.IdCatSubscription FROM [DeliveryBackOffice].[dbo].[CatSubscription] CS WITH(NOLOCK) WHERE CS.SubscriptionName = 'Plan Corporativo' COLLATE Latin1_General_CI_AI)

UPDATE
	[DeliveryBackOffice].[dbo].[CatMembership]
SET
	NextSalesPackageBanner = 'bannerSubsPlan1.png'
WHERE
	IdCatMembership = @ClubForza;
	
UPDATE
	[DeliveryBackOffice].[dbo].[CatSubscription]
SET
	NextSalesPackageBanner = 'bannerSubsPlan2.png'
WHERE
	IdCatSubscription = @PlanBasico;
	
UPDATE
	[DeliveryBackOffice].[dbo].[CatSubscription]
SET
	NextSalesPackageBanner = 'bannerSubsPlan3.png'
WHERE
	IdCatSubscription = @PlanBasicoPlus;
	
UPDATE
	[DeliveryBackOffice].[dbo].[CatSubscription]
SET
	NextSalesPackageBanner = 'bannerSubsPlan4.png'
WHERE
	IdCatSubscription = @PlanGold;
	
UPDATE
	[DeliveryBackOffice].[dbo].[CatSubscription]
SET
	NextSalesPackageBanner = 'bannerFinal.png'
WHERE
	IdCatSubscription = @PlanCorporativo;
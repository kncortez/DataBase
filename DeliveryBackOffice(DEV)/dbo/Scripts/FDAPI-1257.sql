-- FDAPI - 1257

UPDATE	[dbo].[CatMembership] 
SET		[Icon] = 'hwa-membershipIcon', 
		[TokenUpdated] = 'SYS-JOCHOA',
		[DateUpdated] = SYSDATETIME()
WHERE	[RowStatus] = 1;

UPDATE	[dbo].[CatSubscription]
SET		[Icon] = 'hwa-planBasicoIcon',
		[TokenUpdated] = 'SYS-JOCHOA',
		[DateUpdated] = SYSDATETIME()
WHERE	[SubscriptionName] = 'Plan Básico';

UPDATE	[dbo].[CatSubscription]
SET		[Icon] = 'hwa-planBasicoPlusIcon',
		[TokenUpdated] = 'SYS-JOCHOA',
		[DateUpdated] = SYSDATETIME()
WHERE	[SubscriptionName] = 'Plan Básico +';

UPDATE	[dbo].[CatSubscription]
SET		[Icon] = 'hwa-planGoldIcon',
		[TokenUpdated] = 'SYS-JOCHOA',
		[DateUpdated] = SYSDATETIME()
WHERE	[SubscriptionName] = 'Plan Gold';

UPDATE	[dbo].[CatSubscription]
SET		[Icon] = 'hwa-planCorporateIcon',
		[TokenUpdated] = 'SYS-JOCHOA',
		[DateUpdated] = SYSDATETIME()
WHERE	[SubscriptionName] = 'Plan Corporativo';
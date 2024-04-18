--Actualización de precio de paquetes
UPDATE [dbo].[CatSubscription]
SET SubscriptionCost = 1550,
TokenUpdated='SYS-EVASQUEZ',
	  DateUpdated=GETDATE() 
WHERE SubscriptionName = 'Paquete Básico'
And RowStatus=1

UPDATE [dbo].[CatSubscription]
SET SubscriptionCost = 2900,
TokenUpdated='SYS-EVASQUEZ',
	  DateUpdated=GETDATE() 
WHERE SubscriptionName = 'Paquete Plus'
And RowStatus=1

UPDATE [dbo].[CatSubscription]
SET SubscriptionCost = 5400,
TokenUpdated='SYS-EVASQUEZ',
	  DateUpdated=GETDATE() 
WHERE SubscriptionName = 'Paquete Gold'
And RowStatus=1


UPDATE [dbo].[CatSubscription]
SET SubscriptionCost = 99,
TokenUpdated='SYS-EVASQUEZ',
	  DateUpdated=GETDATE() 
WHERE SubscriptionName = 'Plan Amigo'
And RowStatus=1
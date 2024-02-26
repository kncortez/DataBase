-- Modificar descripción
UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='25 envíos Q33.00 c/u',
TokenUpdated='SYS-EVASQUEZ',
	  DateUpdated=GETDATE()
where SubscriptionName='Paquete Petit'

--  Modificar descripción
UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='50 envíos Q31.00 c/u',
TokenUpdated='SYS-EVASQUEZ',
	  DateUpdated=GETDATE()
where SubscriptionName='Paquete Básico'

--  Modificar descripción
UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='100 envíos Q29.00 c/u',
TokenUpdated='SYS-EVASQUEZ',
	  DateUpdated=GETDATE()
where SubscriptionName='Paquete Plus'

--  Modificar descripción
UPDATE [dbo].[CatSubscription]
SET  SubscriptionDescription ='200 envíos Q27.00 c/u',
TokenUpdated='SYS-EVASQUEZ',
	  DateUpdated=GETDATE()
where SubscriptionName='Paquete Gold'

--  Modificar descripción
UPDATE [dbo].[CatSubscription]
SET  SubscriptionDescription ='400 envíos Q25.00 c/u',
TokenUpdated='SYS-EVASQUEZ',
	  DateUpdated=GETDATE()
where SubscriptionName='Paquete Platino'
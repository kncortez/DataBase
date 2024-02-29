--Actualziación de precio de paquetes
UPDATE [dbo].[CatSubscription]
SET SubscriptionCost = 1550
WHERE SubscriptionName = 'Paquete Básico'

UPDATE [dbo].[CatSubscription]
SET SubscriptionCost = 2900
WHERE SubscriptionName = 'Paquete Plus'

UPDATE [dbo].[CatSubscription]
SET SubscriptionCost = 5400
WHERE SubscriptionName = 'Paquete Gold'
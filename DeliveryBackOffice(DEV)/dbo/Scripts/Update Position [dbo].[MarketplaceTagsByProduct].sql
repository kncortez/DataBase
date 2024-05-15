--Posición Paquete Petit
UPDATE MTP  
SET Position = 2
FROM [dbo].[MarketplaceTagsByProduct]   MTP
INNER JOIN 
[dbo].[CatSubscription] CS
ON MTP.CatSubscriptionId = CS.IdCatSubscription
WHERE  CS.SubscriptionName ='Paquete Petit'

--Posición Paquete Básico
UPDATE MTP 
SET Position = 3
FROM [dbo].[MarketplaceTagsByProduct]   MTP
INNER JOIN 
[dbo].[CatSubscription] CS
ON MTP.CatSubscriptionId = CS.IdCatSubscription
WHERE  CS.SubscriptionName ='Paquete Básico'
--Posición Paquete Gold
UPDATE MTP  
SET Position = 4
FROM [dbo].[MarketplaceTagsByProduct]   MTP
INNER JOIN 
[dbo].[CatSubscription] CS
ON MTP.CatSubscriptionId = CS.IdCatSubscription
WHERE  CS.SubscriptionName ='Paquete Gold'
--Posición Paquete Platino
UPDATE MTP  
SET Position = 5
FROM [dbo].[MarketplaceTagsByProduct]   MTP
INNER JOIN 
[dbo].[CatSubscription] CS
ON MTP.CatSubscriptionId = CS.IdCatSubscription
WHERE  CS.SubscriptionName ='Paquete Platino'

-- Posición Paquete Plus 
UPDATE MTP  
SET Position = 6
FROM [dbo].[MarketplaceTagsByProduct]   MTP
INNER JOIN 
[dbo].[CatSubscription] CS
ON MTP.CatSubscriptionId = CS.IdCatSubscription
WHERE  CS.SubscriptionName ='Paquete Plus'
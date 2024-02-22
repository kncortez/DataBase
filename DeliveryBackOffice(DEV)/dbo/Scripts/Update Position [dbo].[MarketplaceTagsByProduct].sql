--Posición Paquete Petit
UPDATE  [dbo].[MarketplaceTagsByProduct]
SET Position = 2
WHERE  CatSubscriptionId = 18
--Posición Paquete Básico
UPDATE  [dbo].[MarketplaceTagsByProduct]
SET Position = 3
WHERE  CatSubscriptionId = 9
--Posición Paquete Gold
UPDATE  [dbo].[MarketplaceTagsByProduct]
SET Position = 4
WHERE  CatSubscriptionId = 11
--Posición Paquete Platino
UPDATE  [dbo].[MarketplaceTagsByProduct]
SET Position = 5
WHERE  CatSubscriptionId = 19

-- Posición Paquete Plus 
UPDATE  [dbo].[MarketplaceTagsByProduct]
SET Position = 6
WHERE  CatSubscriptionId = 10
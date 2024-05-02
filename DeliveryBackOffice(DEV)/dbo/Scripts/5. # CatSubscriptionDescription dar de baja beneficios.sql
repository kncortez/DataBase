DECLARE @IdProduct INT = 0
SELECT @IdProduct = IdCatSubscription FROM DeliveryBackOffice.dbo.CatSubscription
WHERE SubscriptionName LIKE '%Plan Amigo%'
AND RowStatus = 1

PRINT @IdProduct

SELECT * FROM DeliveryBackOffice.dbo.CatSubscription
WHERE SubscriptionName LIKE '%Plan Amigo%'
AND RowStatus = 1

UPDATE DeliveryBackOffice.dbo.CatSubscription
SET SubscriptionCost = 99 --antes 100
,TokenUpdated = 'SYS-BHERRERA'
,DateUpdated = GETDATE()
WHERE SubscriptionName LIKE '%Plan Amigo%'
AND RowStatus = 1

SELECT * FROM DeliveryBackOffice.dbo.CatSubscriptionAtribute
WHERE CatSubscriptionId = @IdProduct
AND RowStatus =1

--Inhabilitar Acumulación de puntos
update DeliveryBackOffice.dbo.CatSubscriptionAtribute
SET RowStatus = 0
,TokenUpdated = 'SYS-BHERRERA'
,DateUpdated = GETDATE()
WHERE CatSubscriptionId = @IdProduct
AND SubscriptionAttributeDescription LIKE '%Acumulación de puntos para envíos gratis.%'
AND RowStatus =1






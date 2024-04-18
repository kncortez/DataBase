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

SELECT * FROM DeliveryBackOffice.dbo.CatSubscriptionDescription
WHERE CatSubscriptionId = @IdProduct
AND RowStatus =1

--Quitar de descripción Acumulaciónn de puntos
--backup Descuento del 10% en env�os a nivel nacional sobre tarifa vigente.;  Acumulación de puntos para envíos gratis.;  Precio de acuerdo a tipo de servicio y destino.;  Desde la primer gu�a, de acuerdo al consumo.;  Permite servicio Collect Q 4.00;  Hasta 10 libras.;  +3.8% C.O.D. con "Acreditamiento Inmediato".;  +Q 1.00 libra extra.
update dbo.CatSubscriptionDescription
SET Description = 'Descuento del 10% en envíos a nivel nacional sobre tarifa vigente.;Precio de acuerdo a tipo de servicio y destino.;  Desde la primer guía, de acuerdo al consumo.;  Permite servicio Collect Q 4.00;  Hasta 10 libras.;  +3.8% C.O.D. con "Acreditamiento Inmediato".;  +Q 1.00 libra extra.'
,TokenUpdated = 'SYS-BHERRERA'
,DateUpdated = GETDATE()
WHERE CatSubscriptionId = @IdProduct
AND Title = 'Beneficios'
AND RowStatus =1



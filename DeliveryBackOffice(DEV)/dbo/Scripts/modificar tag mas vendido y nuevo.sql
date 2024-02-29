--  incluir el cintillo Más Vendido
UPDATE [dbo].[CatSubscription]
SET Tag='MÁS VENDIDO'
where SubscriptionName='Plan Amigo'
AND RowStatus=1

--  quitar cintillo Nuevo e incluir el cintillo de Mas vendido
UPDATE [dbo].[CatSubscription]
SET Tag='MÁS VENDIDO'
where SubscriptionName='Paquete Básico'
AND RowStatus=1

--  incluir el cintillo de Nuevo
UPDATE [dbo].[CatSubscription]
SET Tag='MÁS VENDIDO'
where SubscriptionName='Paquete Petit'
AND RowStatus=1

-- , incluir el cintillo de Nuevo
UPDATE [dbo].[CatSubscription]
SET Tag='NOVEDADES'
where SubscriptionName='Paquete Platino'
AND RowStatus=1



-- quitar cintillo del mas vendido
UPDATE [dbo].[CatSubscription]
SET Tag=NULL
where SubscriptionName='Paquete Plus'
AND RowStatus=1

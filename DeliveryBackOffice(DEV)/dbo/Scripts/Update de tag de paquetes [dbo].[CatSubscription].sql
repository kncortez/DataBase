-- quitar cintillo del mas vendido
UPDATE [dbo].[CatSubscription]
SET Tag=NULL
where SubscriptionName='Paquete Plus'
--  quitar cintillo Nuevo e incluir el cintillo de Mas vendido
UPDATE [dbo].[CatSubscription]
SET Tag='MÁS VENDIDO'
where SubscriptionName='Paquete Básico'

--  incluir el cintillo de Nuevo
UPDATE [dbo].[CatSubscription]
SET Tag='NUEVO'
where SubscriptionName='Paquete Petit'

-- , incluir el cintillo de Nuevo
UPDATE [dbo].[CatSubscription]
SET Tag='NUEVO'
where SubscriptionName='Paquete Platino'

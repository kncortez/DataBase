-- quitar cintillo del mas vendido
UPDATE [dbo].[CatSubscription]
SET Tag=NULL,
TokenUpdated='SYS-EVASQUEZ',
	  DateUpdated=GETDATE()
where SubscriptionName='Paquete Plus'

--  quitar cintillo Nuevo e incluir el cintillo de Mas vendido
UPDATE [dbo].[CatSubscription]
SET Tag='MÁS VENDIDO',
TokenUpdated='SYS-EVASQUEZ',
	  DateUpdated=GETDATE()
where SubscriptionName='Paquete Básico'

--  incluir el cintillo de Nuevo
UPDATE [dbo].[CatSubscription]
SET Tag='NUEVO',
TokenUpdated='SYS-EVASQUEZ',
	  DateUpdated=GETDATE()
where SubscriptionName='Paquete Petit'

-- , incluir el cintillo de Nuevo
UPDATE [dbo].[CatSubscription]
SET Tag='NUEVO',
TokenUpdated='SYS-EVASQUEZ',
	  DateUpdated=GETDATE()
where SubscriptionName='Paquete Platino'
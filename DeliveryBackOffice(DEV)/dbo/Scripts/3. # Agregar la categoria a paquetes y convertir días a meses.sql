USE DeliveryBackOffice
GO
--SE AGREGA LA CATEGORIA A CADA PAQUETE
DECLARE @IdCategory INT =(select idcatProductCategory from dbo.CatProductCategory where CatProductCategoryName='Guías Prepago')
Update [dbo].[CatSubscription] SET
	[CatProductCategoryId]=@IdCategory,
	TokenUpdated='SYS-EVASQUEZ',
	  DateUpdated=GETDATE() 
WHERE rowstatus=1
and SubscriptionName in (
'Paquete Básico',
'Paquete Plus',
'Paquete Gold',
'Paquete Petit',
'Paquete Platino'
)

--ACTUALIZACIÓN PARA CONVERTIR DIAS A MESES
UPDATE [dbo].[CatSubscription]

SET SubscriptionValidity = (SubscriptionValidity / 30),
TokenUpdated='SYS-EVASQUEZ',
	  DateUpdated=GETDATE()
WHERE MembershipValidity>=30


UPDATE [dbo].[CatMembership]
SET   MembershipValidity =(MembershipValidity / 30),
TokenUpdated='SYS-EVASQUEZ',
	  DateUpdated=GETDATE()
WHERE MembershipValidity>=30


	





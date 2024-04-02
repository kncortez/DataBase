USE DeliveryBackOffice
GO
--SE AGREGA LA CATEGORIA A CADA PAQUETE Y MEMBRESÍA
DECLARE @IdCategoryPaquete INT =(select idcatProductCategory from dbo.CatProductCategory where CatProductCategoryName='Paquetes')
UPDATE [dbo].[CatSubscription] SET
	[CatProductCategoryId]=@IdCategoryPaquete
WHERE rowstatus=1
and SubscriptionName in (
'Paquete Básico',
'Paquete Plus',
'Paquete Gold',
'Paquete Petit',
'Paquete Platino'
)

DECLARE @IdCategoryPlan INT =(select idcatProductCategory from dbo.CatProductCategory where CatProductCategoryName='Planes')
UPDATE [dbo].[CatSubscription] SET
	[CatProductCategoryId]=@IdCategoryPlan 
WHERE rowstatus=1
and SubscriptionName in (
'Plan Amigo'
)


DECLARE @IdCategoryMembresia INT =(select idcatProductCategory from dbo.CatProductCategory where CatProductCategoryName='Membresías')
UPDATE [dbo].[CatMembership] SET
	[CatProductCategoryId]=@IdCategoryMembresia
where rowstatus=1
and MembershipName='Club Forza'


--ACTUALIZACIÓN PARA CONVERTIR DIAS A MESES
UPDATE [dbo].[CatSubscription]
SET SubscriptionValidity = (SubscriptionValidity / 30)

--ACTUALIZACIÓN PARA CONVERTIR DIAS A MESES
UPDATE [dbo].[CatMembership]
SET MembershipValidity = (MembershipValidity / 30)
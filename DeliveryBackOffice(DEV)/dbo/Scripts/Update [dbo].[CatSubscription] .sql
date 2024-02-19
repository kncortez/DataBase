USE DeliveryBackOffice
GO
--SE AGREGA LA CATEGORIA A CADA PAQUETE
DECLARE @IdCategory INT =(select idcatProductCategory from dbo.CatProductCategory where CatProductCategoryName='Paquetes')
Update [dbo].[CatSubscription] SET
	[CatProductCategoryId]=@IdCategory 
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
SET SubscriptionValidity = (SubscriptionValidity / 30)


/*  Actualizar Suscripciones y paquetes */
  -- PAQUETE PETIT
  -- PAQUETE BASICO
  -- PLUS
  -- GOLD
  -- PLATINO
  -- PRO

DECLARE @IdCatSubscriptionPETIT INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete Petit' AND IdCountry='GT')
DECLARE @IdCatSubscriptionBASICO INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete Básico' AND IdCountry='GT')
DECLARE @IdCatSubscriptionPLUS INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete Plus' AND IdCountry='GT')
DECLARE @IdCatSubscriptionGOLD INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete Gold' AND IdCountry='GT')
DECLARE @IdCatSubscriptionPLATINO INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete Platino' AND IdCountry='GT')
DECLARE @IdCatSubscriptionPRO INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete Pro' AND IdCountry='GT')

/*Actualizar Precio en Catálogo*/

UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='25 guias a Q34 C/U',
    SubscriptionCost=850.00
WHERE  IdCatSubscription = @IdCatSubscriptionPETIT AND  IdCountry='GT'

UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='50 guias a Q32 C/U',
    SubscriptionCost=1600.00
WHERE  IdCatSubscription = @IdCatSubscriptionBASICO AND  IdCountry='GT'

UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='100 guias a Q30 C/U',
    SubscriptionCost=3000.00
WHERE  IdCatSubscription = @IdCatSubscriptionPLUS AND  IdCountry='GT'

UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='200 guias a Q28 C/U',
    SubscriptionCost=5600.00
WHERE  IdCatSubscription = @IdCatSubscriptionGOLD  AND  IdCountry='GT'

UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='400 guias a Q24 C/U',
    SubscriptionCost=9600.00
WHERE  IdCatSubscription = @IdCatSubscriptionPLATINO  AND  IdCountry='GT'


UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='500 guias a Q22 C/U',
    SubscriptionCost=11000.00
WHERE  IdCatSubscription = @IdCatSubscriptionPRO  AND  IdCountry='GT'

/*Actualizar rango de descuento*/

UPDATE  [dbo].[CatSubscriptionDiscountRange]
SET DiscountLowServiceRange =500
WHERE  CatSubscriptionId = @IdCatSubscriptionPRO

/*Actualizar Suscripción*/




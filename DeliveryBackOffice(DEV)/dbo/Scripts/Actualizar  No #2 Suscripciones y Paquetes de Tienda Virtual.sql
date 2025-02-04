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
    SubscriptionCost=850.00,
	DateUpdated=GETDATE(),
	TokenUpdated='SYS-EVASQUEZ'
WHERE  IdCatSubscription = @IdCatSubscriptionPETIT AND  IdCountry='GT'

UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='50 guias a Q32 C/U',
    SubscriptionCost=1600.00,
	DateUpdated=GETDATE(),
	TokenUpdated='SYS-EVASQUEZ'
WHERE  IdCatSubscription = @IdCatSubscriptionBASICO AND  IdCountry='GT'

UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='100 guias a Q30 C/U',
    SubscriptionCost=3000.00,
	DateUpdated=GETDATE(),
	TokenUpdated='SYS-EVASQUEZ'
WHERE  IdCatSubscription = @IdCatSubscriptionPLUS AND  IdCountry='GT'

UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='200 guias a Q28 C/U',
    SubscriptionCost=5600.00,
	DateUpdated=GETDATE(),
	TokenUpdated='SYS-EVASQUEZ'
WHERE  IdCatSubscription = @IdCatSubscriptionGOLD  AND  IdCountry='GT'

UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='400 guias a Q24 C/U',
    SubscriptionCost=9600.00,
	DateUpdated=GETDATE(),
	TokenUpdated='SYS-EVASQUEZ'
WHERE  IdCatSubscription = @IdCatSubscriptionPLATINO  AND  IdCountry='GT'


UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='500 guias a Q22 C/U',
    SubscriptionCost=11000.00,
	DateUpdated=GETDATE(),
	TokenUpdated='SYS-EVASQUEZ'
WHERE  IdCatSubscription = @IdCatSubscriptionPRO  AND  IdCountry='GT'

/*Actualizar rango de descuento*/

UPDATE  [dbo].[CatSubscriptionDiscountRange]
SET DiscountLowServiceRange =500,
    DateUpdated=GETDATE(),
	TokenUpdated='SYS-EVASQUEZ'
WHERE  CatSubscriptionId = @IdCatSubscriptionPRO

/*Actualizar Suscripción*/


UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico.
Prepara tus paquetes, completa la información de envío y entrégalos en las
+90 agencias express center o puedes solicitar la recolección a tu casa u
oficina. Rastrea el progreso del envío con el número de guía proporcionado
para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al
centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de
los detalles logísticos. Adquiere tu Paquete Petit y podrás obtener tus
guías prepagadas de 25 envíos con tarifa única a todo el país a Q34.00
c/u.',
    DateUpdated=GETDATE(),
	TokenUpdated='SYS-EVASQUEZ'
WHERE CatSubscriptionId = @IdCatSubscriptionPETIT AND RowStatus=1 AND Title='¿Cómo Funciona?'

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico.
Prepara tus paquetes, completa la información de envío y entrégalos en las
+90 agencias express center o puedes solicitar la recolección a tu casa u
oficina. Rastrea el progreso del envío con el número de guía proporcionado
para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al
centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de
los detalles logísticos. Adquiere tu Paquete Basico y podrás obtener tus
guías prepagadas de 50 envíos con tarifa única a todo el país a Q32.00
c/u.',
    DateUpdated=GETDATE(),
	TokenUpdated='SYS-EVASQUEZ'
WHERE CatSubscriptionId = @IdCatSubscriptionBASICO AND RowStatus=1 AND Title='¿Cómo Funciona?'

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico.
Prepara tus paquetes, completa la información de envío y entrégalos en las
+90 agencias express center o puedes solicitar la recolección a tu casa u
oficina. Rastrea el progreso del envío con el número de guía proporcionado
para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al
centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de
los detalles logísticos. Adquiere tu Paquete Plus y podrás obtener tus guías
prepagadas de 100 envíos con tarifa única a todo el país a Q30.00 c/u.',
    DateUpdated=GETDATE(),
	TokenUpdated='SYS-EVASQUEZ'
WHERE CatSubscriptionId = @IdCatSubscriptionPLUS AND RowStatus=1 AND Title='¿Cómo Funciona?'


UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico.
Prepara tus paquetes, completa la información de envío y entrégalos en las
+90 agencias express center o puedes solicitar la recolección a tu casa u
oficina. Rastrea el progreso del envío con el número de guía proporcionado
para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al
centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de
los detalles logísticos. Adquiere tu Paquete Gold y podrás obtener tus
guías prepagadas de 200 envíos con tarifa única a todo el país a Q28.00 c/u.',
    DateUpdated=GETDATE(),
	TokenUpdated='SYS-EVASQUEZ'
WHERE CatSubscriptionId = @IdCatSubscriptionGOLD  AND RowStatus=1 AND Title='¿Cómo Funciona?'


UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico.
Prepara tus paquetes, completa la información de envío y entrégalos en las
+90 agencias express center o puedes solicitar la recolección a tu casa u
oficina. Rastrea el progreso del envío con el número de guía proporcionado
para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al
centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de
los detalles logísticos. Adquiere tu Paquete Platino y podrás obtener tus
guías prepagadas de 400 envíos con tarifa única a todo el país a Q24.00 c/u.',
    DateUpdated=GETDATE(),
	TokenUpdated='SYS-EVASQUEZ'
WHERE CatSubscriptionId = @IdCatSubscriptionPLATINO  AND RowStatus=1 AND Title='¿Cómo Funciona?'


UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico.
Prepara tus paquetes, completa la información de envío y entrégalos en las
+90 agencias express center o puedes solicitar la recolección a tu casa u
oficina. Rastrea el progreso del envío con el número de guía proporcionado
para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al
centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de
los detalles logísticos. Adquiere tu Paquete Pro y podrás obtener tus guías
prepagadas de 500 envíos con tarifa única a todo el país a Q22.00 c/u.',
    DateUpdated=GETDATE(),
	TokenUpdated='SYS-EVASQUEZ'
WHERE CatSubscriptionId = @IdCatSubscriptionPRO  AND RowStatus=1 AND Title='¿Cómo Funciona?'



UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Nuestro paquete te ofrece 500 guías de envío prepagadas con Tarifa única
a todo el país, lo que significa que puedes enviar tus productos a cualquier
destino sin preocuparte por tarifas variables. Pero eso no es todo, ¡nuestra
tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías
prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes
una gran cantidad de envíos de manera continua? Estas guías son ideales
para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una
tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos
sean más rentables y eficientes hoy mismo!',
    DateUpdated=GETDATE(),
	TokenUpdated='SYS-EVASQUEZ'
WHERE CatSubscriptionId = @IdCatSubscriptionPRO  AND RowStatus=1 AND Title='¿Qué es?'


/*Actualizar Atributos*/

UPDATE dbo.CatSubscriptionAtribute
  SET SubscriptionAttributeDescription='25 guias a Q34 C/U',
      DateUpdated=GETDATE(),
	  TokenUpdated='SYS-EVASQUEZ'
where CatSubscriptionId=@IdCatSubscriptionPETIT
And SubscriptionAttributeDescription='25 guías a Q35 c/u.'


UPDATE dbo.CatSubscriptionAtribute
  SET SubscriptionAttributeDescription='50 guias a Q32 C/U',
      DateUpdated=GETDATE(),
	  TokenUpdated='SYS-EVASQUEZ'
where CatSubscriptionId=@IdCatSubscriptionBASICO 
And SubscriptionAttributeDescription='50 guías a Q33 c/u.'


UPDATE dbo.CatSubscriptionAtribute
  SET SubscriptionAttributeDescription='100 guias a Q30 C/U',
      DateUpdated=GETDATE(),
	  TokenUpdated='SYS-EVASQUEZ'
where CatSubscriptionId=@IdCatSubscriptionPLUS
And SubscriptionAttributeDescription='100 guías a Q31 c/u.'

UPDATE dbo.CatSubscriptionAtribute
  SET SubscriptionAttributeDescription='200 guias a Q28 C/U',
      DateUpdated=GETDATE(),
	  TokenUpdated='SYS-EVASQUEZ'
where CatSubscriptionId=@IdCatSubscriptionGOLD
And SubscriptionAttributeDescription='200 guías a Q29 c/u.'

UPDATE dbo.CatSubscriptionAtribute
  SET SubscriptionAttributeDescription='400 guias a Q24 C/U',
      DateUpdated=GETDATE(),
	  TokenUpdated='SYS-EVASQUEZ'
where CatSubscriptionId=@IdCatSubscriptionPLATINO 
And SubscriptionAttributeDescription='400 guías a Q27 c/u.'


UPDATE dbo.CatSubscriptionAtribute
  SET SubscriptionAttributeDescription='500 guias a Q22 C/U',
      DateUpdated=GETDATE(),
	  TokenUpdated='SYS-EVASQUEZ'
where CatSubscriptionId=@IdCatSubscriptionPRO
And SubscriptionAttributeDescription='600 guías a Q25 c/u.'




/*  Actualizar Suscripciones y paquetes */

UPDATE [dbo].[CatSubscription]
SET tag='NOVEDADES'
WHERE SubscriptionName=
'Paquete Gold' and Idcountry='GT'
  -- PAQUETE GOLD

DECLARE @IdCatSubscriptionGOLD INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WITH(NOLOCK) WHERE SubscriptionName='Paquete Gold'
        AND IdCountry='GT')



/*Actualizar Precio en Catálogo*/


UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='200 guías a Q22.00 c/u.',
    SubscriptionCost=4400.00,
	DateUpdated=GETDATE(),
	TokenUpdated='SYS-EVASQUEZ'
WHERE  IdCatSubscription = @IdCatSubscriptionGOLD  AND  IdCountry='GT'



/*Actualizar Suscripción*/


UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Gold y podrás obtener tus guías prepagadas de 200 envíos con tarifa única a todo el país a Q22.00 c/u.',
    DateUpdated=GETDATE(),
	TokenUpdated='SYS-EVASQUEZ'
WHERE CatSubscriptionId = @IdCatSubscriptionGOLD  AND RowStatus=1 AND Title='¿Cómo Funciona?'




UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Nuestro paquete te ofrece 15 guías de envío prepagadas con Tarifa única a
todo el país, lo que significa que puedes enviar tus productos a cualquier
destino sin preocuparte por tarifas variables. Pero eso no es todo, ¡nuestra
tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías
prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes
una gran cantidad de envíos de manera continua? Estas guías son ideales
para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una
tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos
sean más rentables y eficientes hoy mismo!',
    DateUpdated=GETDATE(),
	TokenUpdated='SYS-EVASQUEZ'
WHERE CatSubscriptionId = @IdCatSubscriptionGOLD  AND RowStatus=1 AND Title='¿Qué es?'



/*Actualizar Restricciones*/


UPDATE dbo.CatSubscriptionAtribute
  SET SubscriptionAttributeDescription='200 guías a Q22.00 c/u.',
      DateUpdated=GETDATE(),
	  TokenUpdated='SYS-EVASQUEZ'
where CatSubscriptionId=@IdCatSubscriptionGOLD
And SubscriptionAttributeDescription='200 guías a Q28.00 c/u.'


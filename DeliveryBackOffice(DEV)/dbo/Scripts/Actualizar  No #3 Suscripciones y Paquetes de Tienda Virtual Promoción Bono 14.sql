/*  Actualizar Suscripciones y paquetes */
  -- PAQUETE MICRO
  -- PAQUETE PETIT
  -- PAQUETE BASICO
  -- PAQUETE PLUS
  -- PAQUETE GOLD
  -- PAQUETE FLEXI
  -- PAQUETE PLATINO
  -- PAQUETE PRO
  
DECLARE @IdCatSubscriptionMICRO INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete Micro'
        AND IdCountry='GT')
DECLARE @IdCatSubscriptionPETIT INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete Petit'
        AND IdCountry='GT')
DECLARE @IdCatSubscriptionBASICO INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete Básico' 
        AND IdCountry='GT')
DECLARE @IdCatSubscriptionPLUS INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete Plus' 
        AND IdCountry='GT')
DECLARE @IdCatSubscriptionGOLD INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete Gold'
        AND IdCountry='GT')
DECLARE @IdCatSubscriptionFLEXI INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete Flexi'
        AND IdCountry='GT')
DECLARE @IdCatSubscriptionPLATINO INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete Platino' 
       AND IdCountry='GT')
DECLARE @IdCatSubscriptionPRO INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete Pro' 
       AND IdCountry='GT')


/*Actualizar Precio en Catálogo*/

UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='15 guías a Q32.40 c/u.',
    SubscriptionCost=486.00,
	DateUpdated=GETDATE(),
	TokenUpdated='SYS-EVASQUEZ'
WHERE  IdCatSubscription = @IdCatSubscriptionMICRO AND  IdCountry='GT'


UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='25 guías a Q30.60 c/u.',
    SubscriptionCost=765.00,
	DateUpdated=GETDATE(),
	TokenUpdated='SYS-EVASQUEZ'
WHERE  IdCatSubscription = @IdCatSubscriptionPETIT AND  IdCountry='GT'

UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='50 guías a Q28.80 c/u.',
    SubscriptionCost=1440.00,
	DateUpdated=GETDATE(),
	TokenUpdated='SYS-EVASQUEZ'
WHERE  IdCatSubscription = @IdCatSubscriptionBASICO AND  IdCountry='GT'

UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='100 guías a Q27.00 c/u.',
    SubscriptionCost=2700.00,
	DateUpdated=GETDATE(),
	TokenUpdated='SYS-EVASQUEZ'
WHERE  IdCatSubscription = @IdCatSubscriptionPLUS AND  IdCountry='GT'

UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='200 guías a Q25.20 c/u.',
    SubscriptionCost=5040.00,
	DateUpdated=GETDATE(),
	TokenUpdated='SYS-EVASQUEZ'
WHERE  IdCatSubscription = @IdCatSubscriptionGOLD  AND  IdCountry='GT'

UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='300 guías a Q23.40 c/u.',
    SubscriptionCost=7020.00,
	DateUpdated=GETDATE(),
	TokenUpdated='SYS-EVASQUEZ'
WHERE  IdCatSubscription = @IdCatSubscriptionFLEXI  AND  IdCountry='GT'

UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='400 guías a Q21.60 c/u.',
    SubscriptionCost=8640.00,
	DateUpdated=GETDATE(),
	TokenUpdated='SYS-EVASQUEZ'
WHERE  IdCatSubscription = @IdCatSubscriptionPLATINO  AND  IdCountry='GT'


UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='500 guías a Q19.80 c/u.',
    SubscriptionCost=9900.00,
	DateUpdated=GETDATE(),
	TokenUpdated='SYS-EVASQUEZ'
WHERE  IdCatSubscription = @IdCatSubscriptionPRO  AND  IdCountry='GT'


/*Actualizar Suscripción*/

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
WHERE CatSubscriptionId = @IdCatSubscriptionMICRO  AND RowStatus=1 AND Title='¿Qué es?'

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico.
Prepara tus paquetes, completa la información de envío y entrégalos en las
+100 agencias express center o puedes solicitar la recolección a tu casa u
oficina. Rastrea el progreso del envío con el número de guía proporcionado
para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al
centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de
los detalles logísticos. Adquiere tu Paquete Micro y podrás obtener tus
guías prepagadas de 15 envíos con tarifa única a todo el país a Q32.40
c/u.',
    DateUpdated=GETDATE(),
	TokenUpdated='SYS-EVASQUEZ'
WHERE CatSubscriptionId = @IdCatSubscriptionMICRO  AND RowStatus=1 AND Title='¿Cómo Funciona?'

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
WHERE CatSubscriptionId = @IdCatSubscriptionPETIT   AND RowStatus=1 AND Title='¿Qué es?'

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico.
Prepara tus paquetes, completa la información de envío y entrégalos en las
+100 agencias express center o puedes solicitar la recolección a tu casa u
oficina. Rastrea el progreso del envío con el número de guía proporcionado
para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al
centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de
los detalles logísticos. Adquiere tu Paquete Petit y podrás obtener tus
guías prepagadas de 25 envíos con tarifa única a todo el país a Q30.60.00
c/u.',
    DateUpdated=GETDATE(),
	TokenUpdated='SYS-EVASQUEZ'
WHERE CatSubscriptionId = @IdCatSubscriptionPETIT AND RowStatus=1 AND Title='¿Cómo Funciona?'

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Nuestro paquete te ofrece 50 guías de envío prepagadas con Tarifa única a
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
WHERE CatSubscriptionId = @IdCatSubscriptionBASICO   AND RowStatus=1 AND Title='¿Qué es?'

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico.
Prepara tus paquetes, completa la información de envío y entrégalos en las
+100 agencias express center o puedes solicitar la recolección a tu casa u
oficina. Rastrea el progreso del envío con el número de guía proporcionado
para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al
centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de
los detalles logísticos. Adquiere tu Paquete Básico y podrás obtener tus
guías prepagadas de 50 envíos con tarifa única a todo el país a Q28.80.00
c/u.',
    DateUpdated=GETDATE(),
	TokenUpdated='SYS-EVASQUEZ'
WHERE CatSubscriptionId = @IdCatSubscriptionBASICO AND RowStatus=1 AND Title='¿Cómo Funciona?'

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Nuestro paquete te ofrece 100 guías de envío prepagadas con Tarifa única a
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
WHERE CatSubscriptionId = @IdCatSubscriptionPLUS  AND RowStatus=1 AND Title='¿Qué es?'

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico.
Prepara tus paquetes, completa la información de envío y entrégalos en las
+100 agencias express center o puedes solicitar la recolección a tu casa u
oficina. Rastrea el progreso del envío con el número de guía proporcionado
para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al
centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de
los detalles logísticos. Adquiere tu Paquete Plus y podrás obtener tus guías
prepagadas de 100 envíos con tarifa única a todo el país a Q27.00 c/u.',
    DateUpdated=GETDATE(),
	TokenUpdated='SYS-EVASQUEZ'
WHERE CatSubscriptionId = @IdCatSubscriptionPLUS AND RowStatus=1 AND Title='¿Cómo Funciona?'

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Nuestro paquete te ofrece 200 guías de envío prepagadas con Tarifa única a
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


UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico.
Prepara tus paquetes, completa la información de envío y entrégalos en las
+100 agencias express center o puedes solicitar la recolección a tu casa u
oficina. Rastrea el progreso del envío con el número de guía proporcionado
para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al
centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de
los detalles logísticos. Adquiere tu Paquete Gold y podrás obtener tus
guías prepagadas de 200 envíos con tarifa única a todo el país a Q25.20 c/u.',
    DateUpdated=GETDATE(),
	TokenUpdated='SYS-EVASQUEZ'
WHERE CatSubscriptionId = @IdCatSubscriptionGOLD  AND RowStatus=1 AND Title='¿Cómo Funciona?'

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Nuestro paquete te ofrece 300 guías de envío prepagadas con Tarifa única a
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
WHERE CatSubscriptionId = @IdCatSubscriptionFLEXI  AND RowStatus=1 AND Title='¿Qué es?'

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico.
Prepara tus paquetes, completa la información de envío y entrégalos en las
+100 agencias express center o puedes solicitar la recolección a tu casa u
oficina. Rastrea el progreso del envío con el número de guía proporcionado
para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al
centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de
los detalles logísticos. Adquiere tu Paquete Gold y podrás obtener tus
guías prepagadas de 300 envíos con tarifa única a todo el país a Q23.40 c/u.',
    DateUpdated=GETDATE(),
	TokenUpdated='SYS-EVASQUEZ'
WHERE CatSubscriptionId = @IdCatSubscriptionFLEXI  AND RowStatus=1 AND Title='¿Cómo Funciona?'

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Nuestro paquete te ofrece 400 guías de envío prepagadas con Tarifa única a
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
WHERE CatSubscriptionId = @IdCatSubscriptionPLATINO  AND RowStatus=1 AND Title='¿Qué es?'

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico.
Prepara tus paquetes, completa la información de envío y entrégalos en las
+100 agencias express center o puedes solicitar la recolección a tu casa u
oficina. Rastrea el progreso del envío con el número de guía proporcionado
para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al
centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de
los detalles logísticos. Adquiere tu Paquete Platino y podrás obtener tus
guías prepagadas de 400 envíos con tarifa única a todo el país a Q21.60 c/u.',
    DateUpdated=GETDATE(),
	TokenUpdated='SYS-EVASQUEZ'
WHERE CatSubscriptionId = @IdCatSubscriptionPLATINO  AND RowStatus=1 AND Title='¿Cómo Funciona?'

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

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico.
Prepara tus paquetes, completa la información de envío y entrégalos en las
+100 agencias express center o puedes solicitar la recolección a tu casa u
oficina. Rastrea el progreso del envío con el número de guía proporcionado
para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al
centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de
los detalles logísticos. Adquiere tu Paquete Pro y podrás obtener tus guías
prepagadas de 500 envíos con tarifa única a todo el país a Q19.80 c/u.',
    DateUpdated=GETDATE(),
	TokenUpdated='SYS-EVASQUEZ'
WHERE CatSubscriptionId = @IdCatSubscriptionPRO  AND RowStatus=1 AND Title='¿Cómo Funciona?'

/*Actualizar Restricciones*/

UPDATE A
 SET A.[Description] ='En caso de que tu envío exceda el peso, de 0 a 10 libras, consulta los términos y condiciones.'
FROM [dbo].[CatSubscriptionDescription] A
INNER JOIN [dbo].CatSubscription B
ON A.CatSubscriptionId = B.IdCatSubscription
WHERE A.Title='Aplican restricciones' AND A.Rowstatus=1
      AND B.IdCountry= 'GT'


/*Actualizar Atributos*/

UPDATE dbo.CatSubscriptionAtribute
  SET SubscriptionAttributeDescription='15 guías a Q32.40 c/u.',
      DateUpdated=GETDATE(),
	  TokenUpdated='SYS-EVASQUEZ'
where CatSubscriptionId=@IdCatSubscriptionMICRO
And SubscriptionAttributeDescription='15 guías a Q36 c/u.'

UPDATE dbo.CatSubscriptionAtribute
  SET SubscriptionAttributeDescription='25 guías a Q30.60 c/u.',
      DateUpdated=GETDATE(),
	  TokenUpdated='SYS-EVASQUEZ'
where CatSubscriptionId=@IdCatSubscriptionPETIT
And SubscriptionAttributeDescription='25 guias a Q34 C/U'


UPDATE dbo.CatSubscriptionAtribute
  SET SubscriptionAttributeDescription='50 guías a Q28.80 c/u.',
      DateUpdated=GETDATE(),
	  TokenUpdated='SYS-EVASQUEZ'
where CatSubscriptionId=@IdCatSubscriptionBASICO 
And SubscriptionAttributeDescription='50 guias a Q32 C/U'


UPDATE dbo.CatSubscriptionAtribute
  SET SubscriptionAttributeDescription='100 guías a Q27.00 c/u.',
      DateUpdated=GETDATE(),
	  TokenUpdated='SYS-EVASQUEZ'
where CatSubscriptionId=@IdCatSubscriptionPLUS
And SubscriptionAttributeDescription='100 guias a Q30 C/U'

UPDATE dbo.CatSubscriptionAtribute
  SET SubscriptionAttributeDescription='200 guías a Q25.20 c/u.',
      DateUpdated=GETDATE(),
	  TokenUpdated='SYS-EVASQUEZ'
where CatSubscriptionId=@IdCatSubscriptionGOLD
And SubscriptionAttributeDescription='200 guias a Q28 C/U'

UPDATE dbo.CatSubscriptionAtribute
  SET SubscriptionAttributeDescription='300 guías a Q23.40 c/u.',
      DateUpdated=GETDATE(),
	  TokenUpdated='SYS-EVASQUEZ'
where CatSubscriptionId=@IdCatSubscriptionFLEXI
And SubscriptionAttributeDescription='300 guías a Q26 c/u.'

UPDATE dbo.CatSubscriptionAtribute
  SET SubscriptionAttributeDescription='400 guías a Q21.60 c/u.',
      DateUpdated=GETDATE(),
	  TokenUpdated='SYS-EVASQUEZ'
where CatSubscriptionId=@IdCatSubscriptionPLATINO 
And SubscriptionAttributeDescription='400 guias a Q24 C/U'


UPDATE dbo.CatSubscriptionAtribute
  SET SubscriptionAttributeDescription='500 guías a Q19.80 c/u.',
      DateUpdated=GETDATE(),
	  TokenUpdated='SYS-EVASQUEZ'
where CatSubscriptionId=@IdCatSubscriptionPRO
And SubscriptionAttributeDescription='500 guias a Q22 C/U'


/* New Image banner carousel*/
INSERT [dbo].[MarketplaceCarouselImage] ([XXLImageURL], [XLImageURL], [MDImageURL], [XSImageURL], [ImageOrder], [RowStatus], [TokenCreated], [DateCreated], [TokenUpdated], [DateUpdated], [XXXLImageURL], [HyperlinkURL], [IdCountry]) VALUES ( N'https://forzadelivery.com/images/Tienda/slider04-1920-300.jpg', N'https://forzadelivery.com/images/Tienda/slider04-1200-250.jpg', N'https://forzadelivery.com/images/Tienda/slider04-992-200.jpg', N'https://forzadelivery.com/images/Tienda/slider04-575-200.jpg', 3, 1, N'SYS-EVASQUEZ', CAST(N'2025-06-19T00:00:00.000' AS DateTime), NULL, NULL, N'https://forzadelivery.com/images/Tienda/slider04-2500-350.jpg', NULL, N'GT')
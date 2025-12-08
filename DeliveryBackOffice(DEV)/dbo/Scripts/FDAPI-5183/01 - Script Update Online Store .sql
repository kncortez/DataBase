/*  Actualizar Suscripciones y paquetes */
  -- PAQUETE MICRO
  -- PAQUETE PETIT
  -- PAQUETE BASICO
  -- PAQUETE PLUS
  -- PAQUETE GOLD
  -- PAQUETE PLATINO
  -- PAQUETE PRO
BEGIN TRY
    BEGIN TRANSACTION;
DECLARE @IdCatSubscriptionMICRO INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WITH(NOLOCK) WHERE SubscriptionName='Paquete Micro'
        AND IdCountry='GT');
DECLARE @IdCatSubscriptionPETIT INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WITH(NOLOCK) WHERE SubscriptionName='Paquete Petit'
        AND IdCountry='GT');
DECLARE @IdCatSubscriptionBASICO INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WITH(NOLOCK) WHERE SubscriptionName='Paquete Básico' 
        AND IdCountry='GT');
DECLARE @IdCatSubscriptionPLUS INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WITH(NOLOCK) WHERE SubscriptionName='Paquete Plus' 
        AND IdCountry='GT');
DECLARE @IdCatSubscriptionGOLD INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WITH(NOLOCK) WHERE SubscriptionName='Paquete Gold'
        AND IdCountry='GT');
DECLARE @IdCatSubscriptionPLATINO INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WITH(NOLOCK) WHERE SubscriptionName='Paquete Platino' 
       AND IdCountry='GT');
DECLARE @IdCatSubscriptionPRO INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WITH(NOLOCK) WHERE SubscriptionName='Paquete Pro' 
       AND IdCountry='GT');
/*Actualizar Precio en Catálogo*/
UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='15 guías a Q36.00 c/u.',
    SubscriptionCost=540.00,
	Tag = NULL,
	DateUpdated=GETDATE(),
	TokenUpdated='SYS-BPEDROZA'
WHERE  IdCatSubscription = @IdCatSubscriptionMICRO AND  IdCountry='GT'

UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='25 guías a Q34.00 c/u.',
    SubscriptionCost=850.00,
	Tag = NULL,
	DateUpdated=GETDATE(),
	TokenUpdated='SYS-BPEDROZA'
WHERE  IdCatSubscription = @IdCatSubscriptionPETIT AND  IdCountry='GT'

UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='50 guías a Q32.00 c/u.',
    SubscriptionCost=1600.00,
	Tag = NULL,
	DateUpdated=GETDATE(),
	TokenUpdated='SYS-BPEDROZA'
WHERE  IdCatSubscription = @IdCatSubscriptionBASICO AND  IdCountry='GT'

UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='100 guías a Q30.00 c/u',
    SubscriptionCost=3000.00,
	Tag = NULL,
	DateUpdated=GETDATE(),
	TokenUpdated='SYS-BPEDROZA'
WHERE  IdCatSubscription = @IdCatSubscriptionPLUS AND  IdCountry='GT'

UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='200 guías a Q28.00 c/u.',
    SubscriptionCost=5600.00,
	Tag = NULL,
	DateUpdated=GETDATE(),
	TokenUpdated='SYS-BPEDROZA'
WHERE  IdCatSubscription = @IdCatSubscriptionGOLD  AND  IdCountry='GT'

UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='400 guías a Q24.00 c/u.',
    SubscriptionCost=9600.00,
	Tag = NULL,
	DateUpdated=GETDATE(),
	TokenUpdated='SYS-BPEDROZA'
WHERE  IdCatSubscription = @IdCatSubscriptionPLATINO  AND  IdCountry='GT'

UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='500 guías a Q22.00 c/u.',
    SubscriptionCost=11000.00,
	Tag = NULL,
	DateUpdated=GETDATE(),
	TokenUpdated='SYS-BPEDROZA'
WHERE  IdCatSubscription = @IdCatSubscriptionPRO  AND  IdCountry='GT'
/*Actualizar Suscripción*/
UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Nuestro paquete te ofrece 15 guías de envío prepagadas con Tarifa única a todo el país, lo que significa que puedes enviar tus productos a cualquier destino sin preocuparte por tarifas variables. Pero eso no es todo, ¡nuestra tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes una gran cantidad de envíos de manera continua? Estas guías son ideales para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos sean más rentables y eficientes hoy mismo!',
    DateUpdated=GETDATE(),
	TokenUpdated='SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionMICRO  AND RowStatus=1 AND Title='¿Qué es?'

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +100 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Micro y podrás obtener tus guías prepagadas de 15 envíos con tarifa única a todo el país a Q36.00 c/u.',
    DateUpdated=GETDATE(),
	TokenUpdated='SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionMICRO  AND RowStatus=1 AND Title='¿Cómo Funciona?'

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Nuestro paquete te ofrece 25 guías de envío prepagadas con Tarifa única a todo el país, lo que significa que puedes enviar tus productos a cualquier destino sin preocuparte por tarifas variables. Pero eso no es todo, ¡nuestra tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes una gran cantidad de envíos de manera continua? Estas guías son ideales para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos sean más rentables y eficientes hoy mismo!',
    DateUpdated=GETDATE(),
	TokenUpdated='SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionPETIT  AND RowStatus=1 AND Title='¿Qué es?'

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +100 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Petit y podrás obtener tus guías prepagadas de 25 envíos con tarifa única a todo el país a Q34.00 c/u.',
    DateUpdated=GETDATE(),
	TokenUpdated='SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionPETIT AND RowStatus=1 AND Title='¿Cómo Funciona?'

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Nuestro paquete te ofrece 50 guías de envío prepagadas con Tarifa única a todo el país, lo que significa que puedes enviar tus productos a cualquier destino sin preocuparte por tarifas variables. Pero eso no es todo, ¡nuestra tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes una gran cantidad de envíos de manera continua? Estas guías son ideales para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos sean más rentables y eficientes hoy mismo!',
    DateUpdated=GETDATE(),
	TokenUpdated='SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionBASICO  AND RowStatus=1 AND Title='¿Qué es?'

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +100 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Basico y podrás obtener tus guías prepagadas de 50 envíos con tarifa única a todo el país a Q32.00 c/u.',
    DateUpdated=GETDATE(),
	TokenUpdated='SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionBASICO AND RowStatus=1 AND Title='¿Cómo Funciona?'

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Nuestro paquete te ofrece 100 guías de envío prepagadas con Tarifa única a todo el país, lo que significa que puedes enviar tus productos a cualquier destino sin preocuparte por tarifas variables. Pero eso no es todo, ¡nuestra tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes una gran cantidad de envíos de manera continua? Estas guías son ideales para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos sean más rentables y eficientes hoy mismo!',
    DateUpdated=GETDATE(),
	TokenUpdated='SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionPLUS  AND RowStatus=1 AND Title='¿Qué es?'

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +100 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Plus y podrás obtener tus guías prepagadas de 100 envíos con tarifa única a todo el país a Q30.00 c/u.',
    DateUpdated=GETDATE(),
	TokenUpdated='SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionPLUS AND RowStatus=1 AND Title='¿Cómo Funciona?'

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Nuestro paquete te ofrece 200 guías de envío prepagadas con Tarifa única a todo el país, lo que significa que puedes enviar tus productos a cualquier destino sin preocuparte por tarifas variables. Pero eso no es todo, ¡nuestra tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes una gran cantidad de envíos de manera continua? Estas guías son ideales para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos sean más rentables y eficientes hoy mismo!',
    DateUpdated=GETDATE(),
	TokenUpdated='SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionGOLD  AND RowStatus=1 AND Title='¿Qué es?'

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +100 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Gold y podrás obtener tus guías prepagadas de 200 envíos con tarifa única a todo el país a Q28.00 c/u.',
    DateUpdated=GETDATE(),
	TokenUpdated='SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionGOLD  AND RowStatus=1 AND Title='¿Cómo Funciona?'


UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Nuestro paquete te ofrece 400 guías de envío prepagadas con Tarifa única a todo el país, lo que significa que puedes enviar tus productos a cualquier destino sin preocuparte por tarifas variables. Pero eso no es todo, ¡nuestra tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes una gran cantidad de envíos de manera continua? Estas guías son ideales para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos sean más rentables y eficientes hoy mismo!',
    DateUpdated=GETDATE(),
	TokenUpdated='SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionPLATINO  AND RowStatus=1 AND Title='¿Qué es?'

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +100 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Platino y podrás obtener tus guías prepagadas de 400 envíos con tarifa única a todo el país a Q24.00 c/u.',
    DateUpdated=GETDATE(),
	TokenUpdated='SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionPLATINO  AND RowStatus=1 AND Title='¿Cómo Funciona?'

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Nuestro paquete te ofrece 500 guías de envío prepagadas con Tarifa única a todo el país, lo que significa que puedes enviar tus productos a cualquier destino sin preocuparte por tarifas variables. Pero eso no es todo, ¡nuestra tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes una gran cantidad de envíos de manera continua? Estas guías son ideales para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos sean más rentables y eficientes hoy mismo!',
    DateUpdated=GETDATE(),
	TokenUpdated='SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionPRO  AND RowStatus=1 AND Title='¿Qué es?'

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +100 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Pro y podrás obtener tus guías prepagadas de 500 envíos con tarifa única a todo el país a Q22.00 c/u.',
    DateUpdated=GETDATE(),
	TokenUpdated='SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionPRO  AND RowStatus=1 AND Title='¿Cómo Funciona?'

/*Actualizar Atributos*/
UPDATE dbo.CatSubscriptionAtribute
  SET SubscriptionAttributeDescription='15 guías a Q36.00 c/u.',
      DateUpdated=GETDATE(),
	  TokenUpdated='SYS-BPEDROZA'
where CatSubscriptionId=@IdCatSubscriptionMICRO
And SubscriptionAttributeDescription='15 guías a Q35.00 C/U'

UPDATE dbo.CatSubscriptionAtribute
  SET SubscriptionAttributeDescription='25 guías a Q34.00 c/u.',
      DateUpdated=GETDATE(),
	  TokenUpdated='SYS-BPEDROZA'
where CatSubscriptionId=@IdCatSubscriptionPETIT
And SubscriptionAttributeDescription='25 guías a Q33.00 C/U'

UPDATE dbo.CatSubscriptionAtribute
  SET SubscriptionAttributeDescription='50 guías a Q32.00 c/u.',
      DateUpdated=GETDATE(),
	  TokenUpdated='SYS-BPEDROZA'
where CatSubscriptionId=@IdCatSubscriptionBASICO 
And SubscriptionAttributeDescription='50 guías a Q31.00 C/U'

UPDATE dbo.CatSubscriptionAtribute
  SET SubscriptionAttributeDescription='100 guías a Q30.00 c/u.',
      DateUpdated=GETDATE(),
	  TokenUpdated='SYS-BPEDROZA'
where CatSubscriptionId=@IdCatSubscriptionPLUS
And SubscriptionAttributeDescription='100 guías a Q29.00 C/U'

UPDATE dbo.CatSubscriptionAtribute
  SET SubscriptionAttributeDescription='200 guías a Q28.00 c/u.',
      DateUpdated=GETDATE(),
	  TokenUpdated='SYS-BPEDROZA'
where CatSubscriptionId=@IdCatSubscriptionGOLD
And SubscriptionAttributeDescription='200 guías a Q27.00 C/U'

UPDATE dbo.CatSubscriptionAtribute
  SET SubscriptionAttributeDescription='400 guías a Q24.00 c/u.',
      DateUpdated=GETDATE(),
	  TokenUpdated='SYS-BPEDROZA'
where CatSubscriptionId=@IdCatSubscriptionPLATINO 
And SubscriptionAttributeDescription='400 guías a Q24.00 C/U'

UPDATE dbo.CatSubscriptionAtribute
  SET SubscriptionAttributeDescription='500 guías a Q22.00 c/u.',
      DateUpdated=GETDATE(),
	  TokenUpdated='SYS-BPEDROZA'
where CatSubscriptionId=@IdCatSubscriptionPRO
And SubscriptionAttributeDescription='500 guías a Q22.00 C/U'



    COMMIT TRANSACTION;
    PRINT 'Actualización completada exitosamente.';

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    PRINT 'Se produjo un error en la ejecución.';
    PRINT 'Número de Error: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
    PRINT 'Severidad: ' + CAST(ERROR_SEVERITY() AS VARCHAR(10));
    PRINT 'Estado: ' + CAST(ERROR_STATE() AS VARCHAR(10));
    PRINT 'Procedimiento: ' + ISNULL(ERROR_PROCEDURE(), '-');
    PRINT 'Línea: ' + CAST(ERROR_LINE() AS VARCHAR(10));
    PRINT 'Mensaje: ' + ERROR_MESSAGE();
END CATCH;
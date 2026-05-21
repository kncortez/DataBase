BEGIN TRY
    BEGIN TRANSACTION;

DECLARE @IdCatSubscriptionMICRO   INT = (SELECT IdCatSubscription FROM [dbo].[CatSubscription] WITH(NOLOCK) WHERE SubscriptionName='Paquete Micro'  AND IdCountry='HN');
DECLARE @IdCatSubscriptionPETIT   INT = (SELECT IdCatSubscription FROM [dbo].[CatSubscription] WITH(NOLOCK) WHERE SubscriptionName='Paquete Petit'  AND IdCountry='HN');
DECLARE @IdCatSubscriptionBASICO  INT = (SELECT IdCatSubscription FROM [dbo].[CatSubscription] WITH(NOLOCK) WHERE SubscriptionName='Paquete Básico'  AND IdCountry='HN');
DECLARE @IdCatSubscriptionPLUS    INT = (SELECT IdCatSubscription FROM [dbo].[CatSubscription] WITH(NOLOCK) WHERE SubscriptionName='Paquete Plus'  AND IdCountry='HN');
DECLARE @IdCatSubscriptionGOLD    INT = (SELECT IdCatSubscription FROM [dbo].[CatSubscription] WITH(NOLOCK) WHERE SubscriptionName='Paquete Gold'  AND IdCountry='HN');
DECLARE @IdCatSubscriptionPLATINO INT = (SELECT IdCatSubscription FROM [dbo].[CatSubscription] WITH(NOLOCK) WHERE SubscriptionName='Paquete Platino'  AND IdCountry='HN');
DECLARE @IdCatSubscriptionPRO     INT = (SELECT IdCatSubscription FROM [dbo].[CatSubscription] WITH(NOLOCK) WHERE SubscriptionName='Paquete Pro'  AND IdCountry='HN');


 --*********************  ACTUALIZAR PRECIO EN CATÁLOGO  *********************

--PAQUETE MICRO
UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='15 guías a L104.00 c/u.',
    SubscriptionCost=1560.00,
    Tag = NULL,
    DateUpdated=GETDATE(),
    TokenUpdated='SYS-BPEDROZA'
WHERE IdCatSubscription = @IdCatSubscriptionMICRO AND IdCountry='HN'

--PAQUETE PETIT
UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='25 guías a L100.00 c/u.',
    SubscriptionCost=2500.00,
    Tag = NULL,
    DateUpdated=GETDATE(),
    TokenUpdated='SYS-BPEDROZA'
WHERE IdCatSubscription = @IdCatSubscriptionPETIT AND IdCountry='HN'

--PAQUETE BÁSICO
UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='50 guías a L95.00 c/u.',
    SubscriptionCost=4750.00,
    Tag = NULL,
    DateUpdated=GETDATE(),
    TokenUpdated='SYS-BPEDROZA'
WHERE IdCatSubscription = @IdCatSubscriptionBASICO AND IdCountry='HN'

--PAQUETE PLUS
UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='100 guías a L90.00 c/u.',
    SubscriptionCost=9000.00,
    Tag = NULL,
    DateUpdated=GETDATE(),
    TokenUpdated='SYS-BPEDROZA'
WHERE IdCatSubscription = @IdCatSubscriptionPLUS AND IdCountry='HN'

--PAQUETE GOLD
UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='200 guías a L80.00 c/u.',
    SubscriptionCost=16000.00,
    Tag = NULL,
    DateUpdated=GETDATE(),
    TokenUpdated='SYS-BPEDROZA'
WHERE IdCatSubscription = @IdCatSubscriptionGOLD AND IdCountry='HN'

--PAQUETE PLATINO
UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='400 guías a L75.00 c/u.',
    SubscriptionCost=30000.00,
    Tag = NULL,
    DateUpdated=GETDATE(),
    TokenUpdated='SYS-BPEDROZA'
WHERE IdCatSubscription = @IdCatSubscriptionPLATINO AND IdCountry='HN'


 --*********************  ACTUALIZAR SUSCRIPCIÓN  *********************

--PAQUETE MICRO - ¿Qué es?
UPDATE [dbo].[CatSubscriptionDescription]
SET [Description]='Nuestro paquete te ofrece 15 guías de envío prepagadas con Tarifa única a todo el país, lo que significa que puedes enviar tus productos a cualquier destino sin preocuparte por tarifas variables. Pero eso no es todo, ¡nuestra tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes una gran cantidad de envíos de manera continua? Estas guías son ideales para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos sean más rentables y eficientes hoy mismo!',
    DateUpdated=GETDATE(),
    TokenUpdated='SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionMICRO AND RowStatus=1 AND Title='¿Qué es?'

--PAQUETE MICRO - ¿Cómo Funciona?
UPDATE [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +100 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Micro y podrás obtener tus guías prepagadas de 15 envíos con tarifa única a todo el país a L104.00 c/u.',
    DateUpdated=GETDATE(),
    TokenUpdated='SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionMICRO AND RowStatus=1 AND Title='¿Cómo Funciona?'

--PAQUETE PETIT - ¿Qué es?
UPDATE [dbo].[CatSubscriptionDescription]
SET [Description]='Nuestro paquete te ofrece 25 guías de envío prepagadas con Tarifa única a todo el país, lo que significa que puedes enviar tus productos a cualquier destino sin preocuparte por tarifas variables. Pero eso no es todo, ¡nuestra tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes una gran cantidad de envíos de manera continua? Estas guías son ideales para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos sean más rentables y eficientes hoy mismo!',
    DateUpdated=GETDATE(),
    TokenUpdated='SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionPETIT AND RowStatus=1 AND Title='¿Qué es?'

--PAQUETE PETIT - ¿Cómo Funciona?
UPDATE [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +100 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Petit y podrás obtener tus guías prepagadas de 25 envíos con tarifa única a todo el país a L100.00 c/u.',
    DateUpdated=GETDATE(),
    TokenUpdated='SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionPETIT AND RowStatus=1 AND Title='¿Cómo Funciona?'

--PAQUETE BÁSICO - ¿Qué es?
UPDATE [dbo].[CatSubscriptionDescription]
SET [Description]='Nuestro paquete te ofrece 50 guías de envío prepagadas con Tarifa única a todo el país, lo que significa que puedes enviar tus productos a cualquier destino sin preocuparte por tarifas variables. Pero eso no es todo, ¡nuestra tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes una gran cantidad de envíos de manera continua? Estas guías son ideales para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos sean más rentables y eficientes hoy mismo!',
    DateUpdated=GETDATE(),
    TokenUpdated='SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionBASICO AND RowStatus=1 AND Title='¿Qué es?'

--PAQUETE BÁSICO - ¿Cómo Funciona?
UPDATE [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +100 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Básico y podrás obtener tus guías prepagadas de 50 envíos con tarifa única a todo el país a L95.00 c/u.',
    DateUpdated=GETDATE(),
    TokenUpdated='SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionBASICO AND RowStatus=1 AND Title='¿Cómo Funciona?'

--PAQUETE PLUS - ¿Qué es?
UPDATE [dbo].[CatSubscriptionDescription]
SET [Description]='Nuestro paquete te ofrece 100 guías de envío prepagadas con Tarifa única a todo el país, lo que significa que puedes enviar tus productos a cualquier destino sin preocuparte por tarifas variables. Pero eso no es todo, ¡nuestra tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes una gran cantidad de envíos de manera continua? Estas guías son ideales para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos sean más rentables y eficientes hoy mismo!',
    DateUpdated=GETDATE(),
    TokenUpdated='SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionPLUS AND RowStatus=1 AND Title='¿Qué es?'

--PAQUETE PLUS - ¿Cómo Funciona?
UPDATE [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +100 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Plus y podrás obtener tus guías prepagadas de 100 envíos con tarifa única a todo el país a L90.00 c/u.',
    DateUpdated=GETDATE(),
    TokenUpdated='SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionPLUS AND RowStatus=1 AND Title='¿Cómo Funciona?'

--PAQUETE GOLD - ¿Qué es?
UPDATE [dbo].[CatSubscriptionDescription]
SET [Description]='Nuestro paquete te ofrece 200 guías de envío prepagadas con Tarifa única a todo el país, lo que significa que puedes enviar tus productos a cualquier destino sin preocuparte por tarifas variables. Pero eso no es todo, ¡nuestra tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes una gran cantidad de envíos de manera continua? Estas guías son ideales para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos sean más rentables y eficientes hoy mismo!',
    DateUpdated=GETDATE(),
    TokenUpdated='SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionGOLD AND RowStatus=1 AND Title='¿Qué es?'

--PAQUETE GOLD - ¿Cómo Funciona?
UPDATE [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +100 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Gold y podrás obtener tus guías prepagadas de 200 envíos con tarifa única a todo el país a L80.00 c/u.',
    DateUpdated=GETDATE(),
    TokenUpdated='SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionGOLD AND RowStatus=1 AND Title='¿Cómo Funciona?'

--PAQUETE PLATINO - ¿Qué es?
UPDATE [dbo].[CatSubscriptionDescription]
SET [Description]='Nuestro paquete te ofrece 400 guías de envío prepagadas con Tarifa única a todo el país, lo que significa que puedes enviar tus productos a cualquier destino sin preocuparte por tarifas variables. Pero eso no es todo, ¡nuestra tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes una gran cantidad de envíos de manera continua? Estas guías son ideales para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos sean más rentables y eficientes hoy mismo!',
    DateUpdated=GETDATE(),
    TokenUpdated='SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionPLATINO AND RowStatus=1 AND Title='¿Qué es?'

--PAQUETE PLATINO - ¿Cómo Funciona?
UPDATE [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +100 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Platino y podrás obtener tus guías prepagadas de 400 envíos con tarifa única a todo el país a L75.00 c/u.',
    DateUpdated=GETDATE(),
    TokenUpdated='SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionPLATINO AND RowStatus=1 AND Title='¿Cómo Funciona?'


 --*********************  ACTUALIZAR ATRIBUTOS  *********************

--PAQUETE MICRO
UPDATE dbo.CatSubscriptionAtribute
SET SubscriptionAttributeDescription     = '15 guías a L104.00 c/u.',
    SubscriptionAttributeDescriptionLong = '15 guías a L104.00 c/u.',
    DateUpdated = GETDATE(),
    TokenUpdated = 'SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionMICRO AND SubscriptionAttributeDescription='15 guías a L93.48 c/u.'

--PAQUETE PETIT
UPDATE dbo.CatSubscriptionAtribute
SET SubscriptionAttributeDescription     = '25 guías a L100.00 c/u.',
    SubscriptionAttributeDescriptionLong = '25 guías a L100.00 c/u.',
    DateUpdated = GETDATE(),
    TokenUpdated = 'SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionPETIT AND SubscriptionAttributeDescription='25 guías a L90.00 c/u.'

--PAQUETE BÁSICO
UPDATE dbo.CatSubscriptionAtribute
SET SubscriptionAttributeDescription     = '50 guías a L95.00 c/u.',
    SubscriptionAttributeDescriptionLong = '50 guías a L95.00 c/u.',
    DateUpdated = GETDATE(),
    TokenUpdated = 'SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionBASICO AND SubscriptionAttributeDescription='50 guías a L85.50 c/u.'

--PAQUETE PLUS
UPDATE dbo.CatSubscriptionAtribute
SET SubscriptionAttributeDescription     = '100 guías a L90.00 c/u.',
    SubscriptionAttributeDescriptionLong = '100 guías a L90.00 c/u.',
    DateUpdated = GETDATE(),
    TokenUpdated = 'SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionPLUS AND SubscriptionAttributeDescription='100 guías a L81.00 c/u.'

--PAQUETE GOLD
UPDATE dbo.CatSubscriptionAtribute
SET SubscriptionAttributeDescription     = '200 guías a L80.00 c/u.',
    SubscriptionAttributeDescriptionLong = '200 guías a L80.00 c/u.',
    DateUpdated = GETDATE(),
    TokenUpdated = 'SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionGOLD AND SubscriptionAttributeDescription='200 guías a L72.00 c/u.'

--PAQUETE PLATINO
UPDATE dbo.CatSubscriptionAtribute
SET SubscriptionAttributeDescription     = '400 guías a L75.00 c/u.',
    SubscriptionAttributeDescriptionLong = '400 guías a L75.00 c/u.',
    DateUpdated = GETDATE(),
    TokenUpdated = 'SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionPLATINO AND SubscriptionAttributeDescription='400 guías a L67.50 c/u.'


    COMMIT TRANSACTION;
    PRINT 'Actualización completada exitosamente.';

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    THROW;
    PRINT 'Se produjo un error en la ejecución.';
    PRINT 'Número de Error: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
    PRINT 'Severidad: ' + CAST(ERROR_SEVERITY() AS VARCHAR(10));
    PRINT 'Estado: ' + CAST(ERROR_STATE() AS VARCHAR(10));
    PRINT 'Procedimiento: ' + ISNULL(ERROR_PROCEDURE(), '-');
    PRINT 'Línea: ' + CAST(ERROR_LINE() AS VARCHAR(10));
    PRINT 'Mensaje: ' + ERROR_MESSAGE();

END CATCH;

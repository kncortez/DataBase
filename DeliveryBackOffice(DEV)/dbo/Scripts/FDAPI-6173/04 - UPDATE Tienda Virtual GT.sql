BEGIN TRY
    BEGIN TRANSACTION;

DECLARE @IdCatSubscriptionMICRO   INT = (SELECT IdCatSubscription FROM [dbo].[CatSubscription] WITH(NOLOCK) WHERE SubscriptionName='Paquete Micro'   AND IdCountry='GT'); --20
DECLARE @IdCatSubscriptionPETIT   INT = (SELECT IdCatSubscription FROM [dbo].[CatSubscription] WITH(NOLOCK) WHERE SubscriptionName='Paquete Petit'   AND IdCountry='GT'); --10
DECLARE @IdCatSubscriptionBASICO  INT = (SELECT IdCatSubscription FROM [dbo].[CatSubscription] WITH(NOLOCK) WHERE SubscriptionName='Paquete Básico'  AND IdCountry='GT'); --6
DECLARE @IdCatSubscriptionPLUS    INT = (SELECT IdCatSubscription FROM [dbo].[CatSubscription] WITH(NOLOCK) WHERE SubscriptionName='Paquete Plus'    AND IdCountry='GT'); --7
DECLARE @IdCatSubscriptionGOLD    INT = (SELECT IdCatSubscription FROM [dbo].[CatSubscription] WITH(NOLOCK) WHERE SubscriptionName='Paquete Gold'    AND IdCountry='GT'); --8
DECLARE @IdCatSubscriptionPLATINO INT = (SELECT IdCatSubscription FROM [dbo].[CatSubscription] WITH(NOLOCK) WHERE SubscriptionName='Paquete Platino' AND IdCountry='GT'); --11
DECLARE @IdCatSubscriptionPRO     INT = (SELECT IdCatSubscription FROM [dbo].[CatSubscription] WITH(NOLOCK) WHERE SubscriptionName='Paquete Pro'     AND IdCountry='GT'); --12


 --*********************  ACTUALIZAR PRECIO EN CATÁLOGO  *********************

--PAQUETE MICRO
UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='15 guías a Q38.00 c/u.',
    SubscriptionCost=570.00,
    Tag = NULL,
    DateUpdated=GETDATE(),
    TokenUpdated='SYS-BPEDROZA'
WHERE IdCatSubscription = @IdCatSubscriptionMICRO AND IdCountry='GT'

--PAQUETE PETIT
UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='25 guías a Q36.00 c/u.',
    SubscriptionCost=900.00,
    Tag = NULL,
    DateUpdated=GETDATE(),
    TokenUpdated='SYS-BPEDROZA'
WHERE IdCatSubscription = @IdCatSubscriptionPETIT AND IdCountry='GT'

--PAQUETE BÁSICO
UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='50 guías a Q34.00 c/u.',
    SubscriptionCost=1700.00,
    Tag = NULL,
    DateUpdated=GETDATE(),
    TokenUpdated='SYS-BPEDROZA'
WHERE IdCatSubscription = @IdCatSubscriptionBASICO AND IdCountry='GT'

--PAQUETE PLUS
UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='100 guías a Q32.00 c/u.',
    SubscriptionCost=3200.00,
    Tag = NULL,
    DateUpdated=GETDATE(),
    TokenUpdated='SYS-BPEDROZA'
WHERE IdCatSubscription = @IdCatSubscriptionPLUS AND IdCountry='GT'

--PAQUETE GOLD
UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='200 guías a Q30.00 c/u.',
    SubscriptionCost=6000.00,
    Tag = NULL,
    DateUpdated=GETDATE(),
    TokenUpdated='SYS-BPEDROZA'
WHERE IdCatSubscription = @IdCatSubscriptionGOLD AND IdCountry='GT'

--PAQUETE PLATINO
UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='400 guías a Q26.00 c/u.',
    SubscriptionCost=10400.00,
    Tag = NULL,
    DateUpdated=GETDATE(),
    TokenUpdated='SYS-BPEDROZA'
WHERE IdCatSubscription = @IdCatSubscriptionPLATINO AND IdCountry='GT'


 --*********************  ACTUALIZAR SUSCRIPCIÓN  *********************

--PAQUETE MICRO - ¿Qué es?
UPDATE [dbo].[CatSubscriptionDescription]
SET [Description]='Nuestro paquete te ofrece 15 guías de envío prepagadas con Tarifa única a todo el país, lo que significa que puedes enviar tus productos a cualquier destino sin preocuparte por tarifas variables. Pero eso no es todo, ¡nuestra tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes una gran cantidad de envíos de manera continua? Estas guías son ideales para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos sean más rentables y eficientes hoy mismo!',
    DateUpdated=GETDATE(),
    TokenUpdated='SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionMICRO AND RowStatus=1 AND Title='¿Qué es?'

--PAQUETE MICRO - ¿Cómo Funciona?
UPDATE [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +100 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Micro y podrás obtener tus guías prepagadas de 15 envíos con tarifa única a todo el país a Q38.00 c/u.',
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
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +100 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Petit y podrás obtener tus guías prepagadas de 25 envíos con tarifa única a todo el país a Q36.00 c/u.',
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
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +100 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Básico y podrás obtener tus guías prepagadas de 50 envíos con tarifa única a todo el país a Q34.00 c/u.',
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
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +100 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Plus y podrás obtener tus guías prepagadas de 100 envíos con tarifa única a todo el país a Q32.00 c/u.',
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
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +100 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Gold y podrás obtener tus guías prepagadas de 200 envíos con tarifa única a todo el país a Q30.00 c/u.',
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
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +100 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Platino y podrás obtener tus guías prepagadas de 400 envíos con tarifa única a todo el país a Q26.00 c/u.',
    DateUpdated=GETDATE(),
    TokenUpdated='SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionPLATINO AND RowStatus=1 AND Title='¿Cómo Funciona?'


 --*********************  ACTUALIZAR ATRIBUTOS  *********************

--PAQUETE MICRO
UPDATE dbo.CatSubscriptionAtribute
SET SubscriptionAttributeDescription     = '15 guías a Q38.00 c/u.',
    SubscriptionAttributeDescriptionLong = '15 guías a Q38.00 c/u.',
    DateUpdated = GETDATE(),
    TokenUpdated = 'SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionMICRO AND SubscriptionAttributeDescription='15 guías a Q37.00 c/u.'

--PAQUETE PETIT
UPDATE dbo.CatSubscriptionAtribute
SET SubscriptionAttributeDescription     = '25 guías a Q36.00 c/u.',
    SubscriptionAttributeDescriptionLong = '25 guías a Q36.00 c/u.',
    DateUpdated = GETDATE(),
    TokenUpdated = 'SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionPETIT AND SubscriptionAttributeDescription='25 guías a Q35.00 c/u.'

--PAQUETE BÁSICO
UPDATE dbo.CatSubscriptionAtribute
SET SubscriptionAttributeDescription     = '50 guías a Q34.00 c/u.',
    SubscriptionAttributeDescriptionLong = '50 guías a Q34.00 c/u.',
    DateUpdated = GETDATE(),
    TokenUpdated = 'SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionBASICO AND SubscriptionAttributeDescription='50 guías a Q33.00 c/u.'

--PAQUETE PLUS
UPDATE dbo.CatSubscriptionAtribute
SET SubscriptionAttributeDescription     = '100 guías a Q32.00 c/u.',
    SubscriptionAttributeDescriptionLong = '100 guías a Q32.00 c/u.',
    DateUpdated = GETDATE(),
    TokenUpdated = 'SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionPLUS AND SubscriptionAttributeDescription='100 guías a Q31.00 c/u.'

--PAQUETE GOLD
UPDATE dbo.CatSubscriptionAtribute
SET SubscriptionAttributeDescription     = '200 guías a Q30.00 c/u.',
    SubscriptionAttributeDescriptionLong = '200 guías a Q30.00 c/u.',
    DateUpdated = GETDATE(),
    TokenUpdated = 'SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionGOLD AND SubscriptionAttributeDescription='200 guías a Q29.00 c/u.'

--PAQUETE PLATINO
UPDATE dbo.CatSubscriptionAtribute
SET SubscriptionAttributeDescription     = '400 guías a Q26.00 c/u.',
    SubscriptionAttributeDescriptionLong = '400 guías a Q26.00 c/u.',
    DateUpdated = GETDATE(),
    TokenUpdated = 'SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionPLATINO AND SubscriptionAttributeDescription='400 guías a Q25.00 c/u.'


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

-- ============================================================
-- 1. CatSubscription (paquetes base)
-- ============================================================
PRINT '>>> [1/5] Iniciando INSERT en CatSubscription...'

BEGIN TRANSACTION
BEGIN TRY

    INSERT INTO dbo.CatSubscription
    (
        SubscriptionName, SubscriptionDescription, SubscriptionCost, SubscriptionFixedValue,
        SubscriptionMaxServiceFixedValue, SubscriptionValidity, SubscriptionWeight, RowStatus,
        TokenCreated, DateCreated, Icon, NextSalesPackageBanner, CatTypeSubscriptionId,
        CatProductCategoryId, Position, IdCountry, IdCatCurrencyCOD
    )
    VALUES
    ('Paquete MICRO',   '15 guías a $3.60 c/u.',  1.00,    0, 15,  6, 5, 1, 'SYS-BHERRERA', '2026-03-19 11:44:35', 'hwa-planMicroIcon',   'bannerSubsPlan4.png', 2, 12, 1, 'SV', 2),
    ('Paquete Petit',   '25 guías a $3.40 c/u.',  85.00,   0, 25,  6, 5, 1, 'SYS-BHERRERA', '2026-03-19 11:44:35', 'hwa-planPetitIcon',   'bannerSubsPlan1.png', 2, 12, 1, 'SV', 2),
    ('Paquete Básicos', '50 guías a $3.20 c/u.',  160.00,  0, 50,  6, 5, 1, 'SYS-BHERRERA', '2026-03-19 11:44:35', 'hwa-planBasicoIcon',  'bannerSubsPlan2.png', 2, 12, 1, 'SV', 2),
    ('Paquete Plus',    '100 guías a $2.80 c/u.', 280.00,  0, 100, 6, 5, 1, 'SYS-BHERRERA', '2026-03-19 11:44:35', 'hwa-planPlusIcon',    'bannerSubsPlan3.png', 2, 12, 1, 'SV', 2),
    ('Paquete Gold',    '200 guías a $2.60 c/u.', 520.00,  0, 200, 6, 5, 1, 'SYS-BHERRERA', '2026-03-19 11:44:35', 'hwa-planGoldIcon',    'bannerSubsPlan5.png', 2, 12, 2, 'SV', 2),
    ('Paquete Platino', '400 guías a $2.50 c/u.', 1000.00, 0, 400, 6, 5, 1, 'SYS-BHERRERA', '2026-03-19 11:44:35', 'hwa-planPlatinoIcon', 'bannerSubsPlan6.png', 2, 12, 3, 'SV', 2);

    COMMIT TRANSACTION
    PRINT '    [OK] CatSubscription insertado correctamente. Filas: ' + CAST(@@ROWCOUNT AS VARCHAR)

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION
    PRINT '    [ERROR] Falló INSERT en CatSubscription.'
    PRINT '    Mensaje : ' + ERROR_MESSAGE()
    PRINT '    Línea   : ' + CAST(ERROR_LINE() AS VARCHAR)
    PRINT '    Número  : ' + CAST(ERROR_NUMBER() AS VARCHAR)
END CATCH

-- Verificación
SELECT
    IdCatSubscription,
    SubscriptionName,
    SubscriptionCost,
    Position,
    IdCountry
FROM dbo.CatSubscription
WHERE IdCountry = 'SV' AND DateCreated >= '2026-03-19'
ORDER BY Position
GO


-- ============================================================
-- 2. MarketplaceProductTags
-- ============================================================
PRINT '>>> [2/5] Iniciando INSERT en MarketplaceProductTags...'

BEGIN TRANSACTION
BEGIN TRY

    INSERT INTO [DeliveryBackOffice].[dbo].[MarketplaceProductTags]
    (
        MarketplaceProductTagsName,
        MarketplaceProductTagsDescription,
        MarketplaceProductTagsOrder,
        RowStatus,
        TokenCreated,
        DateCreated,
        IdCountry
    )
    VALUES
    ('LO MÁS VENDIDO',    'En esta sección, encontrarás una selección de los productos más vendidos', 1, 1, 'SYS-BHERRERA', GETDATE(), 'SV'),
    ('NOVEDADES',          'En esta sección, encontrarás lo más reciente de nuestros productos',       2, 1, 'SYS-BHERRERA', GETDATE(), 'SV'),
    ('TODOS LOS PRODUCTOS','Desde membresías, planes con descuento hasta guías prepago',               3, 1, 'SYS-BHERRERA', GETDATE(), 'SV')

    COMMIT TRANSACTION
    PRINT '    [OK] MarketplaceProductTags insertado correctamente. Filas: ' + CAST(@@ROWCOUNT AS VARCHAR)

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION
    PRINT '    [ERROR] Falló INSERT en MarketplaceProductTags.'
    PRINT '    Mensaje : ' + ERROR_MESSAGE()
    PRINT '    Línea   : ' + CAST(ERROR_LINE() AS VARCHAR)
    PRINT '    Número  : ' + CAST(ERROR_NUMBER() AS VARCHAR)
END CATCH

-- Verificación
SELECT
    IdMarketplaceProductTags,
    MarketplaceProductTagsName,
    IdCountry
FROM DeliveryBackOffice.dbo.MarketplaceProductTags
WHERE IdCountry = 'SV'
ORDER BY MarketplaceProductTagsOrder
GO 


-- ============================================================
-- 2. MarketplaceTagsByProduct
-- ============================================================
PRINT '>>> [3/5] Iniciando INSERT en MarketplaceTagsByProduct...'

DECLARE @MASVENDIDO INT, @NOVEDADES INT, @PRODUCTOS INT;
DECLARE @MICRO INT, @PETIT INT, @BASICO INT, @PLUS INT, @GOLD INT, @PLATINO INT;

BEGIN TRANSACTION
BEGIN TRY

    SELECT @MASVENDIDO = IdMarketplaceProductTags
    FROM DeliveryBackOffice.dbo.MarketplaceProductTags
    WHERE IdCountry = 'SV' AND MarketplaceProductTagsName = 'LO MÁS VENDIDO'

    SELECT @NOVEDADES = IdMarketplaceProductTags
    FROM DeliveryBackOffice.dbo.MarketplaceProductTags
    WHERE IdCountry = 'SV' AND MarketplaceProductTagsName = 'NOVEDADES'

    SELECT @PRODUCTOS = IdMarketplaceProductTags
    FROM DeliveryBackOffice.dbo.MarketplaceProductTags
    WHERE IdCountry = 'SV' AND MarketplaceProductTagsName = 'TODOS LOS PRODUCTOS'

    SELECT @MICRO   = IdCatSubscription FROM CatSubscription WHERE IdCountry = 'SV' AND SubscriptionName = 'Paquete MICRO'
    SELECT @PETIT   = IdCatSubscription FROM CatSubscription WHERE IdCountry = 'SV' AND SubscriptionName = 'Paquete Petit'
    SELECT @BASICO  = IdCatSubscription FROM CatSubscription WHERE IdCountry = 'SV' AND SubscriptionName = 'Paquete Básicos'
    SELECT @PLUS    = IdCatSubscription FROM CatSubscription WHERE IdCountry = 'SV' AND SubscriptionName = 'Paquete Plus'
    SELECT @GOLD    = IdCatSubscription FROM CatSubscription WHERE IdCountry = 'SV' AND SubscriptionName = 'Paquete Gold'
    SELECT @PLATINO = IdCatSubscription FROM CatSubscription WHERE IdCountry = 'SV' AND SubscriptionName = 'Paquete Platino'

    -- Validar que todas las variables se resolvieron
    IF @MASVENDIDO IS NULL OR @NOVEDADES IS NULL OR @PRODUCTOS IS NULL
        THROW 50001, 'No se encontraron uno o más tags en MarketplaceProductTags para IdCountry = SV.', 1;
    IF @MICRO IS NULL OR @PETIT IS NULL OR @BASICO IS NULL OR @PLUS IS NULL OR @GOLD IS NULL OR @PLATINO IS NULL
        THROW 50002, 'No se encontraron uno o más paquetes en CatSubscription para IdCountry = SV.', 1;

    INSERT INTO [DeliveryBackOffice].[dbo].[MarketplaceTagsByProduct]
    (
        MarketplaceProductTagsId,
        RowStatus,
        TokenCreated,
        DateCreated,
        CatSubscriptionId,
        CatMembershipId,
        Position
    )
    VALUES
    -- LO MÁS VENDIDO
    (@MASVENDIDO, 1, 'SYS-BHERRERA', GETDATE(), @PETIT,   NULL, 1),
    -- NOVEDADES
    (@NOVEDADES,  1, 'SYS-BHERRERA', GETDATE(), @MICRO,   NULL, 1),
    (@NOVEDADES,  1, 'SYS-BHERRERA', GETDATE(), @PETIT,   NULL, 2),
    (@NOVEDADES,  1, 'SYS-BHERRERA', GETDATE(), @BASICO,  NULL, 3),
    (@NOVEDADES,  1, 'SYS-BHERRERA', GETDATE(), @PLUS,    NULL, 4),
    (@NOVEDADES,  1, 'SYS-BHERRERA', GETDATE(), @GOLD,    NULL, 5),
    (@NOVEDADES,  1, 'SYS-BHERRERA', GETDATE(), @PLATINO, NULL, 6),
    -- TODOS LOS PRODUCTOS
    (@PRODUCTOS,  1, 'SYS-BHERRERA', GETDATE(), @MICRO,   NULL, 1),
    (@PRODUCTOS,  1, 'SYS-BHERRERA', GETDATE(), @PETIT,   NULL, 2),
    (@PRODUCTOS,  1, 'SYS-BHERRERA', GETDATE(), @BASICO,  NULL, 3),
    (@PRODUCTOS,  1, 'SYS-BHERRERA', GETDATE(), @PLUS,    NULL, 4),
    (@PRODUCTOS,  1, 'SYS-BHERRERA', GETDATE(), @GOLD,    NULL, 5),
    (@PRODUCTOS,  1, 'SYS-BHERRERA', GETDATE(), @PLATINO, NULL, 6)

    COMMIT TRANSACTION
    PRINT '    [OK] MarketplaceTagsByProduct insertado correctamente. Filas: ' + CAST(@@ROWCOUNT AS VARCHAR)

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION
    PRINT '    [ERROR] Falló INSERT en MarketplaceTagsByProduct.'
    PRINT '    Mensaje : ' + ERROR_MESSAGE()
    PRINT '    Línea   : ' + CAST(ERROR_LINE() AS VARCHAR)
    PRINT '    Número  : ' + CAST(ERROR_NUMBER() AS VARCHAR)
END CATCH

-- Verificación
SELECT
    MTP.MarketplaceProductTagsId,
    MPT.MarketplaceProductTagsName,
    CS.SubscriptionName,
    MTP.Position
FROM DeliveryBackOffice.dbo.MarketplaceTagsByProduct MTP
INNER JOIN DeliveryBackOffice.dbo.MarketplaceProductTags MPT
    ON MTP.MarketplaceProductTagsId = MPT.IdMarketplaceProductTags
INNER JOIN DeliveryBackOffice.dbo.CatSubscription CS
    ON MTP.CatSubscriptionId = CS.IdCatSubscription
WHERE CS.IdCountry = 'SV'
ORDER BY MTP.MarketplaceProductTagsId, MTP.Position
GO 


-- ============================================================
-- 3. CatSubscriptionAtribute
-- ============================================================
PRINT '>>> [4/5] Iniciando INSERT en CatSubscriptionAtribute...'

DECLARE @MICRO INT, @PETIT INT, @BASICO INT, @PLUS INT, @GOLD INT, @PLATINO INT;

BEGIN TRANSACTION
BEGIN TRY

    SELECT @MICRO   = IdCatSubscription FROM CatSubscription WHERE IdCountry = 'SV' AND SubscriptionName = 'Paquete MICRO'
    SELECT @PETIT   = IdCatSubscription FROM CatSubscription WHERE IdCountry = 'SV' AND SubscriptionName = 'Paquete Petit'
    SELECT @BASICO  = IdCatSubscription FROM CatSubscription WHERE IdCountry = 'SV' AND SubscriptionName = 'Paquete Básicos'
    SELECT @PLUS    = IdCatSubscription FROM CatSubscription WHERE IdCountry = 'SV' AND SubscriptionName = 'Paquete Plus'
    SELECT @GOLD    = IdCatSubscription FROM CatSubscription WHERE IdCountry = 'SV' AND SubscriptionName = 'Paquete Gold'
    SELECT @PLATINO = IdCatSubscription FROM CatSubscription WHERE IdCountry = 'SV' AND SubscriptionName = 'Paquete Platino'

    IF @MICRO IS NULL OR @PETIT IS NULL OR @BASICO IS NULL OR @PLUS IS NULL OR @GOLD IS NULL OR @PLATINO IS NULL
        THROW 50003, 'No se encontraron uno o más paquetes en CatSubscription para IdCountry = SV.', 1;

    INSERT INTO [DeliveryBackOffice].[dbo].[CatSubscriptionAtribute]
    (
        CatSubscriptionId,
        CatAttributeId,
        SubscriptionAttributeValue,
        SubscriptionAttributeDescription,
        SubscriptionAttributeDescriptionLong,
        SubscriptionAttributePosition,
        RowStatus,
        TokenCreated,
        DateCreated
    )
    VALUES
    -- MICRO
    (@MICRO, 1, 1, '15 guías a $3.60 c/u.',               '15 guías a $3.60 c/u.',               1, 1, 'SYS-BHERRERA', GETDATE()),
    (@MICRO, 1, 1, 'Tarifa única en todo el país.',        'Tarifa única en todo el país.',        2, 1, 'SYS-BHERRERA', GETDATE()),
    (@MICRO, 1, 1, 'Costo único para todos tus clientes.', 'Costo único para todos tus clientes.', 3, 1, 'SYS-BHERRERA', GETDATE()),
    (@MICRO, 1, 1, 'Hasta 10 Libras.',                    'Hasta 10 Libras.',                     4, 1, 'SYS-BHERRERA', GETDATE()),
    -- PETIT
    (@PETIT, 1, 1, '25 guías a $3.40 c/u.',               '25 guías a $3.40 c/u.',               1, 1, 'SYS-BHERRERA', GETDATE()),
    (@PETIT, 1, 1, 'Tarifa única en todo el país.',        'Tarifa única en todo el país.',        2, 1, 'SYS-BHERRERA', GETDATE()),
    (@PETIT, 1, 1, 'Costo único para todos tus clientes.', 'Costo único para todos tus clientes.', 3, 1, 'SYS-BHERRERA', GETDATE()),
    (@PETIT, 1, 1, 'Hasta 10 Libras.',                    'Hasta 10 Libras.',                     4, 1, 'SYS-BHERRERA', GETDATE()),
    -- BASICO
    (@BASICO, 1, 1, '50 guías a $3.20 c/u.',              '50 guías a $3.20 c/u.',               1, 1, 'SYS-BHERRERA', GETDATE()),
    (@BASICO, 1, 1, 'Tarifa única en todo el país.',       'Tarifa única en todo el país.',        2, 1, 'SYS-BHERRERA', GETDATE()),
    (@BASICO, 1, 1, 'Costo único para todos tus clientes.','Costo único para todos tus clientes.', 3, 1, 'SYS-BHERRERA', GETDATE()),
    (@BASICO, 1, 1, 'Hasta 10 Libras.',                   'Hasta 10 Libras.',                     4, 1, 'SYS-BHERRERA', GETDATE()),
    (@BASICO, 1, 1, 'La tarifa más barata del mercado.',  'La tarifa más barata del mercado.',    5, 1, 'SYS-BHERRERA', GETDATE()),
    (@BASICO, 1, 1, 'Vigencia de 6 meses.',               'Vigencia de 6 meses.',                 6, 1, 'SYS-BHERRERA', GETDATE()),
    -- PLUS
    (@PLUS, 1, 1, '100 guías a $2.80 c/u.',               '100 guías a $2.80 c/u.',              1, 1, 'SYS-BHERRERA', GETDATE()),
    (@PLUS, 1, 1, 'Costo único para todos tus clientes.',  'Costo único para todos tus clientes.', 2, 1, 'SYS-BHERRERA', GETDATE()),
    (@PLUS, 1, 1, 'Tarifa única en todo el país.',         'Tarifa única en todo el país.',        3, 1, 'SYS-BHERRERA', GETDATE()),
    (@PLUS, 1, 1, 'Hasta 10 Libras.',                     'Hasta 10 Libras.',                     4, 1, 'SYS-BHERRERA', GETDATE()),
    (@PLUS, 1, 1, 'La tarifa más barata del mercado.',    'La tarifa más barata del mercado.',    5, 1, 'SYS-BHERRERA', GETDATE()),
    (@PLUS, 1, 1, 'Vigencia de 6 meses.',                 'Vigencia de 6 meses.',                 6, 1, 'SYS-BHERRERA', GETDATE()),
    -- GOLD
    (@GOLD, 1, 1, '200 guías a $2.60 c/u.',               '200 guías a $2.60 c/u.',              1, 1, 'SYS-BHERRERA', GETDATE()),
    (@GOLD, 1, 1, 'Costo único para todos tus clientes.',  'Costo único para todos tus clientes.', 2, 1, 'SYS-BHERRERA', GETDATE()),
    (@GOLD, 1, 1, 'Tarifa única en todo el país.',         'Tarifa única en todo el país.',        3, 1, 'SYS-BHERRERA', GETDATE()),
    (@GOLD, 1, 1, 'Hasta 10 Libras.',                     'Hasta 10 Libras.',                     4, 1, 'SYS-BHERRERA', GETDATE()),
    (@GOLD, 1, 1, 'La tarifa más barata del mercado.',    'La tarifa más barata del mercado.',    5, 1, 'SYS-BHERRERA', GETDATE()),
    (@GOLD, 1, 1, 'Vigencia de 6 meses.',                 'Vigencia de 6 meses.',                 6, 1, 'SYS-BHERRERA', GETDATE()),
    -- PLATINO
    (@PLATINO, 1, 1, '400 guías a $2.50 c/u.',              '400 guías a $2.50 c/u.',              1, 1, 'SYS-BHERRERA', GETDATE()),
    (@PLATINO, 1, 1, 'Tarifa única en todo el país.',        'Tarifa única en todo el país.',       2, 1, 'SYS-BHERRERA', GETDATE()),
    (@PLATINO, 1, 1, 'Costo único para todos tus clientes.', 'Costo único para todos tus clientes.',3, 1, 'SYS-BHERRERA', GETDATE()),
    (@PLATINO, 1, 1, 'Hasta 10 Libras.',                    'Hasta 10 Libras.',                    4, 1, 'SYS-BHERRERA', GETDATE()),
    (@PLATINO, 1, 1, 'La tarifa más barata del mercado.',   'La tarifa más barata del mercado.',   5, 1, 'SYS-BHERRERA', GETDATE()),
    (@PLATINO, 1, 1, 'Vigencia de 6 meses.',                'Vigencia de 6 meses.',                6, 1, 'SYS-BHERRERA', GETDATE())

    COMMIT TRANSACTION
    PRINT '    [OK] CatSubscriptionAtribute insertado correctamente. Filas: ' + CAST(@@ROWCOUNT AS VARCHAR)

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION
    PRINT '    [ERROR] Falló INSERT en CatSubscriptionAtribute.'
    PRINT '    Mensaje : ' + ERROR_MESSAGE()
    PRINT '    Línea   : ' + CAST(ERROR_LINE() AS VARCHAR)
    PRINT '    Número  : ' + CAST(ERROR_NUMBER() AS VARCHAR)
END CATCH

-- Verificación
SELECT
    CS.SubscriptionName,
    CPA.SubscriptionAttributeDescription,
    CPA.SubscriptionAttributePosition
FROM DeliveryBackOffice.dbo.CatSubscriptionAtribute CPA
INNER JOIN DeliveryBackOffice.dbo.CatSubscription CS
    ON CPA.CatSubscriptionId = CS.IdCatSubscription
WHERE CS.IdCountry = 'SV'
ORDER BY CS.Position, CPA.SubscriptionAttributePosition
GO 


-- ============================================================
-- 4. CatSubscriptionDescription
-- ============================================================
PRINT '>>> [5/5] Iniciando INSERT en CatSubscriptionDescription...'

DECLARE @MICRO INT, @PETIT INT, @BASICO INT, @PLUS INT, @GOLD INT, @PLATINO INT;

BEGIN TRANSACTION
BEGIN TRY

    SELECT @MICRO   = IdCatSubscription FROM CatSubscription WHERE IdCountry = 'SV' AND SubscriptionName = 'Paquete MICRO'
    SELECT @PETIT   = IdCatSubscription FROM CatSubscription WHERE IdCountry = 'SV' AND SubscriptionName = 'Paquete Petit'
    SELECT @BASICO  = IdCatSubscription FROM CatSubscription WHERE IdCountry = 'SV' AND SubscriptionName = 'Paquete Básicos'
    SELECT @PLUS    = IdCatSubscription FROM CatSubscription WHERE IdCountry = 'SV' AND SubscriptionName = 'Paquete Plus'
    SELECT @GOLD    = IdCatSubscription FROM CatSubscription WHERE IdCountry = 'SV' AND SubscriptionName = 'Paquete Gold'
    SELECT @PLATINO = IdCatSubscription FROM CatSubscription WHERE IdCountry = 'SV' AND SubscriptionName = 'Paquete Platino'

    IF @MICRO IS NULL OR @PETIT IS NULL OR @BASICO IS NULL OR @PLUS IS NULL OR @GOLD IS NULL OR @PLATINO IS NULL
        THROW 50004, 'No se encontraron uno o más paquetes en CatSubscription para IdCountry = SV.', 1;

    INSERT INTO [DeliveryBackOffice].[dbo].[CatSubscriptionDescription]
    (
        CatSubscriptionId,
        Title,
        Description,
        Position,
        Type,
        RowStatus,
        TokenCreated,
        DateCreated
    )
    VALUES
    -- MICRO
    (@MICRO, '¿Qué es?',             'Nuestro paquete te ofrece 15 guías de envío prepagadas con Tarifa única a todo el país, lo que significa que puedes enviar tus productos a cualquier destino sin preocuparte por tarifas variables. Pero eso no es todo, ¡nuestra tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes una gran cantidad de envíos de manera continua? Estas guías son ideales para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos sean más rentables y eficientes hoy mismo!', 1, 'PAQUETE MICRO',   1, 'SYS-BHERRERA', GETDATE()),
    (@MICRO, '¿Cómo Funciona?',      'Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Micro y podrás obtener tus guías prepagadas de 15 envíos con tarifa única a todo el país a $3.60 c/u.', 2, 'PAQUETE MICRO',   1, 'SYS-BHERRERA', GETDATE()),
    (@MICRO, 'Aplican restricciones', 'En caso de que tu envío exceda el peso, de 0 a 10 libras, consulta los términos y condiciones.', 3, 'PAQUETE MICRO',   1, 'SYS-BHERRERA', GETDATE()),
    -- PETIT
    (@PETIT, '¿Qué es?',             'Nuestro paquete te ofrece 25 guías de envío prepagadas con Tarifa única a todo el país, lo que significa que puedes enviar tus productos a cualquier destino sin preocuparte por tarifas variables. Pero eso no es todo, ¡nuestra tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes una gran cantidad de envíos de manera continua? Estas guías son ideales para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos sean más rentables y eficientes hoy mismo!', 1, 'PAQUETE PETIT',   1, 'SYS-BHERRERA', GETDATE()),
    (@PETIT, '¿Cómo Funciona?',      'Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Petit y podrás obtener tus guías prepagadas de 25 envíos con tarifa única a todo el país a $3.40 c/u.', 2, 'PAQUETE PETIT',   1, 'SYS-BHERRERA', GETDATE()),
    (@PETIT, 'Aplican restricciones', 'En caso de que tu envío exceda el peso, de 0 a 10 libras, consulta los términos y condiciones.', 5, 'PAQUETE PETIT',   1, 'SYS-BHERRERA', GETDATE()),
    -- BASICO
    (@BASICO, '¿Qué es?',             'Nuestro paquete te ofrece 50 guías de envío prepagadas con Tarifa única a todo el país, lo que significa que puedes enviar tus productos a cualquier destino sin preocuparte por tarifas variables. Pero eso no es todo, ¡nuestra tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes una gran cantidad de envíos de manera continua? Estas guías son ideales para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos sean más rentables y eficientes hoy mismo!', 1, 'PAQUETE BÁSICO',  1, 'SYS-BHERRERA', GETDATE()),
    (@BASICO, '¿Cómo Funciona?',      'Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Basico y podrás obtener tus guías prepagadas de 50 envíos con tarifa única a todo el país a $3.20 c/u.', 2, 'PAQUETE BÁSICO',  1, 'SYS-BHERRERA', GETDATE()),
    (@BASICO, 'Aplican restricciones', 'En caso de que tu envío exceda el peso, de 0 a 10 libras, consulta los términos y condiciones.', 5, 'PAQUETE BÁSICO',  1, 'SYS-BHERRERA', GETDATE()),
    -- PLUS
    (@PLUS, '¿Qué es?',             'Nuestro paquete te ofrece 100 guías de envío prepagadas con Tarifa única a todo el país, lo que significa que puedes enviar tus productos a cualquier destino sin preocuparte por tarifas variables. Pero eso no es todo, ¡nuestra tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes una gran cantidad de envíos de manera continua? Estas guías son ideales para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos sean más rentables y eficientes hoy mismo!', 1, 'PAQUETE PLUS',    1, 'SYS-BHERRERA', GETDATE()),
    (@PLUS, '¿Cómo Funciona?',      'Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Plus y podrás obtener tus guías prepagadas de 100 envíos con tarifa única a todo el país a $2.80 c/u.', 2, 'PAQUETE PLUS',    1, 'SYS-BHERRERA', GETDATE()),
    (@PLUS, 'Aplican restricciones', 'En caso de que tu envío exceda el peso, de 0 a 10 libras, consulta los términos y condiciones.', 5, 'PAQUETE PLUS',    1, 'SYS-BHERRERA', GETDATE()),
    -- GOLD
    (@GOLD, '¿Qué es?',             'Nuestro paquete te ofrece 200 guías de envío prepagadas con Tarifa única a todo el país, lo que significa que puedes enviar tus productos a cualquier destino sin preocuparte por tarifas variables. Pero eso no es todo, ¡nuestra tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes una gran cantidad de envíos de manera continua? Estas guías son ideales para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos sean más rentables y eficientes hoy mismo!', 1, 'PAQUETE GOLD',    1, 'SYS-BHERRERA', GETDATE()),
    (@GOLD, '¿Cómo Funciona?',      'Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Gold y podrás obtener tus guías prepagadas de 200 envíos con tarifa única a todo el país a $2.60 c/u.', 2, 'PAQUETE GOLD',    1, 'SYS-BHERRERA', GETDATE()),
    (@GOLD, 'Aplican restricciones', 'En caso de que tu envío exceda el peso, de 0 a 10 libras, consulta los términos y condiciones.', 5, 'PAQUETE GOLD',    1, 'SYS-BHERRERA', GETDATE()),
    -- PLATINO  ← corregido: era PLATINO sin @
    (@PLATINO, '¿Qué es?',             'Nuestro paquete te ofrece 400 guías de envío prepagadas con Tarifa única a todo el país, lo que significa que puedes enviar tus productos a cualquier destino sin preocuparte por tarifas variables. Pero eso no es todo, ¡nuestra tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes una gran cantidad de envíos de manera continua? Estas guías son ideales para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos sean más rentables y eficientes hoy mismo!', 1, 'PAQUETE PLATINO', 1, 'SYS-BHERRERA', GETDATE()),
    (@PLATINO, '¿Cómo Funciona?',      'Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Platino y podrás obtener tus guías prepagadas de 400 envíos con tarifa única a todo el país a $2.50 c/u.', 2, 'PAQUETE PLATINO', 1, 'SYS-BHERRERA', GETDATE()),
    (@PLATINO, 'Aplican restricciones', 'En caso de que tu envío exceda el peso, de 0 a 10 libras, consulta los términos y condiciones.', 5, 'PAQUETE PLATINO', 1, 'SYS-BHERRERA', GETDATE())

    COMMIT TRANSACTION
    PRINT '    [OK] CatSubscriptionDescription insertado correctamente. Filas: ' + CAST(@@ROWCOUNT AS VARCHAR)

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION
    PRINT '    [ERROR] Falló INSERT en CatSubscriptionDescription.'
    PRINT '    Mensaje : ' + ERROR_MESSAGE()
    PRINT '    Línea   : ' + CAST(ERROR_LINE() AS VARCHAR)
    PRINT '    Número  : ' + CAST(ERROR_NUMBER() AS VARCHAR)
END CATCH

-- Verificación
SELECT
    CPD.IdCatSubscriptionDescription,
    CPD.CatSubscriptionId,
    CS.SubscriptionName,
    CPD.Title,
    CPD.Position,
    CPD.Type,
    CPD.RowStatus
FROM DeliveryBackOffice.dbo.CatSubscriptionDescription CPD
INNER JOIN DeliveryBackOffice.dbo.CatSubscription CS
    ON CPD.CatSubscriptionId = CS.IdCatSubscription
WHERE CS.IdCountry = 'SV'
ORDER BY CS.Position, CPD.Position
GO 
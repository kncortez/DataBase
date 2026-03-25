/***************************************************************************************************
* TICKET:       FDAPI-5983
* DESCRIPCION:  Actualización de paquetes de suscripción para Guatemala (GT)
* AUTOR:        SYS-BILKAR
* FECHA:        2026-03-25
* PAIS:         Guatemala (GT)
* BASE DE DATOS: DeliveryBackOffice
*
* PAQUETES INCLUIDOS:
*   1. MICRO   (ID: 20) - 15 guías  @ Q37.00 c/u = Q555.00
*   2. PETIT   (ID: 10) - 25 guías  @ Q35.00 c/u = Q875.00
*   3. BASICO  (ID: 6)  - 50 guías  @ Q33.00 c/u = Q1,650.00
*   4. PLUS    (ID: 7)  - 100 guías @ Q31.00 c/u = Q3,100.00
*   5. GOLD    (ID: 8)  - 200 guías @ Q29.00 c/u = Q5,800.00
*   6. PLATINO (ID: 11) - 400 guías @ Q25.00 c/u = Q10,000.00
*
* TABLAS AFECTADAS:
*   - CatSubscription
*   - CatSubscriptionAtribute
*   - CatSubscriptionDescription
*
* INSTRUCCIONES PARA QA:
*   - El script incluye transacción automática con ROLLBACK en caso de error
*   - Si MODE = 'TEST', se hace ROLLBACK automático (sin cambios permanentes)
*   - Si MODE = 'EXEC', se hace COMMIT (cambios permanentes)
*   - Revisar mensajes PRINT para verificar éxito de cada operación
***************************************************************************************************/

USE DeliveryBackOffice;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

-- ============================================================================
-- CONFIGURACION DE MODO DE EJECUCION
-- ============================================================================
DECLARE @MODE VARCHAR(10) = 'TEST';  -- 'TEST' = ROLLBACK | 'EXEC' = COMMIT
DECLARE @ExecutionDate DATETIME = GETDATE();
DECLARE @UpdatedBy NVARCHAR(50) = N'SYS-BILKAR';

PRINT '====================================================================';
PRINT 'FDAPI-5983 - Actualización Paquetes Guatemala';
PRINT '====================================================================';
PRINT 'Modo de ejecución: ' + @MODE;
PRINT 'Fecha de ejecución: ' + CONVERT(VARCHAR, @ExecutionDate, 120);
PRINT 'Usuario: ' + @UpdatedBy;
PRINT '====================================================================';
PRINT '';

BEGIN TRY
    BEGIN TRANSACTION;

    -- ========================================================================
    -- SECCION 1: PAQUETE MICRO (ID: 20)
    -- Precio: Q555.00 | Guías: 15 | Precio unitario: Q37.00
    -- ========================================================================
    PRINT '>> Procesando PAQUETE MICRO (ID: 20)...';

    -- 1.1 Actualizar CatSubscription
    UPDATE DeliveryBackOffice.dbo.CatSubscription 
    SET SubscriptionName = N'Paquete MICRO', 
        SubscriptionDescription = N'15 guías a Q37.00 c/u.', 
        SubscriptionCost = 555.00, 
        SubscriptionFixedValue = 0, 
        SubscriptionMaxServiceFixedValue = 15, 
        SubscriptionValidity = 6, 
        SubscriptionWeight = 5, 
        RowStatus = 1, 
        TokenUpdated = N'SYS-BILKAR', 
        DateUpdated = N'2025-12-25 08:00:00.000' 
    WHERE IdCatSubscription = 20;

    -- 1.2 Actualizar CatSubscriptionAtribute
    UPDATE DeliveryBackOffice.dbo.CatSubscriptionAtribute 
    SET CatSubscriptionId = 20, CatAttributeId = 1, SubscriptionAttributeValue = N'1', 
        SubscriptionAttributeDescription = N'15 guías a Q37.00 c/u.', SubscriptionAttributePosition = 1, 
        RowStatus = 1, TokenUpdated = N'SYS-BILKAR', DateUpdated = N'2026-03-25 08:00:00.990', 
        SubscriptionAttributeDescriptionLong = N'15 guías a Q37 c/u.', 
        CatSubscriptionAttributeIcon = N'fa fa-check-circle fa-2x' 
    WHERE IdCatSubscriptionAttribute = 140;

    UPDATE DeliveryBackOffice.dbo.CatSubscriptionAtribute 
    SET CatSubscriptionId = 20, CatAttributeId = 1, SubscriptionAttributeValue = N'1', 
        SubscriptionAttributeDescription = N'Tarifa única en todo el país.', SubscriptionAttributePosition = 2, 
        RowStatus = 1, TokenUpdated = N'SYS-BILKAR', DateUpdated = N'2026-03-25 08:00:00.990', 
        SubscriptionAttributeDescriptionLong = N'Tarifa única en todo el país.', 
        CatSubscriptionAttributeIcon = N'fa fa-map fa-2x' 
    WHERE IdCatSubscriptionAttribute = 142;

    UPDATE DeliveryBackOffice.dbo.CatSubscriptionAtribute 
    SET CatSubscriptionId = 20, CatAttributeId = 1, SubscriptionAttributeValue = N'1', 
        SubscriptionAttributeDescription = N'Costo único para todos tus clientes.', SubscriptionAttributePosition = 3, 
        RowStatus = 1, TokenUpdated = N'SYS-BILKAR', DateUpdated = N'2026-03-25 08:00:00.990', 
        SubscriptionAttributeDescriptionLong = N'Costo único para todos tus clientes.', 
        CatSubscriptionAttributeIcon = N'bi bi-cash fa-2x' 
    WHERE IdCatSubscriptionAttribute = 144;

    UPDATE DeliveryBackOffice.dbo.CatSubscriptionAtribute 
    SET CatSubscriptionId = 20, CatAttributeId = 1, SubscriptionAttributeValue = N'1', 
        SubscriptionAttributeDescription = N'Hasta 10 Libras.', SubscriptionAttributePosition = 4, 
        RowStatus = 1, TokenUpdated = N'SYS-BILKAR', DateUpdated = N'2026-03-25 08:00:00.990', 
        SubscriptionAttributeDescriptionLong = N'Hasta 10 Libras.', 
        CatSubscriptionAttributeIcon = N'fa fa-archive fa-2x' 
    WHERE IdCatSubscriptionAttribute = 146;

    -- 1.3 Actualizar CatSubscriptionDescription
    UPDATE DeliveryBackOffice.dbo.CatSubscriptionDescription 
    SET Title = N'¿Qué es?', 
        Description = N'Nuestro paquete te ofrece <STRONG>15 guías</STRONG> de envío prepagadas con Tarifa única a   
todo el país, lo que significa que puedes enviar tus productos a cualquier   
destino sin preocuparte por tarifas variables. Pero eso no es todo, ¡nuestra   
tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías   
prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes   
una gran cantidad de envíos de manera continua? Estas guías son ideales   
para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una  
tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos   
sean más rentables y eficientes hoy mismo!  ', 
        Position = 1, Type = N'PAQUETE MICRO', CatSubscriptionId = 20, 
        RowStatus = 1, DateUpdated = N'2026-03-25 08:00:00.990', TokenUpdated = N'SYS-BILKAR' 
    WHERE IdCatSubscriptionDescription = 66;

    UPDATE DeliveryBackOffice.dbo.CatSubscriptionDescription 
    SET Title = N'¿Cómo Funciona?', 
        Description = N'Compra en la tienda virtual y recibe las guías en tu correo electrónico.   
Prepara tus paquetes, completa la información de envío y entrégalos en las   
+90 agencias express center o puedes solicitar la recolección a tu casa u   
oficina. Rastrea el progreso del envío con el número de guía proporcionado   
para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al   
centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de   
los detalles logísticos. Adquiere tu Paquete Micro y podrás obtener tus   
guías prepagadas de 15 envíos con tarifa única a todo el país a Q37.00   
c/u.', 
        Position = 2, Type = N'PAQUETE MICRO', CatSubscriptionId = 20, 
        RowStatus = 1, DateUpdated = N'2026-03-25 08:00:00.990', TokenUpdated = N'SYS-BILKAR' 
    WHERE IdCatSubscriptionDescription = 67;

    UPDATE DeliveryBackOffice.dbo.CatSubscriptionDescription 
    SET Title = N'Aplican restricciones', 
        Description = N'En caso de que tu envío exceda el peso, de 0 a 10 libras, consulta los   
términos y condiciones.', 
        Position = 3, Type = N'PAQUETE MICRO', CatSubscriptionId = 20, 
        RowStatus = 1, DateUpdated = N'2026-03-25 08:00:00.990', TokenUpdated = N'SYS-BILKAR' 
    WHERE IdCatSubscriptionDescription = 68;

    PRINT '   [OK] PAQUETE MICRO actualizado correctamente';


    -- ========================================================================
    -- SECCION 2: PAQUETE PETIT (ID: 10)
    -- Precio: Q875.00 | Guías: 25 | Precio unitario: Q35.00
    -- ========================================================================
    PRINT '>> Procesando PAQUETE PETIT (ID: 10)...';

    -- 2.1 Actualizar CatSubscription
    UPDATE DeliveryBackOffice.dbo.CatSubscription 
    SET SubscriptionName = N'Paquete Petit', 
        SubscriptionDescription = N'25 guías a Q35.00 c/u.', 
        SubscriptionCost = 875.00, 
        SubscriptionFixedValue = 0, 
        SubscriptionMaxServiceFixedValue = 25, 
        SubscriptionValidity = 6, 
        SubscriptionWeight = 0, 
        RowStatus = 1, 
        TokenUpdated = N'SYS-BILKAR', 
        DateUpdated = N'2026-03-25 08:00:00.990' 
    WHERE IdCatSubscription = 10;

    -- 2.2 Actualizar CatSubscriptionAtribute
    UPDATE DeliveryBackOffice.dbo.CatSubscriptionAtribute 
    SET CatSubscriptionId = 10, CatAttributeId = 1, SubscriptionAttributeValue = N'1', 
        SubscriptionAttributeDescription = N'25 guías a Q35.00 c/u.', SubscriptionAttributePosition = 1, 
        RowStatus = 1, TokenUpdated = N'SYS-BILKAR', DateUpdated = N'2025-12-08 08:42:06.993', 
        SubscriptionAttributeDescriptionLong = N'25 guías a Q35 c/u.', 
        CatSubscriptionAttributeIcon = N'fa fa-check-circle fa-2x' 
    WHERE IdCatSubscriptionAttribute = 83;

    UPDATE DeliveryBackOffice.dbo.CatSubscriptionAtribute 
    SET CatSubscriptionId = 10, CatAttributeId = 1, SubscriptionAttributeValue = N'1', 
        SubscriptionAttributeDescription = N'Tarifa única en todo el país.', SubscriptionAttributePosition = 2, 
        RowStatus = 1, TokenUpdated = N'SYS-BILKAR', DateUpdated = N'2024-05-15 23:51:33.250', 
        SubscriptionAttributeDescriptionLong = N'Tarifa única en todo el país.', 
        CatSubscriptionAttributeIcon = N'fa fa-map fa-2x' 
    WHERE IdCatSubscriptionAttribute = 84;

    UPDATE DeliveryBackOffice.dbo.CatSubscriptionAtribute 
    SET CatSubscriptionId = 10, CatAttributeId = 1, SubscriptionAttributeValue = N'1', 
        SubscriptionAttributeDescription = N'Costo único para todos tus clientes.', SubscriptionAttributePosition = 3, 
        RowStatus = 1, TokenUpdated = N'SYS-BILKAR', DateUpdated = N'2024-05-15 23:51:37.890', 
        SubscriptionAttributeDescriptionLong = N'Costo único para todos tus clientes.', 
        CatSubscriptionAttributeIcon = N'bi bi-cash fa-2x' 
    WHERE IdCatSubscriptionAttribute = 85;

    UPDATE DeliveryBackOffice.dbo.CatSubscriptionAtribute 
    SET CatSubscriptionId = 10, CatAttributeId = 1, SubscriptionAttributeValue = N'1', 
        SubscriptionAttributeDescription = N'Hasta 10 Libras.', SubscriptionAttributePosition = 4, 
        RowStatus = 1, TokenUpdated = N'SYS-BILKAR', DateUpdated = N'2024-05-15 23:51:44.670', 
        SubscriptionAttributeDescriptionLong = N'Hasta 10 Libras.', 
        CatSubscriptionAttributeIcon = N'fa fa-archive fa-2x' 
    WHERE IdCatSubscriptionAttribute = 86;

    -- 2.3 Actualizar CatSubscriptionDescription
    UPDATE DeliveryBackOffice.dbo.CatSubscriptionDescription 
    SET Title = N'¿Qué es?', 
        Description = N'Nuestro paquete te ofrece 25 guías de envío prepagadas con Tarifa única a   
todo el país, lo que significa que puedes enviar tus productos a cualquier   
destino sin preocuparte por tarifas variables. Pero eso no es todo, ¡nuestra   
tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías   
prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes   
una gran cantidad de envíos de manera continua? Estas guías son ideales   
para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una   
tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos   
sean más rentables y eficientes hoy mismo!', 
        Position = 1, Type = N'PAQUETE PETIT', CatSubscriptionId = 10, 
        RowStatus = 1, DateUpdated = N'2026-03-25 08:00:00.990', TokenUpdated = N'SYS-BILKAR' 
    WHERE IdCatSubscriptionDescription = 33;

    UPDATE DeliveryBackOffice.dbo.CatSubscriptionDescription 
    SET Title = N'¿Cómo Funciona?', 
        Description = N'Compra en la tienda virtual y recibe las guías en tu correo electrónico.   
Prepara tus paquetes, completa la información de envío y entrégalos en las   
+90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado   
para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al   
centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de   
los detalles logísticos. Adquiere tu Paquete Petit y podrás obtener tus   
guías prepagadas de 25 envíos con tarifa única a todo el país a Q35.00   
c/u.', 
        Position = 2, Type = N'PAQUETE PETIT', CatSubscriptionId = 10, 
        RowStatus = 1, DateUpdated = N'2026-03-25 08:00:00.990', TokenUpdated = N'SYS-BILKAR' 
    WHERE IdCatSubscriptionDescription = 34;

    UPDATE DeliveryBackOffice.dbo.CatSubscriptionDescription 
    SET Title = N'Aplican restricciones', 
        Description = N'En caso de que tu envío exceda el peso, de 0 a 10 libras, consulta los   
términos y condiciones.', 
        Position = 5, Type = N'PAQUETE PETIT', CatSubscriptionId = 10, 
        RowStatus = 1, DateUpdated = N'2026-03-25 08:00:00.990', TokenUpdated = N'SYS-BILKAR' 
    WHERE IdCatSubscriptionDescription = 43;

    PRINT '   [OK] PAQUETE PETIT actualizado correctamente';


    -- ========================================================================
    -- SECCION 3: PAQUETE BASICO (ID: 6)
    -- Precio: Q1,650.00 | Guías: 50 | Precio unitario: Q33.00
    -- ========================================================================
    PRINT '>> Procesando PAQUETE BASICO (ID: 6)...';

    -- 3.1 Actualizar CatSubscription
    UPDATE DeliveryBackOffice.dbo.CatSubscription 
    SET SubscriptionName = N'Paquete Básico', 
        SubscriptionDescription = N'50 guías a Q33.00 c/u.', 
        SubscriptionCost = 1650.00, 
        SubscriptionFixedValue = 0, 
        SubscriptionMaxServiceFixedValue = 50, 
        SubscriptionValidity = 6, 
        SubscriptionWeight = 10, 
        RowStatus = 1, 
        TokenUpdated = N'SYS-BILKAR', 
        DateUpdated = N'2026-03-25 08:00:00.990' 
    WHERE IdCatSubscription = 6;

    -- 3.2 Actualizar CatSubscriptionAtribute
    UPDATE DeliveryBackOffice.dbo.CatSubscriptionAtribute 
    SET CatSubscriptionId = 6, CatAttributeId = 1, SubscriptionAttributeValue = N'1', 
        SubscriptionAttributeDescription = N'50 guías a Q33.00 c/u.', SubscriptionAttributePosition = 1, 
        RowStatus = 1, TokenUpdated = N'SYS-BILKAR', DateUpdated = N'2026-03-25 08:00:00.993', 
        SubscriptionAttributeDescriptionLong = N'50 guías a Q33.00 c/u.', 
        CatSubscriptionAttributeIcon = N'fa fa-check-circle fa-2x' 
    WHERE IdCatSubscriptionAttribute = 61;

    UPDATE DeliveryBackOffice.dbo.CatSubscriptionAtribute 
    SET CatSubscriptionId = 6, CatAttributeId = 1, SubscriptionAttributeValue = N'1', 
        SubscriptionAttributeDescription = N'Costo único para todos tus clientes.', SubscriptionAttributePosition = 3, 
        RowStatus = 1, TokenUpdated = null, DateUpdated = null, 
        SubscriptionAttributeDescriptionLong = N'Costo único para todos tus clientes.', 
        CatSubscriptionAttributeIcon = N'bi bi-cash fa-2x' 
    WHERE IdCatSubscriptionAttribute = 62;

    UPDATE DeliveryBackOffice.dbo.CatSubscriptionAtribute 
    SET CatSubscriptionId = 6, CatAttributeId = 1, SubscriptionAttributeValue = N'1', 
        SubscriptionAttributeDescription = N'Tarifa única en todo el país.', SubscriptionAttributePosition = 2, 
        RowStatus = 1, TokenUpdated = null, DateUpdated = null, 
        SubscriptionAttributeDescriptionLong = N'Tarifa única en todo el país.', 
        CatSubscriptionAttributeIcon = N'fa fa-map fa-2x' 
    WHERE IdCatSubscriptionAttribute = 63;

    UPDATE DeliveryBackOffice.dbo.CatSubscriptionAtribute 
    SET CatSubscriptionId = 6, CatAttributeId = 1, SubscriptionAttributeValue = N'1', 
        SubscriptionAttributeDescription = N'Hasta 10 Libras.', SubscriptionAttributePosition = 4, 
        RowStatus = 1, TokenUpdated = null, DateUpdated = null, 
        SubscriptionAttributeDescriptionLong = N'La tarifa más barata del mercado.', 
        CatSubscriptionAttributeIcon = N'fa fa-archive fa-2x' 
    WHERE IdCatSubscriptionAttribute = 64;

    UPDATE DeliveryBackOffice.dbo.CatSubscriptionAtribute 
    SET CatSubscriptionId = 6, CatAttributeId = 1, SubscriptionAttributeValue = N'1', 
        SubscriptionAttributeDescription = N'La tarifa más barata del mercado.', SubscriptionAttributePosition = 5, 
        RowStatus = 1, TokenUpdated = null, DateUpdated = null, 
        SubscriptionAttributeDescriptionLong = N'La tarifa más barata del mercado.', 
        CatSubscriptionAttributeIcon = N'bi bi-cash fa-2x' 
    WHERE IdCatSubscriptionAttribute = 65;

    UPDATE DeliveryBackOffice.dbo.CatSubscriptionAtribute 
    SET CatSubscriptionId = 6, CatAttributeId = 1, SubscriptionAttributeValue = N'1', 
        SubscriptionAttributeDescription = N'Vigencia de 6 meses.', SubscriptionAttributePosition = 6, 
        RowStatus = 1, TokenUpdated = null, DateUpdated = null, 
        SubscriptionAttributeDescriptionLong = N'Vigencia de 6 meses.', 
        CatSubscriptionAttributeIcon = N'fa fa-check-circle fa-2x' 
    WHERE IdCatSubscriptionAttribute = 66;

    -- 3.3 Actualizar CatSubscriptionDescription
    UPDATE DeliveryBackOffice.dbo.CatSubscriptionDescription 
    SET Title = N'¿Qué es?', 
        Description = N'Nuestro paquete te ofrece 50 guías de envío prepagadas con Tarifa única a   
todo el país, lo que significa que puedes enviar tus productos a cualquier   
destino sin preocuparte por tarifas variables. Pero eso no es todo, ¡nuestra   
tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías   
prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes   
una gran cantidad de envíos de manera continua? Estas guías son ideales   
para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una  
tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos   
sean más rentables y eficientes hoy mismo!', 
        Position = 1, Type = N'PAQUETE BÁSICO', CatSubscriptionId = 6, 
        RowStatus = 1, DateUpdated = N'2026-03-25 08:00:00.993', TokenUpdated = N'SYS-BILKAR' 
    WHERE IdCatSubscriptionDescription = 24;

    UPDATE DeliveryBackOffice.dbo.CatSubscriptionDescription 
    SET Title = N'¿Cómo Funciona?', 
        Description = N'Compra en la tienda virtual y recibe las guías en tu correo electrónico.   
Prepara tus paquetes, completa la información de envío y entrégalos en las   
+90 agencias express center o puedes solicitar la recolección a tu casa u   
oficina. Rastrea el progreso del envío con el número de guía proporcionado   
para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al   
centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de   
los detalles logísticos. Adquiere tu Paquete Basico y podrás obtener tus   
guías prepagadas de 50 envíos con tarifa única a todo el país a Q33.00   
c/u.', 
        Position = 2, Type = N'PAQUETE BÁSICO', CatSubscriptionId = 6, 
        RowStatus = 1, DateUpdated = N'2026-03-25 08:00:00.993', TokenUpdated = N'SYS-BILKAR' 
    WHERE IdCatSubscriptionDescription = 25;

    UPDATE DeliveryBackOffice.dbo.CatSubscriptionDescription 
    SET Title = N'Aplican restricciones', 
        Description = N'En caso de que tu envío exceda el peso, de 0 a 10 libras, consulta los   
términos y condiciones.', 
        Position = 5, Type = N'PAQUETE BÁSICO', CatSubscriptionId = 6, 
        RowStatus = 1, DateUpdated = N'2026-03-25 08:00:00.993', TokenUpdated = N'SYS-BILKAR' 
    WHERE IdCatSubscriptionDescription = 39;

    PRINT '   [OK] PAQUETE BASICO actualizado correctamente';


    -- ========================================================================
    -- SECCION 4: PAQUETE PLUS (ID: 7)
    -- Precio: Q3,100.00 | Guías: 100 | Precio unitario: Q31.00
    -- ========================================================================
    PRINT '>> Procesando PAQUETE PLUS (ID: 7)...';

    -- 4.1 Actualizar CatSubscription
    UPDATE DeliveryBackOffice.dbo.CatSubscription 
    SET SubscriptionName = N'Paquete Plus', 
        SubscriptionDescription = N'100 guías a Q31.00 c/una', 
        SubscriptionCost = 3100.00, 
        SubscriptionFixedValue = 0, 
        SubscriptionMaxServiceFixedValue = 100, 
        SubscriptionValidity = 6, 
        SubscriptionWeight = 10, 
        RowStatus = 1, 
        TokenUpdated = N'SYS-BILKAR', 
        DateUpdated = N'2026-03-25 08:00:00.993' 
    WHERE IdCatSubscription = 7;

    -- 4.2 Actualizar CatSubscriptionAtribute
    UPDATE DeliveryBackOffice.dbo.CatSubscriptionAtribute 
    SET CatSubscriptionId = 7, CatAttributeId = 1, SubscriptionAttributeValue = N'1', 
        SubscriptionAttributeDescription = N'100 guías a Q31.00 c/u.', SubscriptionAttributePosition = 1, 
        RowStatus = 1, TokenUpdated = N'SYS-BILKAR', DateUpdated = N'2025-12-08 08:42:06.993', 
        SubscriptionAttributeDescriptionLong = N'100 guías a Q31 c/u.', 
        CatSubscriptionAttributeIcon = N'fa fa-check-circle fa-2x' 
    WHERE IdCatSubscriptionAttribute = 68;

    UPDATE DeliveryBackOffice.dbo.CatSubscriptionAtribute 
    SET CatSubscriptionId = 7, CatAttributeId = 1, SubscriptionAttributeValue = N'1', 
        SubscriptionAttributeDescription = N'Costo único para todos tus clientes.', SubscriptionAttributePosition = 2, 
        RowStatus = 1, TokenUpdated = N'SYS-BILKAR', DateUpdated = N'2024-05-15 23:24:55.623', 
        SubscriptionAttributeDescriptionLong = N'Costo único para todos tus clientes.', 
        CatSubscriptionAttributeIcon = N'bi bi-cash fa-2x' 
    WHERE IdCatSubscriptionAttribute = 69;

    UPDATE DeliveryBackOffice.dbo.CatSubscriptionAtribute 
    SET CatSubscriptionId = 7, CatAttributeId = 1, SubscriptionAttributeValue = N'1', 
        SubscriptionAttributeDescription = N'Tarifa única en todo el país.', SubscriptionAttributePosition = 3, 
        RowStatus = 1, TokenUpdated = N'SYS-BILKAR', DateUpdated = N'2024-05-15 23:25:00.857', 
        SubscriptionAttributeDescriptionLong = N'Tarifa única en todo el país.', 
        CatSubscriptionAttributeIcon = N'fa fa-map fa-2x' 
    WHERE IdCatSubscriptionAttribute = 70;

    UPDATE DeliveryBackOffice.dbo.CatSubscriptionAtribute 
    SET CatSubscriptionId = 7, CatAttributeId = 1, SubscriptionAttributeValue = N'1', 
        SubscriptionAttributeDescription = N'La tarifa más barata del mercado.', SubscriptionAttributePosition = 5, 
        RowStatus = 1, TokenUpdated = N'SYS-BILKAR', DateUpdated = N'2024-05-15 23:25:06.957', 
        SubscriptionAttributeDescriptionLong = N'La tarifa más barata del mercado.', 
        CatSubscriptionAttributeIcon = N'bi bi-cash fa-2x' 
    WHERE IdCatSubscriptionAttribute = 71;

    UPDATE DeliveryBackOffice.dbo.CatSubscriptionAtribute 
    SET CatSubscriptionId = 7, CatAttributeId = 1, SubscriptionAttributeValue = N'1', 
        SubscriptionAttributeDescription = N'Hasta 10 Libras.', SubscriptionAttributePosition = 4, 
        RowStatus = 1, TokenUpdated = N'SYS-BILKAR', DateUpdated = N'2024-05-15 23:25:12.580', 
        SubscriptionAttributeDescriptionLong = N'Hasta 10 Libras.', 
        CatSubscriptionAttributeIcon = N'fa fa-archive fa-2x' 
    WHERE IdCatSubscriptionAttribute = 72;

    UPDATE DeliveryBackOffice.dbo.CatSubscriptionAtribute 
    SET CatSubscriptionId = 7, CatAttributeId = 1, SubscriptionAttributeValue = N'1', 
        SubscriptionAttributeDescription = N'Vigencia de 6 meses.', SubscriptionAttributePosition = 6, 
        RowStatus = 1, TokenUpdated = N'SYS-BILKAR', DateUpdated = N'2024-05-15 23:25:27.283', 
        SubscriptionAttributeDescriptionLong = N'Vigencia de 6 meses.', 
        CatSubscriptionAttributeIcon = N'fa fa-check-circle fa-2x' 
    WHERE IdCatSubscriptionAttribute = 73;

    -- 4.3 Actualizar CatSubscriptionDescription
    UPDATE DeliveryBackOffice.dbo.CatSubscriptionDescription 
    SET Title = N'¿Qué es?', 
        Description = N'Nuestro paquete te ofrece 100 guías de envío prepagadas con Tarifa única   
a todo el país, lo que significa que puedes enviar tus productos a cualquier   
destino sin preocuparte por tarifas variables. Pero eso no es todo, ¡nuestra   
tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías   
prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes   
una gran cantidad de envíos de manera continua? Estas guías son ideales   
para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una   
tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos   
sean más rentables y eficientes hoy mismo!', 
        Position = 1, Type = N'PAQUETE PLUS', CatSubscriptionId = 7, 
        RowStatus = 1, DateUpdated = N'2026-03-25 08:00:00.993', TokenUpdated = N'SYS-BILKAR' 
    WHERE IdCatSubscriptionDescription = 27;

    UPDATE DeliveryBackOffice.dbo.CatSubscriptionDescription 
    SET Title = N'¿Cómo Funciona?', 
        Description = N'Compra en la tienda virtual y recibe las guías en tu correo electrónico.   
Prepara tus paquetes, completa la información de envío y entrégalos en las   
+90 agencias express center o puedes solicitar la recolección a tu casa u   
oficina. Rastrea el progreso del envío con el número de guía proporcionado   
para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al   
centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de   
los detalles logísticos. Adquiere tu Paquete Plus y podrás obtener tus guías   
prepagadas de 100 envíos con tarifa única a todo el país a Q31.00 c/u.', 
        Position = 2, Type = N'PAQUETE PLUS', CatSubscriptionId = 7, 
        RowStatus = 1, DateUpdated = N'2026-03-25 08:00:00.993', TokenUpdated = N'SYS-BILKAR' 
    WHERE IdCatSubscriptionDescription = 28;

    UPDATE DeliveryBackOffice.dbo.CatSubscriptionDescription 
    SET Title = N'Aplican restricciones', 
        Description = N'En caso de que tu envío exceda el peso, de 0 a 10 libras, consulta los   
términos y condiciones.', 
        Position = 5, Type = N'PAQUETE PLUS', CatSubscriptionId = 7, 
        RowStatus = 1, DateUpdated = N'2026-03-25 08:00:00.993', TokenUpdated = N'SYS-BILKAR' 
    WHERE IdCatSubscriptionDescription = 40;

    PRINT '   [OK] PAQUETE PLUS actualizado correctamente';


    -- ========================================================================
    -- SECCION 5: PAQUETE GOLD (ID: 8)
    -- Precio: Q5,800.00 | Guías: 200 | Precio unitario: Q29.00
    -- ========================================================================
    PRINT '>> Procesando PAQUETE GOLD (ID: 8)...';

    -- 5.1 Actualizar CatSubscription
    UPDATE DeliveryBackOffice.dbo.CatSubscription 
    SET SubscriptionName = N'Paquete Gold', 
        SubscriptionDescription = N'200 guías a Q29.00 c/u.', 
        SubscriptionCost = 5800.00, 
        SubscriptionFixedValue = 0, 
        SubscriptionMaxServiceFixedValue = 200, 
        SubscriptionValidity = 6, 
        SubscriptionWeight = 10, 
        RowStatus = 1, 
        TokenUpdated = N'SYS-BILKAR', 
        DateUpdated = N'2026-03-25 08:00:00.993' 
    WHERE IdCatSubscription = 8;

    -- 5.2 Actualizar CatSubscriptionAtribute
    UPDATE DeliveryBackOffice.dbo.CatSubscriptionAtribute 
    SET CatSubscriptionId = 8, CatAttributeId = 1, SubscriptionAttributeValue = N'1', 
        SubscriptionAttributeDescription = N'200 guías a Q29.00 c/u.', SubscriptionAttributePosition = 1, 
        RowStatus = 1, TokenUpdated = N'SYS-BILKAR', DateUpdated = N'2026-03-25 08:00:00.993', 
        SubscriptionAttributeDescriptionLong = N'200 guías a Q29 c/u.', 
        CatSubscriptionAttributeIcon = N'fa fa-check-circle fa-2x' 
    WHERE IdCatSubscriptionAttribute = 75;

    UPDATE DeliveryBackOffice.dbo.CatSubscriptionAtribute 
    SET CatSubscriptionId = 8, CatAttributeId = 1, SubscriptionAttributeValue = N'1', 
        SubscriptionAttributeDescription = N'Costo único para todos tus clientes.', SubscriptionAttributePosition = 2, 
        RowStatus = 1, TokenUpdated = N'SYS-BILKAR', DateUpdated = N'2026-03-25 08:00:00.993', 
        SubscriptionAttributeDescriptionLong = N'Costo único para todos tus clientes.', 
        CatSubscriptionAttributeIcon = N'bi bi-cash fa-2x' 
    WHERE IdCatSubscriptionAttribute = 76;

    UPDATE DeliveryBackOffice.dbo.CatSubscriptionAtribute 
    SET CatSubscriptionId = 8, CatAttributeId = 1, SubscriptionAttributeValue = N'1', 
        SubscriptionAttributeDescription = N'Tarifa única en todo el país.', SubscriptionAttributePosition = 3, 
        RowStatus = 1, TokenUpdated = N'SYS-BILKAR', DateUpdated = N'2026-03-25 08:00:00.993', 
        SubscriptionAttributeDescriptionLong = N'Tarifa única en todo el país.', 
        CatSubscriptionAttributeIcon = N'fa fa-map fa-2x' 
    WHERE IdCatSubscriptionAttribute = 77;

    UPDATE DeliveryBackOffice.dbo.CatSubscriptionAtribute 
    SET CatSubscriptionId = 8, CatAttributeId = 1, SubscriptionAttributeValue = N'1', 
        SubscriptionAttributeDescription = N'La tarifa más barata del mercado.', SubscriptionAttributePosition = 5, 
        RowStatus = 1, TokenUpdated = N'SYS-BILKAR', DateUpdated = N'2026-03-25 08:00:00.993', 
        SubscriptionAttributeDescriptionLong = N'La tarifa más barata del mercado.', 
        CatSubscriptionAttributeIcon = N'bi bi-cash fa-2x' 
    WHERE IdCatSubscriptionAttribute = 78;

    UPDATE DeliveryBackOffice.dbo.CatSubscriptionAtribute 
    SET CatSubscriptionId = 8, CatAttributeId = 1, SubscriptionAttributeValue = N'1', 
        SubscriptionAttributeDescription = N'Hasta 10 Libras.', SubscriptionAttributePosition = 4, 
        RowStatus = 1, TokenUpdated = N'SYS-BILKAR', DateUpdated = N'2026-03-25 08:00:00.993', 
        SubscriptionAttributeDescriptionLong = N'Hasta 10 Libras.', 
        CatSubscriptionAttributeIcon = N'fa fa-archive fa-2x' 
    WHERE IdCatSubscriptionAttribute = 79;

    UPDATE DeliveryBackOffice.dbo.CatSubscriptionAtribute 
    SET CatSubscriptionId = 8, CatAttributeId = 1, SubscriptionAttributeValue = N'1', 
        SubscriptionAttributeDescription = N'Vigencia de 6 meses.', SubscriptionAttributePosition = 6, 
        RowStatus = 1, TokenUpdated = N'SYS-BILKAR', DateUpdated = N'2026-03-25 08:00:00.993', 
        SubscriptionAttributeDescriptionLong = N'Vigencia de 6 meses.', 
        CatSubscriptionAttributeIcon = N'fa fa-check-circle fa-2x' 
    WHERE IdCatSubscriptionAttribute = 80;

    -- 5.3 Actualizar CatSubscriptionDescription
    UPDATE DeliveryBackOffice.dbo.CatSubscriptionDescription 
    SET Title = N'¿Qué es?', 
        Description = N'Nuestro paquete te ofrece 200 guías de envío prepagadas con Tarifa única   
a todo el país, lo que significa que puedes enviar tus productos a cualquier   
destino sin preocuparte por tarifas variables. Pero eso no es todo, ¡nuestra   
tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías   
prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes   
una gran cantidad de envíos de manera continua? Estas guías son ideales   
para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una   
tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos   
sean más rentables y eficientes hoy mismo!', 
        Position = 1, Type = N'PAQUETE GOLD', CatSubscriptionId = 8, 
        RowStatus = 1, DateUpdated = N'2026-03-25 08:00:00.993', TokenUpdated = N'SYS-BILKAR' 
    WHERE IdCatSubscriptionDescription = 30;

    UPDATE DeliveryBackOffice.dbo.CatSubscriptionDescription 
    SET Title = N'¿Cómo Funciona?', 
        Description = N'Compra en la tienda virtual y recibe las guías en tu correo electrónico.   
Prepara tus paquetes, completa la información de envío y entrégalos en las   
+90 agencias express center o puedes solicitar la recolección a tu casa u   
oficina. Rastrea el progreso del envío con el número de guía proporcionado   
para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al   
centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de   
los detalles logísticos. Adquiere tu Paquete Gold y podrás obtener tus guías prepagadas de 200 envíos con tarifa única a todo el país a Q29.00   
c/u.', 
        Position = 2, Type = N'PAQUETE GOLD', CatSubscriptionId = 8, 
        RowStatus = 1, DateUpdated = N'2026-03-25 08:00:00.993', TokenUpdated = N'SYS-BILKAR' 
    WHERE IdCatSubscriptionDescription = 31;

    UPDATE DeliveryBackOffice.dbo.CatSubscriptionDescription 
    SET Title = N'Aplican restricciones', 
        Description = N'En caso de que tu envío exceda el peso, de 0 a 10 libras, consulta los   
términos y condiciones.', 
        Position = 5, Type = N'PAQUETE GOLD', CatSubscriptionId = 8, 
        RowStatus = 1, DateUpdated = N'2026-03-25 08:00:00.993', TokenUpdated = N'SYS-BILKAR' 
    WHERE IdCatSubscriptionDescription = 42;

    PRINT '   [OK] PAQUETE GOLD actualizado correctamente';


    -- ========================================================================
    -- SECCION 6: PAQUETE PLATINO (ID: 11)
    -- Precio: Q10,000.00 | Guías: 400 | Precio unitario: Q25.00
    -- ========================================================================
    PRINT '>> Procesando PAQUETE PLATINO (ID: 11)...';

    -- 6.1 Actualizar CatSubscription
    UPDATE DeliveryBackOffice.dbo.CatSubscription 
    SET SubscriptionName = N'Paquete Platino', 
        SubscriptionDescription = N'400 guías a Q25.00 c/u.', 
        SubscriptionCost = 10000.00, 
        SubscriptionFixedValue = 0, 
        SubscriptionMaxServiceFixedValue = 400, 
        SubscriptionValidity = 6, 
        SubscriptionWeight = 10, 
        RowStatus = 1, 
        TokenUpdated = N'SYS-BILKAR', 
        DateUpdated = N'2026-03-25 08:00:00.993' 
    WHERE IdCatSubscription = 11;

    -- 6.2 Actualizar CatSubscriptionAtribute
    UPDATE DeliveryBackOffice.dbo.CatSubscriptionAtribute 
    SET CatSubscriptionId = 11, CatAttributeId = 1, SubscriptionAttributeValue = N'1', 
        SubscriptionAttributeDescription = N'Tarifa única en todo el país.', SubscriptionAttributePosition = 2, 
        RowStatus = 1, TokenUpdated = N'SYS-BILKAR', DateUpdated = N'2024-05-15 23:52:26.557', 
        SubscriptionAttributeDescriptionLong = N'Tarifa única en todo el país.', 
        CatSubscriptionAttributeIcon = N'fa fa-map fa-2x' 
    WHERE IdCatSubscriptionAttribute = 89;

    UPDATE DeliveryBackOffice.dbo.CatSubscriptionAtribute 
    SET CatSubscriptionId = 11, CatAttributeId = 1, SubscriptionAttributeValue = N'1', 
        SubscriptionAttributeDescription = N'Costo único para todos tus clientes.', SubscriptionAttributePosition = 3, 
        RowStatus = 1, TokenUpdated = N'SYS-BILKAR', DateUpdated = N'2024-05-15 23:52:30.863', 
        SubscriptionAttributeDescriptionLong = N'Costo único para todos tus clientes.', 
        CatSubscriptionAttributeIcon = N'bi bi-cash fa-2x' 
    WHERE IdCatSubscriptionAttribute = 90;

    UPDATE DeliveryBackOffice.dbo.CatSubscriptionAtribute 
    SET CatSubscriptionId = 11, CatAttributeId = 1, SubscriptionAttributeValue = N'1', 
        SubscriptionAttributeDescription = N'La tarifa más barata del mercado.', SubscriptionAttributePosition = 5, 
        RowStatus = 1, TokenUpdated = N'SYS-BILKAR', DateUpdated = N'2024-05-15 23:52:35.667', 
        SubscriptionAttributeDescriptionLong = N'La tarifa más barata del mercado.', 
        CatSubscriptionAttributeIcon = N'fa fa-archive fa-2x' 
    WHERE IdCatSubscriptionAttribute = 91;

    UPDATE DeliveryBackOffice.dbo.CatSubscriptionAtribute 
    SET CatSubscriptionId = 11, CatAttributeId = 1, SubscriptionAttributeValue = N'1', 
        SubscriptionAttributeDescription = N'Hasta 10 Libras.', SubscriptionAttributePosition = 4, 
        RowStatus = 1, TokenUpdated = N'SYS-BILKAR', DateUpdated = N'2024-05-15 23:52:40.137', 
        SubscriptionAttributeDescriptionLong = N'Hasta 10 Libras.', 
        CatSubscriptionAttributeIcon = N'fa fa-archive fa-2x' 
    WHERE IdCatSubscriptionAttribute = 92;

    UPDATE DeliveryBackOffice.dbo.CatSubscriptionAtribute 
    SET CatSubscriptionId = 11, CatAttributeId = 1, SubscriptionAttributeValue = N'1', 
        SubscriptionAttributeDescription = N'Vigencia de 6 meses.', SubscriptionAttributePosition = 6, 
        RowStatus = 1, TokenUpdated = N'SYS-BILKAR', DateUpdated = N'2024-05-15 23:52:44.763', 
        SubscriptionAttributeDescriptionLong = N'Vigencia de 6 meses.', 
        CatSubscriptionAttributeIcon = N'fa fa-check-circle fa-2x' 
    WHERE IdCatSubscriptionAttribute = 93;

    UPDATE DeliveryBackOffice.dbo.CatSubscriptionAtribute 
    SET CatSubscriptionId = 11, CatAttributeId = 1, SubscriptionAttributeValue = N'1', 
        SubscriptionAttributeDescription = N'400 guías a Q25.00 c/u.', SubscriptionAttributePosition = 1, 
        RowStatus = 1, TokenUpdated = N'SYS-BILKAR', DateUpdated = N'2025-12-08 08:42:06.993', 
        SubscriptionAttributeDescriptionLong = N'400 guías a Q25 c/u.', 
        CatSubscriptionAttributeIcon = N'fa fa-check-circle fa-2x' 
    WHERE IdCatSubscriptionAttribute = 96;

    -- 6.3 Actualizar CatSubscriptionDescription
    UPDATE DeliveryBackOffice.dbo.CatSubscriptionDescription 
    SET Title = N'¿Qué es?', 
        Description = N'Nuestro paquete te ofrece 400 guías de envío prepagadas con Tarifa única   
a todo el país, lo que significa que puedes enviar tus productos a cualquier   
destino sin preocuparte por tarifas variables. Pero eso no es todo, ¡nuestra   
tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías   
prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes   
una gran cantidad de envíos de manera continua? Estas guías son ideales   
para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una   
tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos   
sean más rentables y eficientes hoy mismo!', 
        Position = 1, Type = N'PAQUETE PLATINO', CatSubscriptionId = 11, 
        RowStatus = 1, DateUpdated = N'2026-03-25 08:00:00.993', TokenUpdated = N'SYS-BILKAR' 
    WHERE IdCatSubscriptionDescription = 36;

    UPDATE DeliveryBackOffice.dbo.CatSubscriptionDescription 
    SET Title = N'¿Cómo Funciona?', 
        Description = N'Compra en la tienda virtual y recibe las guías en tu correo electrónico.   
Prepara tus paquetes, completa la información de envío y entrégalos en las   
+90 agencias express center o puedes solicitar la recolección a tu casa u   
oficina. Rastrea el progreso del envío con el número de guía proporcionado   
para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al   
centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de   
los detalles logísticos. Adquiere tu Paquete Platino y podrás obtener tus  
guías prepagadas de 400 envíos con tarifa única a todo el país a Q25.00   
c/u.', 
        Position = 2, Type = N'PAQUETE PLATINO', CatSubscriptionId = 11, 
        RowStatus = 1, DateUpdated = N'2026-03-25 08:00:00.993', TokenUpdated = N'SYS-BILKAR' 
    WHERE IdCatSubscriptionDescription = 37;

    UPDATE DeliveryBackOffice.dbo.CatSubscriptionDescription 
    SET Title = N'Aplican restricciones', 
        Description = N'En caso de que tu envío exceda el peso, de 0 a 10 libras, consulta los   
términos y condiciones.', 
        Position = 5, Type = N'PAQUETE PLATINO', CatSubscriptionId = 11, 
        RowStatus = 1, DateUpdated = N'2026-03-25 08:00:00.993', TokenUpdated = N'SYS-BILKAR' 
    WHERE IdCatSubscriptionDescription = 44;

    PRINT '   [OK] PAQUETE PLATINO actualizado correctamente';


    -- ========================================================================
    -- SECCION FINAL: COMMIT O ROLLBACK
    -- ========================================================================
    PRINT '';
    PRINT '====================================================================';

    IF @MODE = 'TEST'
    BEGIN
        ROLLBACK TRANSACTION;
        PRINT 'MODO TEST: Se ejecutó ROLLBACK - No se aplicaron cambios permanentes';
        PRINT 'Para aplicar cambios, cambiar @MODE a ''EXEC''';
    END
    ELSE
    BEGIN
        COMMIT TRANSACTION;
        PRINT 'MODO EXEC: Se ejecutó COMMIT - Cambios aplicados permanentemente';
    END

    PRINT '====================================================================';
    PRINT 'FDAPI-5983 - Ejecución completada exitosamente';
    PRINT '====================================================================';

END TRY
BEGIN CATCH
    -- ========================================================================
    -- MANEJO DE ERRORES: ROLLBACK AUTOMATICO
    -- ========================================================================
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT '';
    PRINT '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!';
    PRINT 'ERROR - Se ejecutó ROLLBACK automático';
    PRINT '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!';
    PRINT 'Número de Error: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    PRINT 'Mensaje: ' + ERROR_MESSAGE();
    PRINT 'Severidad: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
    PRINT 'Estado: ' + CAST(ERROR_STATE() AS VARCHAR);
    PRINT 'Línea: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Procedimiento: ' + ISNULL(ERROR_PROCEDURE(), 'Script Ad-Hoc');
    PRINT '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!';
END CATCH;

GO


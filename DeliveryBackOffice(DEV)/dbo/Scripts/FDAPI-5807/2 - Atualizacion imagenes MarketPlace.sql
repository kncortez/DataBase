-- ===============================================================
-- Actualización de imágenes de productos
-- Aplica para El Salvador (SV), Guatemala (GT) y Honduras (HN)
-- IDs resueltos dinámicamente desde CatSubscription
-- ===============================================================

-- ---------------------------------------------------------------
-- [0/6] INSERT banner carousel SV
-- ---------------------------------------------------------------
PRINT '>>> [0/6] Iniciando INSERT en MarketplaceCarouselImage...'

BEGIN TRANSACTION
BEGIN TRY

    INSERT INTO [DeliveryBackOffice].[dbo].[MarketplaceCarouselImage]
    (
        XXXLImageURL,
        XXLImageURL,
        XLImageURL,
        MDImageURL,
        XSImageURL,
        ImageOrder,
        RowStatus,
        TokenCreated,
        DateCreated,
        HyperlinkURL,
        IdCountry
    )
    VALUES
    (
        'https://www.forzadelivery.com/images/Tienda/SV/BANNER/slider01SV-2500-350.jpg',
        'https://www.forzadelivery.com/images/Tienda/SV/BANNER/slider01SV-1950-300.jpg',
        'https://www.forzadelivery.com/images/Tienda/SV/BANNER/slider01SV-1200-250.jpg',
        'https://www.forzadelivery.com/images/Tienda/SV/BANNER/slider01SV-992-200.jpg',
        'https://www.forzadelivery.com/images/Tienda/SV/BANNER/slider01SV-575-200.jpg',
        2,              -- ImageOrder
        1,              -- RowStatus
        'SYS-PMACAJOL', -- TokenCreated
        GETDATE(),      -- DateCreated
        NULL,           -- HyperlinkURL
        'SV'            -- IdCountry
    );

    COMMIT TRANSACTION
    PRINT '    [OK] MarketplaceCarouselImage insertado correctamente. Filas: ' + CAST(@@ROWCOUNT AS VARCHAR)

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION
    PRINT '    [ERROR] Falló INSERT en MarketplaceCarouselImage.'
    PRINT '    Mensaje : ' + ERROR_MESSAGE()
    PRINT '    Línea   : ' + CAST(ERROR_LINE() AS VARCHAR)
    PRINT '    Número  : ' + CAST(ERROR_NUMBER() AS VARCHAR)
END CATCH

-- Verificación
SELECT
    IdCarouselImage,
    ImageOrder,
    IdCountry,
    XXXLImageURL,
    RowStatus,
    DateCreated
FROM DeliveryBackOffice.dbo.MarketplaceCarouselImage
WHERE IdCountry = 'SV'
ORDER BY ImageOrder;
GO


-- ---------------------------------------------------------------
-- [1/6] MICRO
-- ---------------------------------------------------------------
PRINT '>>> [1/6] Actualizando imágenes: MICRO...'

DECLARE @SV_MICRO INT, @GT_MICRO INT, @HN_MICRO INT;

BEGIN TRANSACTION
BEGIN TRY

    SELECT @SV_MICRO = IdCatSubscription FROM DeliveryBackOffice.dbo.CatSubscription WHERE IdCountry = 'SV' AND SubscriptionName = 'Paquete MICRO';
    SELECT @GT_MICRO = IdCatSubscription FROM DeliveryBackOffice.dbo.CatSubscription WHERE IdCountry = 'GT' AND SubscriptionName = 'Paquete MICRO';
    SELECT @HN_MICRO = IdCatSubscription FROM DeliveryBackOffice.dbo.CatSubscription WHERE IdCountry = 'HN' AND SubscriptionName = 'Paquete MICRO';

    IF @SV_MICRO IS NULL OR @GT_MICRO IS NULL OR @HN_MICRO IS NULL
        THROW 50010, 'No se encontró Paquete MICRO para uno o más países (SV, GT, HN).', 1;

    PRINT '    IDs resueltos → SV: ' + CAST(@SV_MICRO AS VARCHAR) + ' | GT: ' + CAST(@GT_MICRO AS VARCHAR) + ' | HN: ' + CAST(@HN_MICRO AS VARCHAR);

    UPDATE [DeliveryBackOffice].[dbo].[CatProductImage]
    SET
        CatProductImageSmallImageURL = 'https://www.forzadelivery.com/images/Tienda/micro_v2-500-347.jpg',
        CatProductImageLargeImageURL = 'https://www.forzadelivery.com/images/Tienda/micro_v2-1200-722.jpg',
        CatProductImageBigImageURL   = 'https://www.forzadelivery.com/images/Tienda/micro_v2-2103-521.jpg'
    WHERE CatSubscriptionId IN (@SV_MICRO, @GT_MICRO, @HN_MICRO);

    IF @@ROWCOUNT = 0
        THROW 50011, 'UPDATE MICRO no afectó ninguna fila. Verificar registros en CatProductImage.', 1;

    COMMIT TRANSACTION
    PRINT '    [OK] MICRO actualizado. Filas afectadas: ' + CAST(@@ROWCOUNT AS VARCHAR)

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION
    PRINT '    [ERROR] Falló UPDATE de MICRO.'
    PRINT '    Mensaje : ' + ERROR_MESSAGE()
    PRINT '    Línea   : ' + CAST(ERROR_LINE() AS VARCHAR)
    PRINT '    Número  : ' + CAST(ERROR_NUMBER() AS VARCHAR)
END CATCH
GO


-- ---------------------------------------------------------------
-- [2/6] PETIT
-- ---------------------------------------------------------------
PRINT '>>> [2/6] Actualizando imágenes: PETIT...'

DECLARE @SV_PETIT INT, @GT_PETIT INT, @HN_PETIT INT;

BEGIN TRANSACTION
BEGIN TRY

    SELECT @SV_PETIT = IdCatSubscription FROM DeliveryBackOffice.dbo.CatSubscription WHERE IdCountry = 'SV' AND SubscriptionName = 'Paquete Petit';
    SELECT @GT_PETIT = IdCatSubscription FROM DeliveryBackOffice.dbo.CatSubscription WHERE IdCountry = 'GT' AND SubscriptionName = 'Paquete Petit';
    SELECT @HN_PETIT = IdCatSubscription FROM DeliveryBackOffice.dbo.CatSubscription WHERE IdCountry = 'HN' AND SubscriptionName = 'Paquete Petit';

    IF @SV_PETIT IS NULL OR @GT_PETIT IS NULL OR @HN_PETIT IS NULL
        THROW 50020, 'No se encontró Paquete Petit para uno o más países (SV, GT, HN).', 1;

    PRINT '    IDs resueltos → SV: ' + CAST(@SV_PETIT AS VARCHAR) + ' | GT: ' + CAST(@GT_PETIT AS VARCHAR) + ' | HN: ' + CAST(@HN_PETIT AS VARCHAR);

    UPDATE [DeliveryBackOffice].[dbo].[CatProductImage]
    SET
        CatProductImageSmallImageURL = 'https://www.forzadelivery.com/images/Tienda/petit_v2-500-347.jpg',
        CatProductImageLargeImageURL = 'https://www.forzadelivery.com/images/Tienda/petit_v2-1200-722.jpg',
        CatProductImageBigImageURL   = 'https://www.forzadelivery.com/images/Tienda/petit_v2-2103-521.jpg'
    WHERE CatSubscriptionId IN (@SV_PETIT, @GT_PETIT, @HN_PETIT);

    IF @@ROWCOUNT = 0
        THROW 50021, 'UPDATE PETIT no afectó ninguna fila. Verificar registros en CatProductImage.', 1;

    COMMIT TRANSACTION
    PRINT '    [OK] PETIT actualizado. Filas afectadas: ' + CAST(@@ROWCOUNT AS VARCHAR)

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION
    PRINT '    [ERROR] Falló UPDATE de PETIT.'
    PRINT '    Mensaje : ' + ERROR_MESSAGE()
    PRINT '    Línea   : ' + CAST(ERROR_LINE() AS VARCHAR)
    PRINT '    Número  : ' + CAST(ERROR_NUMBER() AS VARCHAR)
END CATCH
GO


-- ---------------------------------------------------------------
-- [3/6] BASICO
-- ---------------------------------------------------------------
PRINT '>>> [3/6] Actualizando imágenes: BASICO...'

DECLARE @SV_BASICO INT, @GT_BASICO INT, @HN_BASICO INT;

BEGIN TRANSACTION
BEGIN TRY

    SELECT @SV_BASICO = IdCatSubscription FROM DeliveryBackOffice.dbo.CatSubscription WHERE IdCountry = 'SV' AND SubscriptionName = 'Paquete Básico';
    SELECT @GT_BASICO = IdCatSubscription FROM DeliveryBackOffice.dbo.CatSubscription WHERE IdCountry = 'GT' AND SubscriptionName = 'Paquete Básico';
    SELECT @HN_BASICO = IdCatSubscription FROM DeliveryBackOffice.dbo.CatSubscription WHERE IdCountry = 'HN' AND SubscriptionName = 'Paquete Básico';

    IF @SV_BASICO IS NULL OR @GT_BASICO IS NULL OR @HN_BASICO IS NULL
        THROW 50030, 'No se encontró Paquete Básico para uno o más países (SV, GT, HN).', 1;

    PRINT '    IDs resueltos → SV: ' + CAST(@SV_BASICO AS VARCHAR) + ' | GT: ' + CAST(@GT_BASICO AS VARCHAR) + ' | HN: ' + CAST(@HN_BASICO AS VARCHAR);

    UPDATE [DeliveryBackOffice].[dbo].[CatProductImage]
    SET
        CatProductImageSmallImageURL = 'https://www.forzadelivery.com/images/Tienda/basico_v2-500-347.jpg',
        CatProductImageLargeImageURL = 'https://www.forzadelivery.com/images/Tienda/basico_v2-1200-722.jpg',
        CatProductImageBigImageURL   = 'https://www.forzadelivery.com/images/Tienda/basico_v2-2103-521.jpg'
    WHERE CatSubscriptionId IN (@SV_BASICO, @GT_BASICO, @HN_BASICO);

    IF @@ROWCOUNT = 0
        THROW 50031, 'UPDATE BASICO no afectó ninguna fila. Verificar registros en CatProductImage.', 1;

    COMMIT TRANSACTION
    PRINT '    [OK] BASICO actualizado. Filas afectadas: ' + CAST(@@ROWCOUNT AS VARCHAR)

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION
    PRINT '    [ERROR] Falló UPDATE de BASICO.'
    PRINT '    Mensaje : ' + ERROR_MESSAGE()
    PRINT '    Línea   : ' + CAST(ERROR_LINE() AS VARCHAR)
    PRINT '    Número  : ' + CAST(ERROR_NUMBER() AS VARCHAR)
END CATCH
GO


-- ---------------------------------------------------------------
-- [4/6] PLUS
-- ---------------------------------------------------------------
PRINT '>>> [4/6] Actualizando imágenes: PLUS...'

DECLARE @SV_PLUS INT, @GT_PLUS INT, @HN_PLUS INT;

BEGIN TRANSACTION
BEGIN TRY

    SELECT @SV_PLUS = IdCatSubscription FROM DeliveryBackOffice.dbo.CatSubscription WHERE IdCountry = 'SV' AND SubscriptionName = 'Paquete Plus';
    SELECT @GT_PLUS = IdCatSubscription FROM DeliveryBackOffice.dbo.CatSubscription WHERE IdCountry = 'GT' AND SubscriptionName = 'Paquete Plus';
    SELECT @HN_PLUS = IdCatSubscription FROM DeliveryBackOffice.dbo.CatSubscription WHERE IdCountry = 'HN' AND SubscriptionName = 'Paquete Plus';

    IF @SV_PLUS IS NULL OR @GT_PLUS IS NULL OR @HN_PLUS IS NULL
        THROW 50040, 'No se encontró Paquete Plus para uno o más países (SV, GT, HN).', 1;

    PRINT '    IDs resueltos → SV: ' + CAST(@SV_PLUS AS VARCHAR) + ' | GT: ' + CAST(@GT_PLUS AS VARCHAR) + ' | HN: ' + CAST(@HN_PLUS AS VARCHAR);

    UPDATE [DeliveryBackOffice].[dbo].[CatProductImage]
    SET
        CatProductImageSmallImageURL = 'https://www.forzadelivery.com/images/Tienda/plus_v2-500-347.jpg',
        CatProductImageLargeImageURL = 'https://www.forzadelivery.com/images/Tienda/plus_v2-1200-722.jpg',
        CatProductImageBigImageURL   = 'https://www.forzadelivery.com/images/Tienda/plus_v2-2103-521.jpg'
    WHERE CatSubscriptionId IN (@SV_PLUS, @GT_PLUS, @HN_PLUS);

    IF @@ROWCOUNT = 0
        THROW 50041, 'UPDATE PLUS no afectó ninguna fila. Verificar registros en CatProductImage.', 1;

    COMMIT TRANSACTION
    PRINT '    [OK] PLUS actualizado. Filas afectadas: ' + CAST(@@ROWCOUNT AS VARCHAR)

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION
    PRINT '    [ERROR] Falló UPDATE de PLUS.'
    PRINT '    Mensaje : ' + ERROR_MESSAGE()
    PRINT '    Línea   : ' + CAST(ERROR_LINE() AS VARCHAR)
    PRINT '    Número  : ' + CAST(ERROR_NUMBER() AS VARCHAR)
END CATCH
GO


-- ---------------------------------------------------------------
-- [5/6] GOLD
-- ---------------------------------------------------------------
PRINT '>>> [5/6] Actualizando imágenes: GOLD...'

DECLARE @SV_GOLD INT, @GT_GOLD INT, @HN_GOLD INT;

BEGIN TRANSACTION
BEGIN TRY

    SELECT @SV_GOLD = IdCatSubscription FROM DeliveryBackOffice.dbo.CatSubscription WHERE IdCountry = 'SV' AND SubscriptionName = 'Paquete Gold';
    SELECT @GT_GOLD = IdCatSubscription FROM DeliveryBackOffice.dbo.CatSubscription WHERE IdCountry = 'GT' AND SubscriptionName = 'Paquete Gold';
    SELECT @HN_GOLD = IdCatSubscription FROM DeliveryBackOffice.dbo.CatSubscription WHERE IdCountry = 'HN' AND SubscriptionName = 'Paquete Gold';

    IF @SV_GOLD IS NULL OR @GT_GOLD IS NULL OR @HN_GOLD IS NULL
        THROW 50050, 'No se encontró Paquete Gold para uno o más países (SV, GT, HN).', 1;

    PRINT '    IDs resueltos → SV: ' + CAST(@SV_GOLD AS VARCHAR) + ' | GT: ' + CAST(@GT_GOLD AS VARCHAR) + ' | HN: ' + CAST(@HN_GOLD AS VARCHAR);

    UPDATE [DeliveryBackOffice].[dbo].[CatProductImage]
    SET
        CatProductImageSmallImageURL = 'https://www.forzadelivery.com/images/Tienda/gold_v2-500-347.jpg',
        CatProductImageLargeImageURL = 'https://www.forzadelivery.com/images/Tienda/gold_v2-1200-722.jpg',
        CatProductImageBigImageURL   = 'https://www.forzadelivery.com/images/Tienda/gold_v2-2103-521.jpg'
    WHERE CatSubscriptionId IN (@SV_GOLD, @GT_GOLD, @HN_GOLD);

    IF @@ROWCOUNT = 0
        THROW 50051, 'UPDATE GOLD no afectó ninguna fila. Verificar registros en CatProductImage.', 1;

    COMMIT TRANSACTION
    PRINT '    [OK] GOLD actualizado. Filas afectadas: ' + CAST(@@ROWCOUNT AS VARCHAR)

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION
    PRINT '    [ERROR] Falló UPDATE de GOLD.'
    PRINT '    Mensaje : ' + ERROR_MESSAGE()
    PRINT '    Línea   : ' + CAST(ERROR_LINE() AS VARCHAR)
    PRINT '    Número  : ' + CAST(ERROR_NUMBER() AS VARCHAR)
END CATCH
GO


-- ---------------------------------------------------------------
-- [6/6] PLATINO
-- ---------------------------------------------------------------
PRINT '>>> [6/6] Actualizando imágenes: PLATINO...'

DECLARE @SV_PLATINO INT, @GT_PLATINO INT, @HN_PLATINO INT;

BEGIN TRANSACTION
BEGIN TRY

    SELECT @SV_PLATINO = IdCatSubscription FROM DeliveryBackOffice.dbo.CatSubscription WHERE IdCountry = 'SV' AND SubscriptionName = 'Paquete Platino';
    SELECT @GT_PLATINO = IdCatSubscription FROM DeliveryBackOffice.dbo.CatSubscription WHERE IdCountry = 'GT' AND SubscriptionName = 'Paquete Platino';
    SELECT @HN_PLATINO = IdCatSubscription FROM DeliveryBackOffice.dbo.CatSubscription WHERE IdCountry = 'HN' AND SubscriptionName = 'Paquete Platino';

    IF @SV_PLATINO IS NULL OR @GT_PLATINO IS NULL OR @HN_PLATINO IS NULL
        THROW 50060, 'No se encontró Paquete Platino para uno o más países (SV, GT, HN).', 1;

    PRINT '    IDs resueltos → SV: ' + CAST(@SV_PLATINO AS VARCHAR) + ' | GT: ' + CAST(@GT_PLATINO AS VARCHAR) + ' | HN: ' + CAST(@HN_PLATINO AS VARCHAR);

    UPDATE [DeliveryBackOffice].[dbo].[CatProductImage]
    SET
        CatProductImageSmallImageURL = 'https://www.forzadelivery.com/images/Tienda/platino_v2-500-347.jpg',
        CatProductImageLargeImageURL = 'https://www.forzadelivery.com/images/Tienda/platino_v2-1200-722.jpg',
        CatProductImageBigImageURL   = 'https://www.forzadelivery.com/images/Tienda/platino_v2-2103-521.jpg'
    WHERE CatSubscriptionId IN (@SV_PLATINO, @GT_PLATINO, @HN_PLATINO);

    IF @@ROWCOUNT = 0
        THROW 50061, 'UPDATE PLATINO no afectó ninguna fila. Verificar registros en CatProductImage.', 1;

    COMMIT TRANSACTION
    PRINT '    [OK] PLATINO actualizado. Filas afectadas: ' + CAST(@@ROWCOUNT AS VARCHAR)

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION
    PRINT '    [ERROR] Falló UPDATE de PLATINO.'
    PRINT '    Mensaje : ' + ERROR_MESSAGE()
    PRINT '    Línea   : ' + CAST(ERROR_LINE() AS VARCHAR)
    PRINT '    Número  : ' + CAST(ERROR_NUMBER() AS VARCHAR)
END CATCH
GO


-- ---------------------------------------------------------------
-- Verificación final: URLs actuales por paquete y país
-- ---------------------------------------------------------------
SELECT
    CS.IdCountry,
    CS.SubscriptionName,
    PI.CatProductImageSmallImageURL,
    PI.CatProductImageLargeImageURL,
    PI.CatProductImageBigImageURL
FROM DeliveryBackOffice.dbo.CatProductImage PI
INNER JOIN DeliveryBackOffice.dbo.CatSubscription CS
    ON PI.CatSubscriptionId = CS.IdCatSubscription
WHERE CS.IdCountry IN ('SV', 'GT', 'HN')
  AND CS.SubscriptionName IN (
      'Paquete MICRO',  'Paquete Petit',   'Paquete Básico',
      'Paquete Plus',   'Paquete Gold',    'Paquete Platino'
  )
ORDER BY
    CASE CS.SubscriptionName
        WHEN 'Paquete MICRO'   THEN 1
        WHEN 'Paquete Petit'   THEN 2
        WHEN 'Paquete Básico'  THEN 3
        WHEN 'Paquete Plus'    THEN 4
        WHEN 'Paquete Gold'    THEN 5
        WHEN 'Paquete Platino' THEN 6
        ELSE 100
    END,
    CS.IdCountry;
GO
BEGIN TRY
    BEGIN TRANSACTION;

    /*******************************************
              PAQUETE MICRO
    *********************************************/
    DECLARE @TokenCreated NVARCHAR(20) = 'SYS-TGARCIA';
    DECLARE @Country CHAR(2) = 'HN';

    -- Validar si ya existe la suscripción
    IF NOT EXISTS (
        SELECT 1 FROM [dbo].[CatSubscription]
        WHERE [SubscriptionName] = N'Paquete MICRO'
          AND [IdCountry] = @Country
    )
    BEGIN
        INSERT [dbo].[CatSubscription] ( 
            [SubscriptionName],
            [SubscriptionDescription],
            [SubscriptionCost],
            [SubscriptionFixedValue],
            [SubscriptionMaxServiceFixedValue],
            [SubscriptionValidity],
            [SubscriptionWeight],
            [RowStatus],
            [TokenCreated],
            [DateCreated],
            [TokenUpdated],
            [DateUpdated],
            [Icon],
            [NextSalesPackageBanner],
            [RateHeaderId],
            [AlternativeRateHeaderId],
            [IncludedMembershipId],
            [CatTypeSubscriptionId],
            [CatProductCategoryId],
            [Tag],
            [Position],
            [IdCountry],
            [IdCatCurrencyCOD],
            [LinkImage]
        ) 
        VALUES (
            N'Paquete MICRO', N'15 envíos L93.48 c/u', 1402.20, 0, 15, 6, 5, 1, @TokenCreated, GETDATE(), NULL, NULL, N'hwa-planMicroIcon', N'bannerSubsPlan4.png', NULL, NULL, NULL, 2, 2, N'NOVEDADES', 1, @Country, 1,N'https://forzadelivery.com/images/Tienda/sliderh01-992-200.jpg'
        );
    END;

    DECLARE @IdCatSubscriptionMICRO INT = (
        SELECT TOP 1 IdCatSubscription
        FROM [dbo].[CatSubscription]
        WHERE [SubscriptionName] = N'Paquete MICRO'
          AND [IdCountry] = @Country
    );

    /*******************************************
               TAGS POR PRODUCTO
    *********************************************/
    IF NOT EXISTS (
        SELECT 1 FROM [dbo].[MarketplaceTagsByProduct]
        WHERE [CatSubscriptionId] = @IdCatSubscriptionMICRO
          AND [MarketplaceProductTagsId] = 2
    )
    BEGIN
        INSERT [dbo].[MarketplaceTagsByProduct] (
            [MarketplaceProductTagsId],
            [RowStatus],
            [TokenCreated],
            [DateCreated],
            [CatSubscriptionId],
            [Position]
        ) 
        VALUES (2, 1, @TokenCreated, GETDATE(), @IdCatSubscriptionMICRO, 6);
    END;

    IF NOT EXISTS (
        SELECT 1 FROM [dbo].[MarketplaceTagsByProduct]
        WHERE [CatSubscriptionId] = @IdCatSubscriptionMICRO
          AND [MarketplaceProductTagsId] = 4
    )
    BEGIN
        INSERT [dbo].[MarketplaceTagsByProduct] (
            [MarketplaceProductTagsId],
            [RowStatus],
            [TokenCreated],
            [DateCreated],
            [CatSubscriptionId],
            [Position]
        ) 
        VALUES (4, 1, @TokenCreated, GETDATE(), @IdCatSubscriptionMICRO, 2);
    END;

    /*******************************************
                    IMÁGENES
    *********************************************/
    IF NOT EXISTS (
        SELECT 1 FROM [dbo].[CatProductImage]
        WHERE [CatSubscriptionId] = @IdCatSubscriptionMICRO
          AND [CatProductImageOrder] = 9
    )
    BEGIN
        INSERT [dbo].[CatProductImage] (
            [CatProductImageSmallImageURL],
            [CatProductImageLargeImageURL],
            [CatProductImageOrder],
            [RowStatus],
            [TokenCreated],
            [DateCreated],
            [CatSubscriptionId],
            [CatProductImageBigImageURL]
        ) 
        VALUES (
            N'https://www.forzadelivery.com/images/Miniatura/micro-500-347.jpg',
            N'https://www.forzadelivery.com/images/Miniatura/micro-1200-722.jpg',
            9, 
			1, 
			@TokenCreated, 
			GETDATE(),
            @IdCatSubscriptionMICRO,
            N'https://www.forzadelivery.com/images/Miniatura/micro-2103-521.jpg'
        );
    END;

    /*******************************************
                  ATRIBUTOS
    *********************************************/
    INSERT INTO [dbo].[CatSubscriptionAtribute] (
        [CatSubscriptionId],
        [CatAttributeId],
        [SubscriptionAttributeValue],
        [SubscriptionAttributeDescription],
        [SubscriptionAttributePosition],
        [RowStatus],
        [TokenCreated],
        [DateCreated],
        [SubscriptionAttributeDescriptionLong],
        [CatSubscriptionAttributeIcon]
    )
    SELECT @IdCatSubscriptionMICRO, 1, N'1', descs.[Short], descs.[Pos], 1,
           @TokenCreated, GETDATE(), descs.[Long], descs.[Icon]
    FROM (VALUES
        (N'15 guías a L93.48 c/u.', 1, N'15 guías a L93.48 c/u.', N'fa fa-check-circle fa-2x'),
        (N'Tarifa única en todo el país.', 2, N'Tarifa única en todo el país.', N'fa fa-map fa-2x'),
        (N'Costo único para todos tus clientes.', 3, N'Costo único para todos tus clientes.', N'bi bi-cash fa-2x'),
        (N'Hasta 10 Libras.', 4, N'Hasta 10 Libras.', N'fa fa-archive fa-2x')
    ) AS descs([Short],[Pos],[Long],[Icon])
    WHERE NOT EXISTS (
        SELECT 1 FROM [dbo].[CatSubscriptionAtribute]
        WHERE [CatSubscriptionId] = @IdCatSubscriptionMICRO
          AND [SubscriptionAttributeDescription] = descs.[Short]
    );

    /*******************************************
                DESCRIPCIONES
    *********************************************/
    INSERT INTO [dbo].[CatSubscriptionDescription] (
        [Title],
        [Description],
        [Position],
        [Type],
        [CatSubscriptionId],
        [RowStatus],
        [DateCreated],
        [TokenCreated]
    )
    SELECT d.[Title], d.[Description], d.[Pos], N'PAQUETE MICRO',
           @IdCatSubscriptionMICRO, 1, GETDATE(), @TokenCreated
    FROM (VALUES
        (N'¿Qué es?', N'Nuestro paquete te ofrece 15 guías de envío prepagadas con Tarifa única a
			todo el país, lo que significa que puedes enviar tus productos a cualquier
			destino sin preocuparte por tarifas variables. Pero eso no es todo, ¡nuestra
			tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías
			prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes
			una gran cantidad de envíos de manera continua? Estas guías son ideales
			para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una
			tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos
			sean más rentables y eficientes hoy mismo!', 1),
        (N'¿Cómo Funciona?', N'Compra en la tienda virtual y recibe las guías en tu correo electrónico.
			Prepara tus paquetes, completa la información de envío y entrégalos en las
			+90 agencias express center o puedes solicitar la recolección a tu casa u
			oficina. Rastrea el progreso del envío con el número de guía proporcionado
			para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al
			centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de
			los detalles logísticos. Adquiere tu Paquete Micro y podrás obtener tus
			guías prepagadas de 15 envíos con tarifa única a todo el país a L93.48
			c/u.', 2),
        (N'Aplican restricciones', N'En caso de que tu envío exceda el peso, de 0 a 10 libras, consulta los términos y condiciones.', 3)
    ) AS d([Title],[Description],[Pos])
    WHERE NOT EXISTS (
        SELECT 1 FROM [dbo].[CatSubscriptionDescription]
        WHERE [CatSubscriptionId] = @IdCatSubscriptionMICRO
          AND [Title] = d.[Title]
    );

    /*******************************************
                DESCUENTOS
    *********************************************/
    IF NOT EXISTS (
        SELECT 1 FROM [dbo].[CatSubscriptionDiscountRange]
        WHERE [CatSubscriptionId] = @IdCatSubscriptionMICRO
          AND [DiscountLowServiceRange] = 15
    )
    BEGIN
        INSERT [dbo].[CatSubscriptionDiscountRange] (
            [CatSubscriptionId],
            [DiscountLowServiceRange],
            [DiscountTopServiceRange],
            [ValueTypeId],
            [DiscountValue],
            [RowStatus],
            [TokenCreated],
            [DateCreated]
        )
        VALUES (@IdCatSubscriptionMICRO, 15, NULL, 1, 0.00, 1, @TokenCreated, GETDATE());
    END;

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

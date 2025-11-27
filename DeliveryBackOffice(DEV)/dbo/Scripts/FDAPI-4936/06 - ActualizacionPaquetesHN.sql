BEGIN TRY
    BEGIN TRANSACTION;

    /*******************************************

            PAQUETE PETIT

    *********************************************/
    DECLARE @TokenUpdated NVARCHAR(20) = 'SYS-TGARCIA'
    DECLARE @Country CHAR(2) = 'HN'
    DECLARE @IdCatSubscriptionPETIT INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete Petit' AND IdCountry = @Country) --17

    UPDATE [dbo].[CatSubscription]
    SET SubscriptionDescription = '25 envíos L90.00 c/u',
        SubscriptionCost = 2250.00,
        DateUpdated = GETDATE(),
        TokenUpdated = @TokenUpdated
    -- SELECT * FROM [dbo].[CatSubscription]
    WHERE  IdCatSubscription = @IdCatSubscriptionPETIT 
        AND  IdCountry = @Country

    UPDATE  [dbo].[CatSubscriptionDescription]
    SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Petit y podrás obtener tus guías prepagadas de 25 envíos con tarifa única a todo el país a L90.00 c/u.',
        DateUpdated = GETDATE(),
        TokenUpdated = @TokenUpdated
    -- SELECT * FROM [dbo].[CatSubscriptionDescription]
    WHERE CatSubscriptionId = @IdCatSubscriptionPETIT 
        AND RowStatus = 1 
        AND Title = '¿Cómo Funciona?'

    UPDATE dbo.CatSubscriptionAtribute
    SET SubscriptionAttributeDescription = '25 guías a L90.00 c/u.',
        SubscriptionAttributeDescriptionLong = '25 guías a L90.00 c/u.',
        DateUpdated = GETDATE(),
        TokenUpdated = @TokenUpdated
    -- SELECT * FROM dbo.CatSubscriptionAtribute
    WHERE CatSubscriptionId = @IdCatSubscriptionPETIT
        AND SubscriptionAttributeDescription='25 guías a L100.00 c/u.'

    /*******************************************

            PAQUETE BASICO

    *********************************************/
    DECLARE @IdCatSubscriptionBASICO INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete Básico' AND IdCountry = @Country) --13

    UPDATE [dbo].[CatSubscription]
    SET SubscriptionDescription ='50 envíos L85.50 c/u',
        SubscriptionCost = 4275.00,
        DateUpdated=GETDATE(),
        TokenUpdated = @TokenUpdated
    -- SELECT * FROM [dbo].[CatSubscription]
    WHERE  IdCatSubscription = @IdCatSubscriptionBASICO 
        AND  IdCountry = @Country

    UPDATE  [dbo].[CatSubscriptionDescription]
    SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Básico y podrás obtener tus guías prepagadas de 50 envíos con tarifa única a todo el país a L85.50 c/u.  ',
        DateUpdated=GETDATE(),
        TokenUpdated = @TokenUpdated
    -- SELECT * FROM [dbo].[CatSubscriptionDescription]
    WHERE CatSubscriptionId = @IdCatSubscriptionBASICO 
        AND RowStatus=1 
        AND Title='¿Cómo Funciona?'

    UPDATE dbo.CatSubscriptionAtribute
    SET SubscriptionAttributeDescription='50 guías a L85.50 c/u.',
        SubscriptionAttributeDescriptionLong = '50 guías a L85.50 c/u.',
        DateUpdated = GETDATE(),
        TokenUpdated = @TokenUpdated
    -- SELECT * FROM dbo.CatSubscriptionAtribute
    WHERE CatSubscriptionId = @IdCatSubscriptionBASICO 
        AND SubscriptionAttributeDescription='50 guías a L95.00 c/u.'

    /*******************************************

            PAQUETE PLUS

    *********************************************/
    DECLARE @IdCatSubscriptionPLUS INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete Plus' AND IdCountry = @Country) --14

    UPDATE [dbo].[CatSubscription]
    SET SubscriptionDescription ='100 envíos L81.00 c/u',
        SubscriptionCost = 8100.00,
        DateUpdated=GETDATE(),
        TokenUpdated = @TokenUpdated
    -- SELECT * FROM [dbo].[CatSubscription]
    WHERE  IdCatSubscription = @IdCatSubscriptionPLUS 
        AND  IdCountry = @Country

    UPDATE  [dbo].[CatSubscriptionDescription]
    SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electronico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Plus y podrás obtener tus guías prepagadas de 100 envíos con tarifa única a todo el país a L81.00 c/u.',
    DateUpdated=GETDATE(),
        TokenUpdated = @TokenUpdated
    -- SELECT * FROM [dbo].[CatSubscriptionDescription]
    WHERE CatSubscriptionId = @IdCatSubscriptionPLUS 
        AND RowStatus=1 
        AND Title='¿Cómo Funciona?'

    UPDATE dbo.CatSubscriptionAtribute
    SET SubscriptionAttributeDescription='100 guías a L81.00 c/u.',
        SubscriptionAttributeDescriptionLong = '100 guías a L81.00 c/u.',
        DateUpdated=GETDATE(),
        TokenUpdated = @TokenUpdated
    -- SELECT * FROM dbo.CatSubscriptionAtribute
    WHERE CatSubscriptionId = @IdCatSubscriptionPLUS
        AND SubscriptionAttributeDescription='100 guías a L90.00 c/u.'

    /*******************************************

            PAQUETE GOLD

    *********************************************/
    DECLARE @IdCatSubscriptionGOLD INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete Gold' AND IdCountry = @Country) --15


    UPDATE [dbo].[CatSubscription]
    SET SubscriptionDescription ='200 envíos L72.00 c/u',
        SubscriptionCost = 14400.00,
        DateUpdated=GETDATE(),
        TokenUpdated = @TokenUpdated
    -- SELECT * FROM [dbo].[CatSubscription]
    WHERE  IdCatSubscription = @IdCatSubscriptionGOLD  
        AND  IdCountry = @Country


    UPDATE  [dbo].[CatSubscriptionDescription]
    SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electronico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Gold y podrás obtener tus guías prepagadas de 200 envíos con tarifa única a todo el país a L72.00 c/u.  ',
        DateUpdated=GETDATE(),
        TokenUpdated = @TokenUpdated
    -- SELECT * FROM  [dbo].[CatSubscriptionDescription]
    WHERE CatSubscriptionId = @IdCatSubscriptionGOLD  
        AND RowStatus=1 
        AND Title='¿Cómo Funciona?'

    UPDATE dbo.CatSubscriptionAtribute
    SET SubscriptionAttributeDescription='200 guías a L72.00 c/u.',
        SubscriptionAttributeDescriptionLong = '200 guías a L72.00 c/u.',
        DateUpdated=GETDATE(),
        TokenUpdated = @TokenUpdated
    -- SELECT * FROM dbo.CatSubscriptionAtribute
    WHERE CatSubscriptionId = @IdCatSubscriptionGOLD
        AND SubscriptionAttributeDescription='200 guías a L80.00 c/u.';
            
    /*******************************************

            PAQUETE PLATINO

    *********************************************/
    DECLARE @IdCatSubscriptionPLATINO INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete Platino' AND IdCountry = @Country) --18

    UPDATE [dbo].[CatSubscription]
    SET SubscriptionDescription ='400 envíos L67.50 c/u',
        SubscriptionCost = 27000.00,
        DateUpdated = GETDATE(),
        TokenUpdated = @TokenUpdated
    -- SELECT * FROM [dbo].[CatSubscription]
    WHERE  IdCatSubscription = @IdCatSubscriptionPLATINO  
        AND  IdCountry = @Country

    UPDATE  [dbo].[CatSubscriptionDescription]
    SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Platino y podrás obtener tus guías prepagadas de 400 envíos con tarifa única a todo el país a L67.50 c/u.',
        DateUpdated = GETDATE(),
        TokenUpdated = @TokenUpdated
    -- SELECT * FROM [dbo].[CatSubscriptionDescription]
    WHERE CatSubscriptionId = @IdCatSubscriptionPLATINO  
        AND RowStatus = 1 
        AND Title = '¿Cómo Funciona?'

    UPDATE dbo.CatSubscriptionAtribute
    SET SubscriptionAttributeDescription='400 guías a L67.50 c/u.',
        SubscriptionAttributeDescriptionLong = '400 guías a L67.50 c/u.',
        DateUpdated = GETDATE(),
        TokenUpdated = @TokenUpdated
    -- SELECT * FROM dbo.CatSubscriptionAtribute
    WHERE CatSubscriptionId=@IdCatSubscriptionPLATINO 
        AND SubscriptionAttributeDescription='400 guías a L75.00 c/u.';
            
    /*******************************************

            PAQUETE PRO

    *********************************************/
    DECLARE @IdCatSubscriptionPRO INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete Pro' AND IdCountry = @Country) --19

    UPDATE [dbo].[CatSubscription]
    SET SubscriptionDescription = '600 envíos L63.00 c/u',
        SubscriptionCost = 37800.00,
        DateUpdated = GETDATE(),
        TokenUpdated = @TokenUpdated
    -- SELECT * FROM [dbo].[CatSubscription]
    WHERE  IdCatSubscription = @IdCatSubscriptionPRO  
        AND  IdCountry = @Country

    UPDATE  [dbo].[CatSubscriptionDescription]
    SET [Description] = 'Compra en la tienda virtual y recibe las guías en tu correo electrónico.  Prepara tus paquetes, completa la información de envío y entrégalos en las  +90 agencias express center o puedes solicitar la recolección a tu casa u  oficina. Rastrea el progreso del envío con el número de guía proporcionado  para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al  centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de  los detalles logísticos. Adquiere tu Paquete Pro y podrás obtener tus guías  prepagadas de 600 envíos con tarifa única a todo el país a L.63.00 c/u.',
        DateUpdated = GETDATE(),
        TokenUpdated = @TokenUpdated
    -- SELECT * FROM [dbo].[CatSubscriptionDescription]
    WHERE CatSubscriptionId = @IdCatSubscriptionPRO  
        AND RowStatus = 1 
        AND Title = '¿Cómo Funciona?'

    UPDATE dbo.CatSubscriptionAtribute
    SET SubscriptionAttributeDescription='600 guías a L63.00 c/u',
        SubscriptionAttributeDescriptionLong = '600 guías a L63.00 c/u.',
        DateUpdated = GETDATE(),
        TokenUpdated = @TokenUpdated
    -- SELECT * FROM dbo.CatSubscriptionAtribute
    WHERE CatSubscriptionId=@IdCatSubscriptionPRO
        AND SubscriptionAttributeDescription='600 guias a L70 C/U'


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
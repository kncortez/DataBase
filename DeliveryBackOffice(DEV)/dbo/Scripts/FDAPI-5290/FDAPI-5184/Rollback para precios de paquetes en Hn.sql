/* =================================================
   Script:    Rollback para precios de paquetes en Hn
   Propósito: Modificación de membresia y suscripciones en precio de Hn.
   Autor:     Walter Orozco
   Historia:  FDAPI-5290[FDAPI-5184]
   Fecha:     2025-12-26
================================================= */

BEGIN TRY
	BEGIN TRANSACTION

	DECLARE @TokenUpdated NVARCHAR(20) = 'SYS-WOROZCO'
	DECLARE @Country CHAR(2) = 'HN'

	--===========================================================
	--						PAQUETE PETIT
	--===========================================================

	DECLARE @IdCatSubscriptionPETIT INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete Petit' AND IdCountry = @Country) --17

    UPDATE [dbo].[CatSubscription]
    SET SubscriptionDescription = '25 envíos L100.00 c/u',
        SubscriptionCost = 2500.00,
        DateUpdated = GETDATE(),
        TokenUpdated = @TokenUpdated
    -- SELECT * FROM [dbo].[CatSubscription]
    WHERE  IdCatSubscription = @IdCatSubscriptionPETIT 
		AND  IdCountry = @Country

    UPDATE  [dbo].[CatSubscriptionDescription]
    SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Petit y podrás obtener tus guías prepagadas de 25 envíos con tarifa única a todo el país a L100.00 c/u.',
        DateUpdated = GETDATE(),
        TokenUpdated = @TokenUpdated
    -- SELECT * FROM [dbo].[CatSubscriptionDescription]
    WHERE CatSubscriptionId = @IdCatSubscriptionPETIT 
        AND RowStatus = 1 
        AND Title = '¿Cómo Funciona?'

    UPDATE dbo.CatSubscriptionAtribute
    SET SubscriptionAttributeDescription = '25 guías a L100.00 c/u.',
        SubscriptionAttributeDescriptionLong = '25 guías a L100.00 c/u.',
        DateUpdated = GETDATE(),
        TokenUpdated = @TokenUpdated
    -- SELECT * FROM dbo.CatSubscriptionAtribute
    WHERE CatSubscriptionId = @IdCatSubscriptionPETIT
        AND SubscriptionAttributePosition = 1

	--===========================================================
	--						PAQUETE BASICO
	--===========================================================

	DECLARE @IdCatSubscriptionBASICO INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete Básico' AND IdCountry = @Country) --13

    UPDATE [dbo].[CatSubscription]
    SET SubscriptionDescription ='50 envíos L95.00 c/u',
        SubscriptionCost = 4750.00,
        DateUpdated=GETDATE(),
        TokenUpdated = @TokenUpdated
    -- SELECT * FROM [dbo].[CatSubscription]
    WHERE  IdCatSubscription = @IdCatSubscriptionBASICO 
        AND  IdCountry = @Country

    UPDATE  [dbo].[CatSubscriptionDescription]
    SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Básico y podrás obtener tus guías prepagadas de 50 envíos con tarifa única a todo el país a L95.00 c/u.  ',
        DateUpdated=GETDATE(),
        TokenUpdated = @TokenUpdated
    -- SELECT * FROM [dbo].[CatSubscriptionDescription]
    WHERE CatSubscriptionId = @IdCatSubscriptionBASICO 
        AND RowStatus=1 
        AND Title='¿Cómo Funciona?'

    UPDATE dbo.CatSubscriptionAtribute
    SET SubscriptionAttributeDescription='50 guías a L95.00 c/u.',
        SubscriptionAttributeDescriptionLong = '50 guías a L95.00 c/u.',
        DateUpdated = GETDATE(),
        TokenUpdated = @TokenUpdated
    -- SELECT * FROM dbo.CatSubscriptionAtribute
    WHERE CatSubscriptionId = @IdCatSubscriptionBASICO 
        AND SubscriptionAttributePosition = 1

	--===========================================================
	--						PAQUETE PLUS
	--===========================================================

	DECLARE @IdCatSubscriptionPLUS INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete Plus' AND IdCountry = @Country) --14

    UPDATE [dbo].[CatSubscription]
    SET SubscriptionDescription ='100 envíos L90.00 c/u',
        SubscriptionCost = 9000.00,
        DateUpdated=GETDATE(),
        TokenUpdated = @TokenUpdated,
		Tag = NULL
    -- SELECT * FROM [dbo].[CatSubscription]
    WHERE  IdCatSubscription = @IdCatSubscriptionPLUS 
        AND  IdCountry = @Country

    UPDATE  [dbo].[CatSubscriptionDescription]
    SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electronico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Plus y podrás obtener tus guías prepagadas de 100 envíos con tarifa única a todo el país a L90.00 c/u.',
    DateUpdated=GETDATE(),
        TokenUpdated = @TokenUpdated
    -- SELECT * FROM [dbo].[CatSubscriptionDescription]
    WHERE CatSubscriptionId = @IdCatSubscriptionPLUS 
        AND RowStatus=1 
        AND Title='¿Cómo Funciona?'

    UPDATE dbo.CatSubscriptionAtribute
    SET SubscriptionAttributeDescription='100 guías a L90.00 c/u.',
        SubscriptionAttributeDescriptionLong = '100 guías a L90.00 c/u.',
        DateUpdated=GETDATE(),
        TokenUpdated = @TokenUpdated
    -- SELECT * FROM dbo.CatSubscriptionAtribute
    WHERE CatSubscriptionId = @IdCatSubscriptionPLUS
        AND SubscriptionAttributePosition = 1

	--===========================================================
	--						PAQUETE GOLD
	--===========================================================

	DECLARE @IdCatSubscriptionGOLD INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete Gold' AND IdCountry = @Country) --15

    UPDATE [dbo].[CatSubscription]
    SET SubscriptionDescription ='200 envíos L80.00 c/u',
        SubscriptionCost = 16000.00,
        DateUpdated=GETDATE(),
        TokenUpdated = @TokenUpdated,
		Tag = NULL
    -- SELECT * FROM [dbo].[CatSubscription]
    WHERE  IdCatSubscription = @IdCatSubscriptionGOLD  
        AND  IdCountry = @Country


    UPDATE  [dbo].[CatSubscriptionDescription]
    SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electronico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Gold y podrás obtener tus guías prepagadas de 200 envíos con tarifa única a todo el país a L80.00 c/u.  ',
        DateUpdated=GETDATE(),
        TokenUpdated = @TokenUpdated
    -- SELECT * FROM  [dbo].[CatSubscriptionDescription]
    WHERE CatSubscriptionId = @IdCatSubscriptionGOLD  
        AND RowStatus=1 
        AND Title='¿Cómo Funciona?'

    UPDATE dbo.CatSubscriptionAtribute
    SET SubscriptionAttributeDescription='200 guías a L80.00 c/u.',
        SubscriptionAttributeDescriptionLong = '200 guías a L80.00 c/u.',
        DateUpdated=GETDATE(),
        TokenUpdated = @TokenUpdated
    -- SELECT * FROM dbo.CatSubscriptionAtribute
    WHERE CatSubscriptionId = @IdCatSubscriptionGOLD
        AND SubscriptionAttributePosition = 1

	--===========================================================
	--						PAQUETE PLATINO
	--===========================================================

	DECLARE @IdCatSubscriptionPLATINO INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete Platino' AND IdCountry = @Country) --18

    UPDATE [dbo].[CatSubscription]
    SET SubscriptionDescription ='400 envíos L75.00 c/u',
        SubscriptionCost = 30000.00,
        DateUpdated = GETDATE(),
        TokenUpdated = @TokenUpdated,
		Tag = NULL
    -- SELECT * FROM [dbo].[CatSubscription]
    WHERE  IdCatSubscription = @IdCatSubscriptionPLATINO  
        AND  IdCountry = @Country

    UPDATE  [dbo].[CatSubscriptionDescription]
    SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Platino y podrás obtener tus guías prepagadas de 400 envíos con tarifa única a todo el país a L75.00 c/u.',
        DateUpdated = GETDATE(),
        TokenUpdated = @TokenUpdated
    -- SELECT * FROM [dbo].[CatSubscriptionDescription]
    WHERE CatSubscriptionId = @IdCatSubscriptionPLATINO  
        AND RowStatus = 1 
        AND Title = '¿Cómo Funciona?'

    UPDATE dbo.CatSubscriptionAtribute
    SET SubscriptionAttributeDescription='400 guías a L75.00 c/u.',
        SubscriptionAttributeDescriptionLong = '400 guías a L75.00 c/u.',
        DateUpdated = GETDATE(),
        TokenUpdated = @TokenUpdated
    -- SELECT * FROM dbo.CatSubscriptionAtribute
    WHERE CatSubscriptionId = @IdCatSubscriptionPLATINO 
        AND SubscriptionAttributePosition = 1

	--===========================================================
	--						PAQUETE PRO
	--===========================================================

	DECLARE @IdCatSubscriptionPRO INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete Pro' AND IdCountry = @Country) --19

    UPDATE [dbo].[CatSubscription]
    SET SubscriptionDescription = '600 envíos L70.00 c/u',
        SubscriptionCost = 42000.00,
        DateUpdated = GETDATE(),
        TokenUpdated = @TokenUpdated,
		Tag = NULL
    -- SELECT * FROM [dbo].[CatSubscription]
    WHERE  IdCatSubscription = @IdCatSubscriptionPRO  
        AND  IdCountry = @Country

    UPDATE  [dbo].[CatSubscriptionDescription]
    SET [Description] = 'Compra en la tienda virtual y recibe las guías en tu correo electrónico.  Prepara tus paquetes, completa la información de envío y entrégalos en las  +90 agencias express center o puedes solicitar la recolección a tu casa u  oficina. Rastrea el progreso del envío con el número de guía proporcionado  para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al  centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de  los detalles logísticos. Adquiere tu Paquete Pro y podrás obtener tus guías  prepagadas de 600 envíos con tarifa única a todo el país a L.70.00 c/u.',
        DateUpdated = GETDATE(),
        TokenUpdated = @TokenUpdated
    -- SELECT * FROM [dbo].[CatSubscriptionDescription]
    WHERE CatSubscriptionId = @IdCatSubscriptionPRO  
        AND RowStatus = 1 
        AND Title = '¿Cómo Funciona?'

    UPDATE dbo.CatSubscriptionAtribute
    SET SubscriptionAttributeDescription='600 guías a L70.00 c/u',
        SubscriptionAttributeDescriptionLong = '600 guías a L70.00 c/u.',
        DateUpdated = GETDATE(),
        TokenUpdated = @TokenUpdated
    -- SELECT * FROM dbo.CatSubscriptionAtribute
    WHERE CatSubscriptionId = @IdCatSubscriptionPRO
        AND SubscriptionAttributePosition = 1

	--===========================================================
	--						PAQUETE MICRO
	--===========================================================

	DECLARE @IdCatSubscriptionMICRO INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete MICRO' AND IdCountry = @Country) --29

    UPDATE [dbo].[CatSubscription]
    SET SubscriptionDescription = '15 envíos L104.00 c/u',
        SubscriptionCost = 1558.00,
        DateUpdated = GETDATE(),
        TokenUpdated = @TokenUpdated,
		Tag = NULL
    -- SELECT * FROM [dbo].[CatSubscription]
    WHERE  IdCatSubscription = @IdCatSubscriptionMICRO  
        AND  IdCountry = @Country

    UPDATE  [dbo].[CatSubscriptionDescription]
    SET [Description] = 'Compra en la tienda virtual y recibe las guías en tu correo electrónico.     Prepara tus paquetes, completa la información de envío y entrégalos en las     +90 agencias express center o puedes solicitar la recolección a tu casa u     oficina. Rastrea el progreso del envío con el número de guía proporcionado     para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al     centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de     los detalles logísticos. Adquiere tu Paquete Micro y podrás obtener tus     guías prepagadas de 15 envíos con tarifa única a todo el país a L104.00     c/u.',
        DateUpdated = GETDATE(),
        TokenUpdated = @TokenUpdated
    -- SELECT * FROM [dbo].[CatSubscriptionDescription]
    WHERE CatSubscriptionId = @IdCatSubscriptionMICRO  
        AND RowStatus = 1 
        AND Title = '¿Cómo Funciona?'

    UPDATE dbo.CatSubscriptionAtribute
    SET SubscriptionAttributeDescription='15 guías a L104.00 c/u.',
        SubscriptionAttributeDescriptionLong = '15 guías a L104.00 c/u.',
        DateUpdated = GETDATE(),
        TokenUpdated = @TokenUpdated
    -- SELECT * FROM dbo.CatSubscriptionAtribute
    WHERE CatSubscriptionId = @IdCatSubscriptionMICRO
        AND SubscriptionAttributePosition = 1
 
	COMMIT TRANSACTION;
	PRINT 'Actualización realizada correctamente.'
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION

    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
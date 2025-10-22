BEGIN TRY
    BEGIN TRANSACTION;

/*******************************************
*********************************************

          PAQUETE MICRO

*********************************************
*********************************************/


DECLARE @IdCatSubscriptionMICRO INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete MICRO' AND IdCountry='GT')


UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='15 guías a Q35.00 C/U',
    SubscriptionCost=525.00,
	DateUpdated=GETDATE(),
	TokenUpdated='SYS-BPEDROZA'
WHERE  IdCatSubscription = @IdCatSubscriptionMICRO AND  IdCountry='GT'


UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Micro y podrás obtener tus guías prepagadas de 15 envíos con tarifa única a todo el país a Q35.00 c/u.',
    DateUpdated=GETDATE(),
	TokenUpdated='SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionMICRO AND RowStatus=1 AND Title='¿Cómo Funciona?'

UPDATE dbo.CatSubscriptionAtribute
  SET SubscriptionAttributeDescription='15 guías a Q35.00 C/U',
      DateUpdated=GETDATE(),
	  TokenUpdated='SYS-BPEDROZA'
where CatSubscriptionId=@IdCatSubscriptionMICRO
And SubscriptionAttributeDescription='15 guías a Q36.00 c/u.'




/*******************************************
*********************************************

          PAQUETE PETIT

*********************************************
*********************************************/
DECLARE @IdCatSubscriptionPETIT INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete Petit' AND IdCountry='GT')

UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='25 guías a Q33.00 C/U',
    SubscriptionCost=825.00,
	DateUpdated=GETDATE(),
	TokenUpdated='SYS-BPEDROZA'
WHERE  IdCatSubscription = @IdCatSubscriptionPETIT AND  IdCountry='GT'

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Petit y podrás obtener tus guías prepagadas de 25 envíos con tarifa única a todo el país a Q33.00 c/u.',
    DateUpdated=GETDATE(),
	TokenUpdated='SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionPETIT AND RowStatus=1 AND Title='¿Cómo Funciona?'

UPDATE dbo.CatSubscriptionAtribute
  SET SubscriptionAttributeDescription='25 guías a Q33.00 C/U',
      DateUpdated=GETDATE(),
	  TokenUpdated='SYS-BPEDROZA'
where CatSubscriptionId=@IdCatSubscriptionPETIT
And SubscriptionAttributeDescription='25 guías a Q34.00 c/u.'



/*******************************************
*********************************************

          PAQUETE BASICO

*********************************************
*********************************************/
DECLARE @IdCatSubscriptionBASICO INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete Básico' AND IdCountry='GT')


UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='50 guías a Q31.00 C/U',
    SubscriptionCost=1550.00,
	DateUpdated=GETDATE(),
	TokenUpdated='SYS-BPEDROZA'
WHERE  IdCatSubscription = @IdCatSubscriptionBASICO AND  IdCountry='GT'

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Basico y podrás obtener tus guías prepagadas de 50 envíos con tarifa única a todo el país a Q31.00 c/u.',
    DateUpdated=GETDATE(),
	TokenUpdated='SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionBASICO AND RowStatus=1 AND Title='¿Cómo Funciona?'

UPDATE dbo.CatSubscriptionAtribute
  SET SubscriptionAttributeDescription='50 guías a Q31.00 C/U',
      DateUpdated=GETDATE(),
	  TokenUpdated='SYS-BPEDROZA'
where CatSubscriptionId=@IdCatSubscriptionBASICO 
And SubscriptionAttributeDescription='50 guias a Q32.00 c/u.'




/*******************************************
*********************************************

          PAQUETE PLUS

*********************************************
*********************************************/
DECLARE @IdCatSubscriptionPLUS INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete Plus' AND IdCountry='GT')

UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='100 guías a Q29.00 C/U',
    SubscriptionCost=2900.00,
	DateUpdated=GETDATE(),
	TokenUpdated='SYS-BPEDROZA'
WHERE  IdCatSubscription = @IdCatSubscriptionPLUS AND  IdCountry='GT'

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Plus y podrás obtener tus guías prepagadas de 100 envíos con tarifa única a todo el país a Q29.00 c/u.',
DateUpdated=GETDATE(),
	TokenUpdated='SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionPLUS AND RowStatus=1 AND Title='¿Cómo Funciona?'

UPDATE dbo.CatSubscriptionAtribute
  SET SubscriptionAttributeDescription='100 guías a Q29.00 C/U',
      DateUpdated=GETDATE(),
	  TokenUpdated='SYS-BPEDROZA'
where CatSubscriptionId=@IdCatSubscriptionPLUS
And SubscriptionAttributeDescription='100 guías a Q30.00 c/u.'




/*******************************************
*********************************************

          PAQUETE GOLD

*********************************************
*********************************************/
DECLARE @IdCatSubscriptionGOLD INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete Gold' AND IdCountry='GT')


UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='200 guías a Q27.00 C/U',
    SubscriptionCost=5400.00,
	DateUpdated=GETDATE(),
	TokenUpdated='SYS-BPEDROZA'
WHERE  IdCatSubscription = @IdCatSubscriptionGOLD  AND  IdCountry='GT'


UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Gold y podrás obtener tus guías prepagadas de 200 envíos con tarifa única a todo el país a Q27.00 c/u.',
    DateUpdated=GETDATE(),
	TokenUpdated='SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionGOLD  AND RowStatus=1 AND Title='¿Cómo Funciona?'

UPDATE dbo.CatSubscriptionAtribute
  SET SubscriptionAttributeDescription='200 guías a Q27.00 C/U',
      DateUpdated=GETDATE(),
	  TokenUpdated='SYS-BPEDROZA'
where CatSubscriptionId=@IdCatSubscriptionGOLD
And SubscriptionAttributeDescription='200 guías a Q28.00 c/u.'





/*******************************************
*********************************************

          PAQUETE PLATINO

*********************************************
*********************************************/
DECLARE @IdCatSubscriptionPLATINO INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete Platino' AND IdCountry='GT')

UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='400 guías a Q25.00 C/U',
    SubscriptionCost=10000.00,
	DateUpdated=GETDATE(),
	TokenUpdated='SYS-BPEDROZA'
WHERE  IdCatSubscription = @IdCatSubscriptionPLATINO  AND  IdCountry='GT'

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Platino y podrás obtener tus guías prepagadas de 400 envíos con tarifa única a todo el país a Q25.00 c/u.',
    DateUpdated=GETDATE(),
	TokenUpdated='SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionPLATINO  AND RowStatus=1 AND Title='¿Cómo Funciona?'

UPDATE dbo.CatSubscriptionAtribute
  SET SubscriptionAttributeDescription='400 guías a Q25.00 C/U',
      DateUpdated=GETDATE(),
	  TokenUpdated='SYS-BPEDROZA'
where CatSubscriptionId=@IdCatSubscriptionPLATINO 
And SubscriptionAttributeDescription='400 guías a Q24.00 c/u.'




/*******************************************
*********************************************

          PAQUETE PLATINO

*********************************************
*********************************************/
DECLARE @IdCatSubscriptionPRO INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete Pro' AND IdCountry='GT')

UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='500 guías a Q23.00 C/U',
    SubscriptionCost=11500.00,
	DateUpdated=GETDATE(),
	TokenUpdated='SYS-BPEDROZA'
WHERE  IdCatSubscription = @IdCatSubscriptionPRO  AND  IdCountry='GT'

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Pro y podrás obtener tus guías prepagadas de 500 envíos con tarifa única a todo el país a Q23.00 c/u.',
    DateUpdated=GETDATE(),
	TokenUpdated='SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionPRO  AND RowStatus=1 AND Title='¿Cómo Funciona?'

UPDATE dbo.CatSubscriptionAtribute
  SET SubscriptionAttributeDescription='500 guías a Q23.00 C/U',
      DateUpdated=GETDATE(),
	  TokenUpdated='SYS-BPEDROZA'
where CatSubscriptionId=@IdCatSubscriptionPRO
And SubscriptionAttributeDescription='500 guías a Q22.00 c/u.'


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
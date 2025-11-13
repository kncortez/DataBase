BEGIN TRY
    BEGIN TRANSACTION;

/*******************************************
*********************************************

          PAQUETE PLATINO

*********************************************
*********************************************/
DECLARE @IdCatSubscriptionPLATINO INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete Platino' AND IdCountry='GT')

UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='400 guías a Q24.00 C/U',
    SubscriptionCost=9600.00,
	Tag = NULL,
	DateUpdated=GETDATE(),
	TokenUpdated='SYS-BPEDROZA'
WHERE  IdCatSubscription = @IdCatSubscriptionPLATINO  AND  IdCountry='GT'

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Platino y podrás obtener tus guías prepagadas de 400 envíos con tarifa única a todo el país a Q24.00 c/u.',
    DateUpdated=GETDATE(),
	TokenUpdated='SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionPLATINO  AND RowStatus=1 AND Title='¿Cómo Funciona?'

UPDATE dbo.CatSubscriptionAtribute
  SET SubscriptionAttributeDescription='400 guías a Q24.00 C/U',
      DateUpdated=GETDATE(),
	  TokenUpdated='SYS-BPEDROZA'
where CatSubscriptionId=@IdCatSubscriptionPLATINO 
And SubscriptionAttributeDescription='400 guías a Q25.00 C/U'





/*******************************************
*********************************************

          PAQUETE PRO

*********************************************
*********************************************/
DECLARE @IdCatSubscriptionPRO INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete Pro' AND IdCountry='GT')

UPDATE [dbo].[CatSubscription]
SET SubscriptionDescription ='500 guías a Q22.00 C/U',
    SubscriptionCost=11000.00,
	Tag = NULL,
	DateUpdated=GETDATE(),
	TokenUpdated='SYS-BPEDROZA'
WHERE  IdCatSubscription = @IdCatSubscriptionPRO  AND  IdCountry='GT'

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Pro y podrás obtener tus guías prepagadas de 500 envíos con tarifa única a todo el país a Q22.00 c/u.',
    DateUpdated=GETDATE(),
	TokenUpdated='SYS-BPEDROZA'
WHERE CatSubscriptionId = @IdCatSubscriptionPRO  AND RowStatus=1 AND Title='¿Cómo Funciona?'

UPDATE dbo.CatSubscriptionAtribute
  SET SubscriptionAttributeDescription='500 guías a Q22.00 C/U',
      DateUpdated=GETDATE(),
	  TokenUpdated='SYS-BPEDROZA'
where CatSubscriptionId=@IdCatSubscriptionPRO
And SubscriptionAttributeDescription='500 guías a Q23.00 C/U'


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
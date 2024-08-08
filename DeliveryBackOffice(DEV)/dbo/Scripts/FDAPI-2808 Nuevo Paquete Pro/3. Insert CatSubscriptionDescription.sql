Use DeliveryBackOffice
GO

Declare @NewIdCatProduct INT =(Select idCatSubscription from dbo.CatSubscription where SubscriptionName='Paquete PRO' and rowstatus=1);	


BEGIN TRANSACTION
BEGIN TRY

    INSERT INTO [dbo].[CatSubscriptionDescription]
            ([Title]
            ,[Description]
            ,[Position]
            ,[Type]
            ,[CatSubscriptionId]
            ,[RowStatus]
            ,[DateCreated]
            ,[TokenCreated]
            ,[DateUpdated]
            ,[TokenUpdated])
        VALUES
            ('¿Qué es?'
            ,'Nuestro paquete te ofrece 600 guías de envío prepagadas con Tarifa única a todo el país, lo que significa que puedes enviar tus productos a cualquier destino sin preocuparte por tarifas variables. Pero eso no es todo, ¡nuestra tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes una gran cantidad de envíos de manera continua? Estas guías son ideales para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos sean más rentables y eficientes hoy mismo!'
            ,1
            ,'PAQUETE PRO'
            ,@NewIdCatProduct
            ,1
            ,GETDATE()
            ,'SYS-IXCHOP'
            ,NULL
            ,NULL)

    INSERT INTO [dbo].[CatSubscriptionDescription]
            ([Title]
            ,[Description]
            ,[Position]
            ,[Type]
            ,[CatSubscriptionId]
            ,[RowStatus]
            ,[DateCreated]
            ,[TokenCreated]
            ,[DateUpdated]
            ,[TokenUpdated])
        VALUES
            ('¿Cómo Funciona?'
            ,'Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Pro y podrás obtener tus guías prepagadas de 600 envíos con tarifa única a todo el país a Q25.00 c/u.'
            ,2
            ,'PAQUETE PRO'
            ,@NewIdCatProduct
            ,1
            ,GETDATE()
            ,'SYS-IXCHOP'
            ,NULL
            ,NULL)


    INSERT INTO [dbo].[CatSubscriptionDescription]
            ([Title]
            ,[Description]
            ,[Position]
            ,[Type]
            ,[CatSubscriptionId]
            ,[RowStatus]
            ,[DateCreated]
            ,[TokenCreated]
            ,[DateUpdated]
            ,[TokenUpdated])
        VALUES
            ('Aplican restricciones'
            ,'En caso de que tu envío exceda el peso, +Q1.00 por libra adicional, consulta los términos y condiciones.'
            ,3
            ,'PAQUETE PRO'
            ,@NewIdCatProduct
            ,1
            ,GETDATE()
            ,'SYS-IXCHOP'
            ,NULL
            ,NULL)

    COMMIT;
    SELECT 'Se han realizado los resgistros exitosamente'            

END TRY
BEGIN CATCH
    ROLLBACK
    SELECT 'Error'
END CATCH
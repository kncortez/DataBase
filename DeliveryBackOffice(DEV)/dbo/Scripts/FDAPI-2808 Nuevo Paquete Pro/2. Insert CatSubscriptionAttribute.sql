Use DeliveryBackOffice
GO

Declare @NewIdCatProduct INT =(Select idCatSubscription from dbo.CatSubscription where SubscriptionName='Paquete PRO' and rowstatus=1);	


-----------------------------------------------------------------------
--Insert en CatSubscriptionAtribute
-----------------------------------------------------------------------

--Atributo 1 CatSubscriptionAtribute
BEGIN TRANSACTION
BEGIN TRY
    
    INSERT INTO [dbo].[CatSubscriptionAtribute]
            ([CatSubscriptionId]
            ,[CatAttributeId]
            ,[SubscriptionAttributeValue]
            ,[SubscriptionAttributeDescription]
            ,[SubscriptionAttributePosition]
            ,[RowStatus]
            ,[TokenCreated]
            ,[DateCreated]
            ,[TokenUpdated]
            ,[DateUpdated]
            ,[SubscriptionAttributeDescriptionLong]
            ,[CatSubscriptionAttributeIcon])
        VALUES
            (@NewIdCatProduct
            ,1
            ,1
            ,'600 guías a Q25 c/u.'
            ,1
            ,1
            ,'SYS-AIXCHOP'
            ,GETDATE()
            ,NULL
            ,NULL
            ,'600 guías a Q25 c/u.'
            ,'fa fa-check-circle fa-2x')

    --Atributo 2 CatSubscriptionAtribute
    INSERT INTO [dbo].[CatSubscriptionAtribute]
            ([CatSubscriptionId]
            ,[CatAttributeId]
            ,[SubscriptionAttributeValue]
            ,[SubscriptionAttributeDescription]
            ,[SubscriptionAttributePosition]
            ,[RowStatus]
            ,[TokenCreated]
            ,[DateCreated]
            ,[TokenUpdated]
            ,[DateUpdated]
            ,[SubscriptionAttributeDescriptionLong]
            ,[CatSubscriptionAttributeIcon])
        VALUES
            (@NewIdCatProduct
            ,1
            ,1
            ,'Tarifa única en todo el país.'
            ,2
            ,1
            ,'SYS-AIXCHOP'
            ,GETDATE()
            ,NULL
            ,NULL
            ,'Tarifa única en todo el país.'
            ,'fa fa-map fa-2x')

    --Atributo 2 CatSubscriptionAtribute
    INSERT INTO [dbo].[CatSubscriptionAtribute]
            ([CatSubscriptionId]
            ,[CatAttributeId]
            ,[SubscriptionAttributeValue]
            ,[SubscriptionAttributeDescription]
            ,[SubscriptionAttributePosition]
            ,[RowStatus]
            ,[TokenCreated]
            ,[DateCreated]
            ,[TokenUpdated]
            ,[DateUpdated]
            ,[SubscriptionAttributeDescriptionLong]
            ,[CatSubscriptionAttributeIcon])
        VALUES
            (@NewIdCatProduct
            ,1
            ,1
            ,'Costo único para todos tus clientes.'
            ,3
            ,1
            ,'SYS-AIXCHOP'
            ,GETDATE()
            ,NULL
            ,NULL
            ,'Costo único para todos tus clientes.'
            ,'bi bi-cash fa-2x')

    --Atributo 3 CatSubscriptionAtribute
    INSERT INTO [dbo].[CatSubscriptionAtribute]
            ([CatSubscriptionId]
            ,[CatAttributeId]
            ,[SubscriptionAttributeValue]
            ,[SubscriptionAttributeDescription]
            ,[SubscriptionAttributePosition]
            ,[RowStatus]
            ,[TokenCreated]
            ,[DateCreated]
            ,[TokenUpdated]
            ,[DateUpdated]
            ,[SubscriptionAttributeDescriptionLong]
            ,[CatSubscriptionAttributeIcon])
        VALUES
            (@NewIdCatProduct
            ,1
            ,1
            ,'Hasta 10 libras.'
            ,4
            ,1
            ,'SYS-AIXCHOP'
            ,GETDATE()
            ,NULL
            ,NULL
            ,'Hasta 10 libras.'
            ,'fa fa-archive fa-2x')

    --Atributo 4 CatSubscriptionAtribute
    INSERT INTO [dbo].[CatSubscriptionAtribute]
            ([CatSubscriptionId]
            ,[CatAttributeId]
            ,[SubscriptionAttributeValue]
            ,[SubscriptionAttributeDescription]
            ,[SubscriptionAttributePosition]
            ,[RowStatus]
            ,[TokenCreated]
            ,[DateCreated]
            ,[TokenUpdated]
            ,[DateUpdated]
            ,[SubscriptionAttributeDescriptionLong]
            ,[CatSubscriptionAttributeIcon])
        VALUES
            (@NewIdCatProduct
            ,1
            ,1
            ,'La tarifa más barata del mercado.'
            ,5
            ,1
            ,'SYS-AIXCHOP'
            ,GETDATE()
            ,NULL
            ,NULL
            ,'La tarifa más barata del mercado.'
            ,'fa fa-archive fa-2x')


    --Atributo 5 CatSubscriptionAtribute
    INSERT INTO [dbo].[CatSubscriptionAtribute]
            ([CatSubscriptionId]
            ,[CatAttributeId]
            ,[SubscriptionAttributeValue]
            ,[SubscriptionAttributeDescription]
            ,[SubscriptionAttributePosition]
            ,[RowStatus]
            ,[TokenCreated]
            ,[DateCreated]
            ,[TokenUpdated]
            ,[DateUpdated]
            ,[SubscriptionAttributeDescriptionLong]
            ,[CatSubscriptionAttributeIcon])
        VALUES
            (@NewIdCatProduct
            ,1
            ,1
            ,'Vigencia de 6 meses.'
            ,6
            ,1
            ,'SYS-AIXCHOP'
            ,GETDATE()
            ,NULL
            ,NULL
            ,'Vigencia de 6 meses.'
            ,'fa fa-check-circle fa-2x')
    COMMIT;
    SELECT 'Se han realizado los resgistros exitosamente'
END TRY
BEGIN CATCH
    ROLLBACK
    SELECT 'Error'
END CATCH

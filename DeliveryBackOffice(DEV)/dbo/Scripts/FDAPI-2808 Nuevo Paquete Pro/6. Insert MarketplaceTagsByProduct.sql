Use DeliveryBackOffice
GO

Declare @NewIdCatProduct INT =(Select idCatSubscription from dbo.CatSubscription where SubscriptionName='Paquete PRO' and rowstatus=1);	


BEGIN TRANSACTION
BEGIN TRY



    INSERT INTO [dbo].[MarketplaceTagsByProduct]
            ([MarketplaceProductTagsId]
            ,[RowStatus]
            ,[TokenCreated]
            ,[DateCreated]
            ,[TokenUpdated]
            ,[DateUpdated]
            ,[CatSubscriptionId]
            ,[CatMembershipId]
            ,[Position])
        VALUES
            (4--Tag de todos los productos
            ,1
            ,'SYS-AIXCHOP'
            ,GETDATE()
            ,NULL
            ,NULL
            ,@NewIdCatProduct 
            ,NULL
            ,6)


    INSERT INTO [dbo].[MarketplaceTagsByProduct]
            ([MarketplaceProductTagsId]
            ,[RowStatus]
            ,[TokenCreated]
            ,[DateCreated]
            ,[TokenUpdated]
            ,[DateUpdated]
            ,[CatSubscriptionId]
            ,[CatMembershipId]
            ,[Position])
        VALUES
            (2--Tag de novedades
            ,1
            ,'SYS-AIXCHOP'
            ,GETDATE()
            ,NULL
            ,NULL
            ,@NewIdCatProduct 
            ,NULL
            ,6)
    COMMIT;
    SELECT 'Se han realizado los resgistros exitosamente'            
END TRY
BEGIN CATCH
    ROLLBACK
    SELECT 'Error'
END CATCH           
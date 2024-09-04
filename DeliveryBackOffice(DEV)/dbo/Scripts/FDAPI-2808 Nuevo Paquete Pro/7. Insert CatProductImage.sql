USE [DeliveryBackOffice]
GO

Declare @NewIdCatProduct INT =(Select idCatSubscription from dbo.CatSubscription where SubscriptionName='Paquete PRO' and rowstatus=1);	


BEGIN TRANSACTION
BEGIN TRY

    INSERT INTO [dbo].[CatProductImage]
                    ([CatProductImageSmallImageURL]
                    ,[CatProductImageLargeImageURL]
                    ,[CatProductImageOrder]
                    ,[RowStatus]
                    ,[TokenCreated]
                    ,[DateCreated]
                    ,[TokenUpdated]
                    ,[DateUpdated]
                    ,[CatSubscriptionId]
                    ,[CatMembershipId]
                    ,[CatProductImageBigImageURL]
                    ,[CatProductImageXXXLImageURL])
                VALUES
                    ('https://forzadelivery.com/images/Tienda/pro-500-347.jpg'
                    ,'https://forzadelivery.com/images/Tienda/pro-1200-722.jpg'
                    ,8
                    ,1
                    ,'SYS-AIXCHOP'
                    ,GETDATE()
                    ,NULL
                    ,NULL
                    ,@NewIdCatProduct 
                    ,NULL
                    ,'https://forzadelivery.com/images/Tienda/pro-2103-521.jpg'
                    ,NULL)

    COMMIT;
    SELECT 'Se han realizado los resgistros exitosamente'            

END TRY
BEGIN CATCH
    ROLLBACK
    SELECT 'Error'
END CATCH
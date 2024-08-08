Use DeliveryBackOffice
GO

Declare @NewIdCatProduct INT =(Select idCatSubscription from dbo.CatSubscription where SubscriptionName='Paquete PRO' and rowstatus=1);	


BEGIN TRANSACTION
BEGIN TRY



    INSERT INTO [dbo].[CatSubscriptionDiscountRange]
            ([CatSubscriptionId]
            ,[DiscountLowServiceRange]
            ,[DiscountTopServiceRange]
            ,[ValueTypeId]
            ,[DiscountValue]
            ,[RowStatus]
            ,[TokenCreated]
            ,[DateCreated]
            ,[TokenUpdated]
            ,[DateUpdated])
        VALUES
            (@NewIdCatProduct
            ,600
            ,NULL
            ,1
            ,0.00
            ,1
            ,'SYS-AIXCHOP'
            ,GETDATE()
            ,NULL
            ,NULL)
    COMMIT;
    SELECT 'Se han realizado los resgistros exitosamente'            

END TRY
BEGIN CATCH
    ROLLBACK
    SELECT 'Error'
END CATCH
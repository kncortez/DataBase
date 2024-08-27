SELECT * FROM DeliveryBackOffice.dbo.RatebyCustomer
WHERE RbcIdCustomer = 81 OR RbcIdRate = 2286

INSERT INTO [dbo].[RatebyCustomer]
           ([RbcIdRate]
           ,[RbcIdCustomer]
           ,[RbcRowStatus]
           ,[RbcTokenCreated]
           ,[RbcDateCreated]
           ,[RbcTokenUpdated]
           ,[RbcDateUpdated]
           ,[RbcCodeOfReference])
     VALUES
           (3675
           ,68381
           ,1
           ,'SYS-WOROZCO'
           ,'2024-06-13 10:15:00.000'
           ,NULL
           ,NULL
           ,NULL)











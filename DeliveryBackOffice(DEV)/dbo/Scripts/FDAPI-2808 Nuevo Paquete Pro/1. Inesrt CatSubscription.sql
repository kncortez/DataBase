Use DeliveryBackOffice
GO

INSERT INTO [dbo].[CatSubscription]
           ([SubscriptionName]
           ,[SubscriptionDescription]
           ,[SubscriptionCost]
           ,[SubscriptionFixedValue]
           ,[SubscriptionMaxServiceFixedValue]
           ,[SubscriptionValidity]
           ,[SubscriptionWeight]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated]
           ,[Icon]
           ,[NextSalesPackageBanner]
           ,[RateHeaderId]
           ,[AlternativeRateHeaderId]
           ,[IncludedMembershipId]
           ,[CatTypeSubscriptionId]
           ,[CatProductCategoryId]
           ,[Tag]
           ,[Position])
     VALUES
           ('Paquete PRO'
           ,'600 envíos Q25.00 c/u'
           ,15000.00
           ,0
           ,600
           ,6
           ,5
           ,1
           ,'SYS-AIXCHOP'
           ,GETDATE()
           ,NULL
           ,NULL
           ,'hwa-planProIcon'
           ,'bannerSubsPlan4.png'
           ,NULL
           ,NULL
           ,NULL
           ,2
           ,2
           ,'NOVEDADES'
           ,1)
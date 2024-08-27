--COPIAR
SELECT TOP 20 * FROM DeliveryBackOffice.dbo.VisitPointClient
WHERE CustomerID = 81
ORDER BY IdVisitPointClient DESC

--INSERT
INSERT INTO [dbo].[VisitPointClient]
           ([CodeOfReference]
           ,[DescriptionOfClient]
           ,[StatusClient]
           ,[CountryId]
           ,[VisitPointId]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated]
           ,[CustomerID]
           ,[Address]
           ,[Zone]
           ,[Town]
           ,[Department]
           ,[Phone]
           ,[ContactName]
           ,[IdKindOfVPClient]
           ,[IdKindOfVPBusiness]
           ,[IdSettlement]
           ,[Email]
           ,[IdTownship]
           ,[Latitude]
           ,[Longitude]
           ,[Accuracy]
           ,[BranchCode]
           ,[SaleChannelId]
           ,[ExcludePriceShippingCOD]
           ,[ExcludeCommissionCOD]
           ,[IsOriginVisitPoint]
           ,[LogLatitude]
           ,[LogLongitude]
           ,[DescriptionCC]
           ,[CatBusinessSegmentId]
           ,[AllowScheduledPickups])
     VALUES
           (677882
           ,'FD EXC HN 1'
           ,1
           ,'HN'
           ,NULL
           ,'SYS-WOROZCO'
           ,'2024-06-12 17:30:00.000'
           ,NULL
           ,NULL
           ,68381
           ,''
           ,'0'
           ,'YORO'
           ,'YORO'
           ,'(+504) 2217-0098'
           ,'FD EXC HN 1'
           ,1
           ,21
           ,2755
           ,'x_exc.hn1@forzadelivery.com'
           ,633
           ,'15.1375'
           ,'-87.12778'
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,1
           ,'15.1375'
           ,'-87.12778'
           ,'Express Center HN 1'
           ,21
           ,NULL)


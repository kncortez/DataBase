--CLONAR
SELECT * FROM DeliveryBackOffice.dbo.AlternativeRateByCustomer
where CustomerId IN (81,68381)

INSERT INTO [dbo].[AlternativeRateByCustomer]
           ([RateId]
           ,[CustomerId]
           ,[VisitPointClientId]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           (3676
           ,68381
           ,NULL
           ,1
           ,'SYS-WOROZCO'
           ,'2024-06-13 10:22:00.000'
           ,NULL
           ,NULL)

USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[CatTransportCompany]
           ([TransportCompanyName]
           ,[TransportCompanyDescription]
           ,[TansportCompanyAbbreviation]
           ,[CountryID]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DataUpdated])
     VALUES
           ('FORZA DELIVERY EXPRESS'
           ,'FORZA DELIVERY EXPRESS'
           ,'DELIVERY'
           ,'GT'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO



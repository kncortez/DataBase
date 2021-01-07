USE [DeliveryBackOffice]
GO

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
           ,[Email])
     VALUES
           (5301,'VP HUB GT',1,'GT',NULL,'SYS-CAQUINO',GETDATE(),NULL,NULL,6,'HUB GUATEMALA',12,'Guatemala','Guatemala','22882560','contact_name',6,10,518,'test@forzalatam.com')
GO
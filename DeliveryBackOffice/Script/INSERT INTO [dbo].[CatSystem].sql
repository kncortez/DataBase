USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[CatSystem]
           ([SysNameSystem]
           ,[SysPlataform]
           ,[SysDescription]
           ,[SysRowStatus]
           ,[SysTokenCreated]
           ,[SysDateCreated]
           ,[SysTokenUpdated]
           ,[SysDateUpdated]
           ,[SysShow])
     VALUES
           ('Hermes Web-Concesionario'
           ,'forzadelivery.com/portal'
           ,'Portal Web Concesionario'
           ,1
           ,'SYS-FMONTERROSO'
           ,GETDATE()
           ,NULL
           ,NULL
           ,0)
GO



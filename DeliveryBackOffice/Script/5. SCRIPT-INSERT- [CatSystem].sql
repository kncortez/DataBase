--Script para crear id system Hermes Desktop
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
           ,[SysDateUpdated])
     VALUES
           ('Hermes Desktop'
           ,'Forza Delivery Desktop'
           ,'Desktop Aplication'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO
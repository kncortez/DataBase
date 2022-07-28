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
           ('Hermes Web-ExpressCenter',
			'forzadelivery.com/portal',
            'Portal Web Express Center',
			1,
			'SYS-CAQUINO',
            GETDATE(),
            NULL,
			NULL)
			
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
           ('Hermes Web-Corporativo',
			'forzadelivery.com/portal',
            'Portal Web Corporativo',
			1,
			'SYS-CAQUINO',
            GETDATE(),
            NULL,
			NULL)

GO



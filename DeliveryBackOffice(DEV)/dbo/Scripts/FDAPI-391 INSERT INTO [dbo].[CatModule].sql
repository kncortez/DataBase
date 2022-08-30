USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Impersonar-corporativo',
			NULL,
            '',
            'Impersonar clientes corporativos desde portal web',
			1,
			NULL,
            1,
            1,
			'SYS-FMONTERROSO',
            GETDATE(),
            NULL,
			NULL)

INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Impersonar-Individual',
			NULL,
            '',
            'Impersonar clientes individuales desde portal web',
			1,
			NULL,
            1,
            1,
			'SYS-FMONTERROSO',
            GETDATE(),
            NULL,
			NULL)
			
INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Parser',
			NULL,
            'Parser',
            'Parser',
			1,
			NULL,
            1,
            1,
			'SYS-ORODRIGUEZ',
            GETDATE(),
            NULL,
			NULL)
GO



USE [DeliveryBackOffice]
GO

declare @ultimo as int 
set @ultimo = (select top 1 mdl2.ModIdModule from CatModule mdl2 order by 1 desc );

--DBCC CHECKIDENT ( [CatSaleAdvisor], RESEED, 5); 

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
           ('Delivery'
           ,NULL
           ,''
           ,'Menu'
           ,1
           ,''
           ,'TRUE'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)


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
           ('Operaciones'
           ,NULL
           ,''
           ,'Menu'
           ,1
           ,''
           ,'TRUE'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)


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
           ('Comercial'
           ,NULL
           ,''
           ,'Menu'
           ,1
           ,''
           ,'TRUE'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)

DECLARE @IdComercial as int  = SCOPE_IDENTITY()
set @IdComercial = (select top 1 cm.ModIdModule from CatModule cm where cm.ModName = 'Comercial')

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
           ('Facturación'
           ,NULL
           ,''
           ,'Menu'
           ,1
           ,''
           ,'TRUE'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)



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
           ('Servicio al Cliente'
           ,NULL
           ,''
           ,'Menu'
           ,1
           ,''
           ,'TRUE'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)



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
           ('Ayuda'
           ,NULL
           ,''
           ,'Menu'
           ,1
           ,''
           ,'TRUE'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)



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
           ('Gestión'
           ,@IdComercial
           ,'Menu Gestion'
           ,'Menu Gestión'
           ,1
           ,''
           ,'TRUE'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)


declare @IdGestionComercial as int  = SCOPE_IDENTITY()  
set @IdGestionComercial = (select cm1.ModIdModule from CatModule cm1 where cm1.ModName = 'Gestión' and cm1.ModIdModuleParent = @IdComercial)




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
           ('Socios de Negocio'
           ,@IdGestionComercial
           ,'FrmBusinessPartner'
           ,'Modulo de Gestión de Socios de Negocio'
           ,1
           ,''
           ,'TRUE'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)



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
           ('Punto de Visita'
           ,@IdGestionComercial
           ,'FrmVisitPointClient'
           ,'Modulo de Gestión de Puntos de Servicio'
           ,2
           ,''
           ,'TRUE'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)

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
           ('Tarifas'
           ,@IdGestionComercial
           ,'FrmRate'
           ,'Modulo de Gestión de Tarifas'
           ,3
           ,''
           ,'TRUE'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)


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
           ('Express Centers'
           ,@IdGestionComercial
           ,'FrmExpressCenters'
           ,'Modulo de Gestión de Express Centers'
           ,4
           ,''
           ,'TRUE'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)

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
           ('Usuarios'
           ,@IdGestionComercial
           ,'FrmMgtCommercialUsers'
           ,'Modulo de Gestión Comercial de Usuarios '
           ,5
           ,''
           ,'TRUE'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)

select * from CatModule  mdl
where mdl.ModIdModule > @ultimo
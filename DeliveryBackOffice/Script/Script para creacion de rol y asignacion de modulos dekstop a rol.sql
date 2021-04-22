USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[CatRol]
           ([RolIdSystem]
           ,[RolName]
           ,[RolDescription]
           ,[RolAdminBrothers]
           ,[RolAdminClient]
           ,[RolRowStatus]
           ,[RolTokenCreated]
           ,[RolDateCreated]
           ,[RolokenUpdated]
           ,[RolDateUpdated])
     VALUES
           (2
           ,'Super Administrator HD'
           ,'Super Administrador Hermes Desktop'
           ,'TRUE'
           ,'TRUE'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO

declare @IdRol as int = SCOPE_IDENTITY()  
set @IdRol = (select top 1 rol.RolIdRol from CatRol rol where rol.RolName = 'Super Administrator HD' and rol.RolIdSystem = 2)

declare @IdModuleDesktop as int = (select top 1 mdl.ModIdModule from CatModule mdl where mdl.ModName = 'Delivery' AND MDL.ModDescription = 'Menu' and mdl.ModRowStatus = 'TRUE')

INSERT INTO [dbo].[RolByModuleBySystem]
           ([RmsIdRol]
           ,[RmsIdSystem]
           ,[RmsIdModule]
           ,[RmsRowStatus]
           ,[RmsTokenCreated]
           ,[RmsDateCreated]
           ,[RmsTokenUpdated]
           ,[RmsDateUpdated])
select @IdRol, 2, mdl.ModIdModule, mdl.ModRowStatus, 'SYS-ERAMIREZ' , GETDATE(), NULL , NULL from CatModule mdl
where mdl.ModIdModule >= @IdModuleDesktop 

SELECT * FROM CatRol WHERE RolIdRol = @IdRol and  RolIdSystem = 2

SELECT * FROM RolByModuleBySystem RMS WHERE RMS.RmsIdRol = @IdRol


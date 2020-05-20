

--SELECT * FROM DenariusUser_Dev.DBO.LGN_ModuleByRolBySystem MRS JOIN DenariusUser_Dev.DBO.LGN_Module MDL ON MRS.MRS_IdModule = MDL.MDL_IdModule
--WHERE MRS.MRS_IdRol= 575
--ORDER BY MRS.MRS_IdModule 

--SELECT *  FROM DenariusUser_Dev.DBO.LGN_Module MDL WITH (nolock)
--where MDL.MDL_AUTHPATH LIKE '%/corporate/%'

DECLARE @IdNewSystem as int 
set @IdNewSystem  = -1;

SET @IdNewSystem = (SELECT top 1 sistema.SYS_IdSystem FROM DenariusUser_Dev.DBO.LGN_System sistema with (nolock) order by sistema.SYS_IdSystem DESC)
 

DECLARE @IdRolAdmin as int
SET @IdRolAdmin = -1;

SET @IdRolAdmin = (SELECT TOP 1 ROL.LGN_IdRol FROM DenariusUser_Dev.DBO.LGN_Rol ROL WITH (NOLOCK) WHERE ROL.LGN_Name = 'SUPER ADMINISTRADOR FORZA DELIVERY' ORDER BY 1 DESC  )



DECLARE @IdModule as int
set @IdModule= -1;

set @IdModule = (SELECT TOP 1 mdl.MDL_IdModule + 1  FROM DenariusUser_Dev.DBO.LGN_Module MDL WITH  (NOLOCK) ORDER BY MDL.MDL_IdModule DESC )

--@IdModule Home
INSERT INTO [DenariusUser_Dev].[dbo].[LGN_Module]
           ([MDL_IdModule]
           ,[MDL_Name]
           ,[MDL_IdModuleParent]
           ,[MDL_AuthPath]
           ,[MDL_Description]
           ,[MDL_Order]
           ,[MDL_Metadata]
           ,[MDL_Visible]
           ,[MDL_KeyWord])
     VALUES
           (@IdModule
           ,'Escritorio'
           ,NULL
           ,'/tracking/home.aspx'
           ,'Ir a escritorio forza delivery'
           ,1
           ,'hi hi-home'
           ,'TRUE'
           ,'HOME')

DECLARE @IdModule2 as int
set @IdModule2= -1;
set @IdModule2 = @IdModule + 1; 

--@IdModule Change Password
INSERT INTO [DenariusUser_Dev].[dbo].[LGN_Module]
           ([MDL_IdModule]
           ,[MDL_Name]
           ,[MDL_IdModuleParent]
           ,[MDL_AuthPath]
           ,[MDL_Description]
           ,[MDL_Order]
           ,[MDL_Metadata]
           ,[MDL_Visible]
           ,[MDL_KeyWord])
     VALUES
           (@IdModule2
           ,'Cambiar Contraseña'
           ,NULL
           ,'/tracking/changepassword.aspx'
           ,'Cambiar contraseña de usuario forza delivery'
           ,7
           ,NULL
           ,'FALSE'
           ,'PASSWORD')

SELECT *  FROM DenariusUser_Dev.DBO.LGN_Module MDL WITH (nolock)
where MDL.MDL_AUTHPATH LIKE '%/tracking/%'


INSERT INTO DenariusUser_Dev.[dbo].[LGN_ModuleByRolBySystem]
           ([MRS_IdModule]
           ,[MRS_IdRol]
           ,[MRS_IdSystem]
           ,[MRS_ExecPermission])
     VALUES
           (@IdModule
           ,@IdRolAdmin
           ,@IdNewSystem
           ,'TRUE')


INSERT INTO DenariusUser_Dev.[dbo].[LGN_ModuleByRolBySystem]
           ([MRS_IdModule]
           ,[MRS_IdRol]
           ,[MRS_IdSystem]
           ,[MRS_ExecPermission])
     VALUES
           (@IdModule2
           ,@IdRolAdmin
           ,@IdNewSystem
           ,'TRUE')



DECLARE @IdRolMonitoreo as int
SET @IdRolMonitoreo = -1;

SET @IdRolMonitoreo = (SELECT TOP 1 ROL.LGN_IdRol FROM DenariusUser_Dev.DBO.LGN_Rol ROL WITH (NOLOCK) WHERE ROL.LGN_Name = 'MONITOREO TRACKING FORZA DELIVERY' ORDER BY 1 DESC  )


INSERT INTO DenariusUser_Dev.[dbo].[LGN_ModuleByRolBySystem]
           ([MRS_IdModule]
           ,[MRS_IdRol]
           ,[MRS_IdSystem]
           ,[MRS_ExecPermission])
     VALUES
           (@IdModule
           ,@IdRolMonitoreo
           ,@IdNewSystem
           ,'TRUE')


INSERT INTO DenariusUser_Dev.[dbo].[LGN_ModuleByRolBySystem]
           ([MRS_IdModule]
           ,[MRS_IdRol]
           ,[MRS_IdSystem]
           ,[MRS_ExecPermission])
     VALUES
           (@IdModule2
           ,@IdRolMonitoreo
           ,@IdNewSystem
           ,'TRUE')


SELECT * FROM DenariusUser_Dev.DBO.LGN_ModuleByRolBySystem MRS JOIN DenariusUser_Dev.DBO.LGN_Module MDL ON MRS.MRS_IdModule = MDL.MDL_IdModule
WHERE MRS.MRS_IdRol= @IdRolAdmin
ORDER BY MRS.MRS_IdModule 


SELECT * FROM DenariusUser_Dev.DBO.LGN_ModuleByRolBySystem MRS JOIN DenariusUser_Dev.DBO.LGN_Module MDL ON MRS.MRS_IdModule = MDL.MDL_IdModule
WHERE MRS.MRS_IdRol= @IdRolMonitoreo
ORDER BY MRS.MRS_IdModule 
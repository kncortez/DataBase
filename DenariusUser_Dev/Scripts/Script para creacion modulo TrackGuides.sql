USE [DenariusUser_Dev]
GO
declare @idModule as int = -1
set @idModule = (select top 1 MDL_IdModule from LGN_Module  order by 1 desc )

INSERT INTO [dbo].[LGN_Module]
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
           (@idModule+1
           ,'Rastreo de Guias'
           ,NULL
           ,'/TrackGuides.aspx'
           ,'Rastreo de Guias Transporte Forza Delivery'
           ,1
           ,'fa fa-eye'
           ,'true'
           ,'FDTrackGuides')
GO

select top 1 * from LGN_Module  order by 1 desc

--SELECT TOP (1000) [RUR_IdRol]
--      ,[RUR_IdUser]
--      ,[RUR_IdStation]
--      ,[RUR_IdCountry]
--      ,[RUR_Username]
--      ,[RUR_Status]
--  FROM [DenariusUser_Dev].[dbo].[LGN_RolByUserByRegion] rur 
--  join DenariusUser_Dev.dbo.LGN_Rol rol on rur.RUR_IdRol = rol.LGN_IdRol
--  and rol.LGN_IdSystem = 12
--  where rur_username = 'edwin.ramirez'
  
  USE [DenariusUser_Dev]
GO

INSERT INTO [dbo].[LGN_ModuleByRolBySystem]
           ([MRS_IdModule]
           ,[MRS_IdRol]
           ,[MRS_IdSystem]
           ,[MRS_ExecPermission])
     VALUES
           (558
           ,1864
           ,12
           ,'true')
GO

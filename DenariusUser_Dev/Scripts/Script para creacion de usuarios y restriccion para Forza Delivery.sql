USE [DenariusUser_Dev]
GO

DECLARE @IdUser as nvarchar(50) 
declare @UserName as nvarchar(50)

set @IdUser = '100088'
set @UserName = 'edwin.ramirez'


DECLARE @IdNewSystem as int 
set @IdNewSystem  = -1;

SET @IdNewSystem = (SELECT top 1 sistema.SYS_IdSystem FROM DenariusUser_Dev.DBO.LGN_System sistema with (nolock) order by sistema.SYS_IdSystem DESC)
 

DECLARE @IdRolAdmin as int
SET @IdRolAdmin = -1;

SET @IdRolAdmin = (SELECT TOP 1 ROL.LGN_IdRol FROM DenariusUser_Dev.DBO.LGN_Rol ROL WITH (NOLOCK) WHERE ROL.LGN_Name = 'SUPER ADMINISTRADOR FORZA DELIVERY' ORDER BY 1 DESC  )



INSERT INTO DenariusUser_Dev.[dbo].[LGN_RolByUserByRegion]
           ([RUR_IdRol]
           ,[RUR_IdUser]
           ,[RUR_IdStation]
           ,[RUR_IdCountry]
           ,[RUR_Username]
           ,[RUR_Status])
     VALUES
           (@IdRolAdmin
           ,100088
           ,-1
           ,'GT'
           ,'edwin.ramirez'
           ,'TRUE')

INSERT INTO DenariusUser_Dev.[dbo].[LGN_Restriction]
           ([RST_IdUser]
           ,[RST_Username]
           ,[RST_IdSystem]
           ,[RST_AccessRetries]
           ,[RST_Status]
           ,[RST_Retries]
           ,[LGN_CreationDate]
           ,[LGN_CreationToken]
           ,[LGN_OperationDate]
           ,[LGN_OperationToken])
     VALUES
           (
		   @IdUser
           ,@UserName
           ,@IdNewSystem
           , 10
           ,'ACTIVE'
           ,0
           ,GETDATE()
           ,'SYS-ERAMIREZ'
           ,NULL
           ,NULL
		   )


select * from  DenariusUser_Dev.[dbo].[LGN_RolByUserByRegion] rur with (nolock)
where rur.RUR_IdUser = @IdUser 
and rur.RUR_Username = @UserName 
and rur.RUR_IdRol = @IdRolAdmin

select * from  DenariusUser_Dev.[dbo].[LGN_Restriction] res with (nolock)
where res.RST_IdUser = @IdUser 
and res.RST_Username = @UserName 
and res.RST_IdSystem= @IdNewSystem

GO



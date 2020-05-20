DECLARE @IdNewSystem as int 
set @IdNewSystem  = -1;

SET @IdNewSystem = (SELECT top 1 sistema.SYS_IdSystem FROM DenariusUser_Dev.DBO.LGN_System sistema with (nolock) order by sistema.SYS_IdSystem DESC)

DECLARE @IdRolAdmin as int
SET @IdRolAdmin = -1;

SET @IdRolAdmin = (SELECT TOP 1 ROL.LGN_IdRol FROM DenariusUser_Dev.DBO.LGN_Rol ROL WITH (NOLOCK) ORDER BY 1 DESC )

IF (@IdNewSystem > 0 AND @IdRolAdmin > 0 ) 
BEGIN 
		INSERT INTO [dbo].[LGN_Rol]
				   ([LGN_Name]
				   ,[LGN_Description]
				   ,[LGN_StatusRol]
				   ,[LGN_IdSystem]
				   ,[LGN_CreationDate]
				   ,[LGN_CreationToken]
				   ,[LGN_AdminClients]
				   ,[LGN_AdminBrothers]
				   ,[LGN_AdminHierarchicaly])
			 VALUES
				   ('MONITOREO TRACKING FORZA DELIVERY'
				   ,'MONITOREO FORZA DELIVERY'
				   ,'TRUE'
				   ,@IdNewSystem
				   ,GETDATE()
				   ,'SYS-ERAMIREZ'
				   ,'FALSE'
				   ,'FALSE'
				   ,'FALSE')

		DECLARE @IdNewRol as int
		SET @IdNewRol = (SELECT TOP 1 ROL.LGN_IdRol FROM DenariusUser_Dev.DBO.LGN_Rol ROL WITH (NOLOCK) ORDER BY 1 DESC )

		
		INSERT INTO [DenariusUser_Dev].dbo.[LGN_RolbyRol]
				   ([RBR_RolAdmin]
				   ,[RBR_Rol])
			 VALUES
				   (
				   @IdRolAdmin
				   ,@IdNewRol
				   )

		select * from [DenariusUser_Dev].dbo.[LGN_RolbyRol] rolbyrol WITH (NOLOCK)
		WHERE rolbyrol.RBR_RolAdmin = @IdRolAdmin

END 
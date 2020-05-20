DECLARE @IdNewSystem as int 
set @IdNewSystem  = -1;

SET @IdNewSystem = (SELECT top 1 sistema.SYS_IdSystem FROM DenariusUser_Dev.DBO.LGN_System sistema with (nolock) order by sistema.SYS_IdSystem DESC)


if (@IdNewSystem > 0 )
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
           ('SUPER ADMINISTRADOR FORZA DELIVERY'
           ,'SADMIN FORZA DELIVERY'
           ,'TRUE'
           ,@IdNewSystem
           ,GETDATE()
           ,'SYS-ERAMIREZ'
           ,'TRUE'
           ,'FALSE'
           ,'TRUE')


END 

SELECT @IdNewSystem 'IdNewSystem'
SELECT top 1 * FROM DenariusUser_Dev.DBO.LGN_Rol ROL WITH (NOLOCK) 
order by 1 desc 
--WHERE ROL.LGN_IdSystem = @IdNewSystem 
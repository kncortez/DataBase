/*Script para creacion de un nuevo sistema*/
  DECLARE @IdSystem as int  
  set @IdSystem = -1;
  
select top 1 @IdSystem  = sistema.SYS_IdSystem  FROM [DenariusUser_Dev].[dbo].[LGN_System] sistema with(nolock) 
  order by sistema.SYS_IdSystem desc 

  declare @newsystemid as int
  set @newsystemid  = -1;
  set @newsystemid = @IdSystem + 1;

if   (@newsystemid > 0 )
begin 
	INSERT INTO [dbo].[LGN_System]
           ([SYS_IdSystem]
           ,[SYS_SystemName]
           ,[SYS_Platform]
           ,[SYS_Description]
           ,[SYS_Status]
           ,[SYS_TokenInsertId]
           ,[SYS_TokenInsertDatetime]
           ,[SYS_TokenUpdateId]
           ,[SYS_TokenUpdateDateTime])
     VALUES
           ( @newsystemid 
            ,'Forza Delivery Express'
            ,'Web'
           ,'Tracking Web Forza Delivery'
            ,'TRUE'
		   ,'SYS-ERAMIREZ'
            ,GETDATE()
           ,NULL
           ,NULL)
	
end 

SELECT * FROM [DenariusUser_Dev].[dbo].[LGN_System] WITH(NOLOCK)
WHERE SYS_IdSystem = @newsystemid
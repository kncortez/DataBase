USE [DenariusUser_Dev]
GO

DECLARE @IdSystem as int 
set @IdSystem = (select top 1 SYS_IdSystem from [dbo].[LGN_System] order by SYS_IdSystem desc )

--print   @IdSystem

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
           (@IdSystem+1
           ,'Forza Ecommerce Engine'
           ,'API_WebService'
           ,'Web Services API Forza Delivery'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)

set @IdSystem = (select top 1 SYS_IdSystem from [dbo].[LGN_System] order by SYS_IdSystem desc )

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
           (@IdSystem+1
           ,'Forza EPayment BAC'
           ,'API_WebService'
           ,'Web Services API Forza Payment BAC'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)



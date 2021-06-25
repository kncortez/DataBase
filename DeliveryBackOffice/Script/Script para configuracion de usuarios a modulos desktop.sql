USE [DeliveryBackOffice]
GO

--SELECT * FROM RegisterUser RUS
--WHERE RUS.UsrEmail = 'edwin.ramirez.gt@gmail.com'

INSERT INTO [dbo].[InternalUser]
           ([IdUser]
           ,[Username]
           ,[IdEmployee]
           ,[RegisterUserID]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           (100088
           ,'edwin.ramirez'
           ,1
           ,21
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO


--SELECT * FROM DenariusDesktop_Dev.DBO.LGT_INF_Employee

INSERT INTO [dbo].[UserSystemRestriction]
           ([UstIdUser]
           ,[UstIdSystem]
           ,[UstAccessRetries]
           ,[UstRetries]
           ,[UstStatus]
           ,[UstRowStatus]
           ,[UstTokenCreated]
           ,[UstDateCreated]
           ,[UstOperationDate])
     VALUES
           (21
           ,2
           ,5
           ,0
           ,'ACTIVE'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,GETDATE()
		   )
GO


USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[RolByUserBySystem]
           ([RusIdRol]
           ,[RusIdSystem]
           ,[RusIdUser]
           ,[RusRowStatus]
           ,[RusTokenCreated]
           ,[RusDateCreated]
           ,[RusTokenUpdated]
           ,[RusDateUpdated])
     VALUES
           (3
           ,2
           ,21
           ,'true'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO


INSERT INTO [dbo].[RolByUserBySystem]
           ([RusIdRol]
           ,[RusIdSystem]
           ,[RusIdUser]
           ,[RusRowStatus]
           ,[RusTokenCreated]
           ,[RusDateCreated]
           ,[RusTokenUpdated]
           ,[RusDateUpdated])
     VALUES
           (3
           ,2
           ,9
           ,'true'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO





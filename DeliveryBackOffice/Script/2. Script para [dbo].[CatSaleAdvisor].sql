USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[CatSaleAdvisor]
           ([SaleAdvisorCode]
           ,[SaleAdvisorDescription]
           ,[EmployeID]
           ,[SAPSellerID]
           ,[CountryID]
           ,[SaleAdvisorStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('SA-103206'
           ,'CELESTE MARIANELY ROSALES MARROQUIN'
           ,7271
           ,NULL
           ,'GT'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO

INSERT INTO [dbo].[CatSaleAdvisor]
           ([SaleAdvisorCode]
           ,[SaleAdvisorDescription]
           ,[EmployeID]
           ,[SAPSellerID]
           ,[CountryID]
           ,[SaleAdvisorStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('SA-104917'
           ,'GUILLERMO ALFREDO LOPEZ LOPEZ'
           ,12776
           ,NULL
           ,'GT'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO

INSERT INTO [dbo].[CatSaleAdvisor]
           ([SaleAdvisorCode]
           ,[SaleAdvisorDescription]
           ,[EmployeID]
           ,[SAPSellerID]
           ,[CountryID]
           ,[SaleAdvisorStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('SA-105085'
           ,'HERBERT ADOLFO FLORES VELASQUEZ'
           ,13004
           ,NULL
           ,'GT'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO

INSERT INTO [dbo].[CatSaleAdvisor]
           ([SaleAdvisorCode]
           ,[SaleAdvisorDescription]
           ,[EmployeID]
           ,[SAPSellerID]
           ,[CountryID]
           ,[SaleAdvisorStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('SA-105175'
           ,'ANA CRISTINA ARRIVILLAGA'
           ,13136
           ,NULL
           ,'GT'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO

INSERT INTO [dbo].[CatSaleAdvisor]
           ([SaleAdvisorCode]
           ,[SaleAdvisorDescription]
           ,[EmployeID]
           ,[SAPSellerID]
           ,[CountryID]
           ,[SaleAdvisorStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('SA-105553'
           ,'MERY YOLANDA MAZARIEGOS AGUILAR'
           ,13824
           ,NULL
           ,'GT'
           ,'TRUE'
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO
select * from dbo.[CatSaleAdvisor]
--DBCC CHECKIDENT ( [CatSaleAdvisor], RESEED, 0); 

--SELECT * FROM DenariusDesktop_Dev.DBO.LGT_INF_Employee
--WHERE IdDepartment  =302
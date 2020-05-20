USE [DenariusCorporate_Dev]
GO

INSERT INTO [dbo].[PRM_Companies]
           ([CNY_CompanyName]
           ,[CNY_CardCode]
           ,[CNY_Description]
           ,[CNY_Country]
           ,[CNY_Status]
           ,[CNY_TokenInsertId]
           ,[CNY_TokenInsertDatetime]
           ,[CNY_TokenUpdateId]
           ,[CNY_TokenUpdateDatetime]
           ,[CNY_LogoNameInDenariusImageFile])
     VALUES
           ('FORZA DELIVERY EXPRESS'
           ,'C11527'
           ,'TRANSPORTE Y LOGISTICA DE PAQUETES'
           ,'GT'
           ,1
           ,'SYS-ERAMIREZ'
           ,GETDATE()
           ,NULL
           , NULL
           ,'logoForzaDelivery.jpg'
		   )

SELECT TOP 3 * FROM [dbo].[PRM_Companies]  ORDER BY 1 DESC 


GO



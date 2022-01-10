USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[CatRol]
           ([RolIdSystem]
           ,[RolName]
           ,[RolDescription]
           ,[RolAdminBrothers]
           ,[RolAdminClient]
           ,[RolRowStatus]
           ,[RolTokenCreated]
           ,[RolDateCreated]
           ,[RolokenUpdated]
           ,[RolDateUpdated]
           ,[RolAdminInternal])
     VALUES
           (
		   1
		   ,'Concesionario'
           ,'Operador concesionario'
           ,NULL
           ,0
           ,1
           ,'SYS-MESPINOZA'
           ,GETDATE()
           ,NULL
           ,NULL
           ,NULL
		   )
GO



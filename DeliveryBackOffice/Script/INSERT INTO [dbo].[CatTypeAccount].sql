USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[CatTypeAccount]
           ([TacShortName]
           ,[TacName]
           ,[TacDescription]
           ,[TacRowStatus]
           ,[TacTokenCreated]
           ,[TacDateCreated]
           ,[TacTokenUpdated]
           ,[TacDateUpdated])
     VALUES
	 (
           'CNC'
           ,'Concesionario'
           ,'Cuentas concesionarios'
           ,1
           ,'SYS-MESPINOZA'
           ,GETDATE()
           ,NULL
           ,NULL
	)
GO



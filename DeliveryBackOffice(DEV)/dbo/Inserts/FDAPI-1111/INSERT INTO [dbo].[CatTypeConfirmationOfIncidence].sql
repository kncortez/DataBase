USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[CatTypeConfirmationOfIncidence]
           ([Name]
           ,[Description]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('Incidencia en Ruta'
           ,'No cumple con validación de rango o no confirmado por cliente.'
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)
GO

INSERT INTO [dbo].[CatTypeConfirmationOfIncidence]
           ([Name]
           ,[Description]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('Visita Fallida'
           ,'Cumple con validación de rango y/o confirmado por cliente.'
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)
GO


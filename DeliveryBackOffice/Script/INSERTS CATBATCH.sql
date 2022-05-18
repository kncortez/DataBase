/*
INSERTAR LOS REGISTROS PARA LOS TIPOS DE LOTES QUE EXISTEN
*/

USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[CatBatch]
           ([CatName]
           ,[CatDescription]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('COD'
           ,'LOTE DE COD'
           ,1
           ,'SYS-MJIMENEZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO

INSERT INTO [dbo].[CatBatch]
           ([CatName]
           ,[CatDescription]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('RECOLECCION'
           ,'LOTE DE PAGOS EN RECOLECCION'
           ,1
           ,'SYS-MJIMENEZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO

INSERT INTO [dbo].[CatBatch]
           ([CatName]
           ,[CatDescription]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('COLLECT'
           ,'LOTE DE PAGOS EN DESTINO (COLLECT)'
           ,1
           ,'SYS-MJIMENEZ'
           ,GETDATE()
           ,NULL
           ,NULL)
GO
USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[CatInvoiceType]
           ([Name]
           ,[Description]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('Envío','Facturación de envíos',1,'SYS-OMORALES',GETDATE(),NULL,NULL),
		   ('Comisión COD','Facturación de comisiones COD',1,'SYS-OMORALES',GETDATE(),NULL,NULL),
		   ('Rebajo de envío','Facturación de rebajo de envío',1,'SYS-OMORALES',GETDATE(),NULL,NULL),
		   ('Otros','Facturación otros/varios',1,'SYS-OMORALES',GETDATE(),NULL,NULL)
GO



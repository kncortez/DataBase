USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[Unit]
           ([UnitName]
           ,[Prefix]
           ,[TypeUnit]
           ,[UnitStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
SELECT 'Libra','Lb','mass', 'TRUE','SYS-ERAMIREZ', GETDATE(), NULL, NULL
UNION 
SELECT 'Kilogramo','Kg','mass', 'TRUE','SYS-ERAMIREZ', GETDATE(), NULL, NULL
UNION 
SELECT 'Caja','Box','package', 'TRUE','SYS-ERAMIREZ', GETDATE(), NULL, NULL
UNION
SELECT 'Kilometro','Km','lenght', 'TRUE','SYS-ERAMIREZ', GETDATE(), NULL, NULL
GO

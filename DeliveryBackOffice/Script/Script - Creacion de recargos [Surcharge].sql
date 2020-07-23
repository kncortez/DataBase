USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[Surcharge]([SurchargeName],[PercentValue],[SuchargeStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
SELECT 'ESPECIAL', 20, 'TRUE', 'SYS-ERAMIREZ', GETDATE(), NULL, NULL
UNION
SELECT 'FRAGIL', 3, 'TRUE', 'SYS-ERAMIREZ', GETDATE(), NULL, NULL
UNION
SELECT 'ASEGURADO', 1, 'TRUE', 'SYS-ERAMIREZ', GETDATE(), NULL, NULL


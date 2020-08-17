USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[SpecialDiscount]([DiscountName],[PercentValue],[SpecialDiscountStatus],[DateExpire],[IdCustomer],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
SELECT 'SPRING 2020', 4.25, 'FALSE', '2020-04-04', NULL, 'SYS-ERAMIREZ', GETDATE(), NULL, NULL
UNION
SELECT 'COVID-19', 0.05, 'TRUE', '2020-08-31', NULL,'SYS-ERAMIREZ', GETDATE(), NULL, NULL
GO

--SELECT * FROM [SpecialDiscount]

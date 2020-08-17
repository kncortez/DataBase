USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[DimensionalParameter]([IdUnit],[ByRange],[ByUnity],[MinimunValue],[MaximunValue],[DimensionalStatus],[IdCountry],[TokenCreated],[DateCreated],[TokenUpdated],[UpdatedCreated])
SELECT 4, 'TRUE', 'FALSE', 1, 10, 'TRUE', 'GT', 'SYS-ERAMIREZ', GETDATE(), NULL, NULL
UNION
SELECT 4, 'TRUE', 'FALSE', 11, 20, 'TRUE', 'GT', 'SYS-ERAMIREZ', GETDATE(), NULL, NULL
UNION
SELECT 4, 'TRUE', 'FALSE', 21, 30, 'TRUE', 'GT', 'SYS-ERAMIREZ', GETDATE(), NULL, NULL
UNION
SELECT 4, 'TRUE', 'FALSE', 31, 40, 'TRUE', 'GT', 'SYS-ERAMIREZ', GETDATE(), NULL, NULL
UNION
SELECT 4, 'TRUE', 'FALSE', 41, 50, 'TRUE', 'GT', 'SYS-ERAMIREZ', GETDATE(), NULL, NULL
UNION
SELECT 4, 'TRUE', 'FALSE', 51, -1, 'TRUE', 'GT', 'SYS-ERAMIREZ', GETDATE(), NULL, NULL

GO


SELECT rangos.IdDimensional ,uni.Prefix, rangos.MinimunValue, rangos.MaximunValue , rangos.IdCountry
FROM [DimensionalParameter] rangos join Unit uni on rangos.IdUnit = uni.IdUnit
and rangos.DimensionalStatus = 'TRUE'
and rangos.ByRange = 'TRUE'
AND RANGOS.ByUnity = 'FALSE'
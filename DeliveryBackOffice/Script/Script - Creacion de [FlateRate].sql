USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[FlateRate]([IdDimensional],[IdSegmentArea],[ExceededRate],[PriceRate],[AdicionalCostPerUnit],[IdCurrency],[IdCountry],[FlatRateStatus],[IdRateCategory],[DateFromValid],[DateExpired],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
SELECT 1 'IdDimensional', 1 'IdSegmentArea', 'FALSE' 'ExceededRate',  30 'PriceRate', NULL 'AdicionalCostPerUnit', 1 'IdCurrency', 'GT' [IdCountry],  'TRUE' 'FlatRateStatus',  1 [IdRateCategory], '2020-07-01' [DateFromValid], '2022-07-31' [DateExpired], 'SYS-ERAMIREZ' [TokenCreated], GETDATE() [DateCreated], NULL [TokenUpdated], NULL [DateUpdated]

INSERT INTO [dbo].[FlateRate]([IdDimensional],[IdSegmentArea],[ExceededRate],[PriceRate],[AdicionalCostPerUnit],[IdCurrency],[IdCountry],[FlatRateStatus],[IdRateCategory],[DateFromValid],[DateExpired],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
SELECT 1 'IdDimensional', 2 'IdSegmentArea', 'FALSE' 'ExceededRate',  45 'PriceRate', NULL 'AdicionalCostPerUnit', 1 'IdCurrency', 'GT' [IdCountry],  'TRUE' 'FlatRateStatus',  1 [IdRateCategory], '2020-07-01' [DateFromValid], '2022-07-31' [DateExpired], 'SYS-ERAMIREZ' [TokenCreated], GETDATE() [DateCreated], NULL [TokenUpdated], NULL [DateUpdated]

INSERT INTO [dbo].[FlateRate]([IdDimensional],[IdSegmentArea],[ExceededRate],[PriceRate],[AdicionalCostPerUnit],[IdCurrency],[IdCountry],[FlatRateStatus],[IdRateCategory],[DateFromValid],[DateExpired],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
SELECT 1 'IdDimensional', 3 'IdSegmentArea', 'FALSE' 'ExceededRate',  51 'PriceRate', NULL 'AdicionalCostPerUnit', 1 'IdCurrency', 'GT' [IdCountry],  'TRUE' 'FlatRateStatus',  1 [IdRateCategory], '2020-07-01' [DateFromValid], '2022-07-31' [DateExpired], 'SYS-ERAMIREZ' [TokenCreated], GETDATE() [DateCreated], NULL [TokenUpdated], NULL [DateUpdated]

INSERT INTO [dbo].[FlateRate]([IdDimensional],[IdSegmentArea],[ExceededRate],[PriceRate],[AdicionalCostPerUnit],[IdCurrency],[IdCountry],[FlatRateStatus],[IdRateCategory],[DateFromValid],[DateExpired],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
SELECT 1 'IdDimensional', 4 'IdSegmentArea', 'FALSE' 'ExceededRate',  56 'PriceRate', NULL 'AdicionalCostPerUnit', 1 'IdCurrency', 'GT' [IdCountry],  'TRUE' 'FlatRateStatus',  1 [IdRateCategory], '2020-07-01' [DateFromValid], '2022-07-31' [DateExpired], 'SYS-ERAMIREZ' [TokenCreated], GETDATE() [DateCreated], NULL [TokenUpdated], NULL [DateUpdated]

INSERT INTO [dbo].[FlateRate]([IdDimensional],[IdSegmentArea],[ExceededRate],[PriceRate],[AdicionalCostPerUnit],[IdCurrency],[IdCountry],[FlatRateStatus],[IdRateCategory],[DateFromValid],[DateExpired],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
SELECT 1 'IdDimensional', 5 'IdSegmentArea', 'FALSE' 'ExceededRate',  65 'PriceRate', NULL 'AdicionalCostPerUnit', 1 'IdCurrency', 'GT' [IdCountry],  'TRUE' 'FlatRateStatus',  1 [IdRateCategory], '2020-07-01' [DateFromValid], '2022-07-31' [DateExpired], 'SYS-ERAMIREZ' [TokenCreated], GETDATE() [DateCreated], NULL [TokenUpdated], NULL [DateUpdated]

INSERT INTO [dbo].[FlateRate]([IdDimensional],[IdSegmentArea],[ExceededRate],[PriceRate],[AdicionalCostPerUnit],[IdCurrency],[IdCountry],[FlatRateStatus],[IdRateCategory],[DateFromValid],[DateExpired],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
SELECT 2 'IdDimensional', 1 'IdSegmentArea', 'FALSE' 'ExceededRate',  33 'PriceRate', NULL 'AdicionalCostPerUnit', 1 'IdCurrency', 'GT' [IdCountry],  'TRUE' 'FlatRateStatus',  1 [IdRateCategory], '2020-07-01' [DateFromValid], '2022-07-31' [DateExpired], 'SYS-ERAMIREZ' [TokenCreated], GETDATE() [DateCreated], NULL [TokenUpdated], NULL [DateUpdated]

INSERT INTO [dbo].[FlateRate]([IdDimensional],[IdSegmentArea],[ExceededRate],[PriceRate],[AdicionalCostPerUnit],[IdCurrency],[IdCountry],[FlatRateStatus],[IdRateCategory],[DateFromValid],[DateExpired],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
SELECT 2 'IdDimensional', 2 'IdSegmentArea', 'FALSE' 'ExceededRate',  48 'PriceRate', NULL 'AdicionalCostPerUnit', 1 'IdCurrency', 'GT' [IdCountry],  'TRUE' 'FlatRateStatus',  1 [IdRateCategory], '2020-07-01' [DateFromValid], '2022-07-31' [DateExpired], 'SYS-ERAMIREZ' [TokenCreated], GETDATE() [DateCreated], NULL [TokenUpdated], NULL [DateUpdated]

INSERT INTO [dbo].[FlateRate]([IdDimensional],[IdSegmentArea],[ExceededRate],[PriceRate],[AdicionalCostPerUnit],[IdCurrency],[IdCountry],[FlatRateStatus],[IdRateCategory],[DateFromValid],[DateExpired],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
SELECT 2 'IdDimensional', 3 'IdSegmentArea', 'FALSE' 'ExceededRate',  53 'PriceRate', NULL 'AdicionalCostPerUnit', 1 'IdCurrency', 'GT' [IdCountry],  'TRUE' 'FlatRateStatus',  1 [IdRateCategory], '2020-07-01' [DateFromValid], '2022-07-31' [DateExpired], 'SYS-ERAMIREZ' [TokenCreated], GETDATE() [DateCreated], NULL [TokenUpdated], NULL [DateUpdated]

INSERT INTO [dbo].[FlateRate]([IdDimensional],[IdSegmentArea],[ExceededRate],[PriceRate],[AdicionalCostPerUnit],[IdCurrency],[IdCountry],[FlatRateStatus],[IdRateCategory],[DateFromValid],[DateExpired],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
SELECT 2 'IdDimensional', 4 'IdSegmentArea', 'FALSE' 'ExceededRate',  62 'PriceRate', NULL 'AdicionalCostPerUnit', 1 'IdCurrency', 'GT' [IdCountry],  'TRUE' 'FlatRateStatus',  1 [IdRateCategory], '2020-07-01' [DateFromValid], '2022-07-31' [DateExpired], 'SYS-ERAMIREZ' [TokenCreated], GETDATE() [DateCreated], NULL [TokenUpdated], NULL [DateUpdated]

INSERT INTO [dbo].[FlateRate]([IdDimensional],[IdSegmentArea],[ExceededRate],[PriceRate],[AdicionalCostPerUnit],[IdCurrency],[IdCountry],[FlatRateStatus],[IdRateCategory],[DateFromValid],[DateExpired],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
SELECT 2 'IdDimensional', 5 'IdSegmentArea', 'FALSE' 'ExceededRate',  69 'PriceRate', NULL 'AdicionalCostPerUnit', 1 'IdCurrency', 'GT' [IdCountry],  'TRUE' 'FlatRateStatus',  1 [IdRateCategory], '2020-07-01' [DateFromValid], '2022-07-31' [DateExpired], 'SYS-ERAMIREZ' [TokenCreated], GETDATE() [DateCreated], NULL [TokenUpdated], NULL [DateUpdated]

INSERT INTO [dbo].[FlateRate]([IdDimensional],[IdSegmentArea],[ExceededRate],[PriceRate],[AdicionalCostPerUnit],[IdCurrency],[IdCountry],[FlatRateStatus],[IdRateCategory],[DateFromValid],[DateExpired],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
SELECT 3 'IdDimensional', 1 'IdSegmentArea', 'FALSE' 'ExceededRate',  34 'PriceRate', NULL 'AdicionalCostPerUnit', 1 'IdCurrency', 'GT' [IdCountry],  'TRUE' 'FlatRateStatus',  1 [IdRateCategory], '2020-07-01' [DateFromValid], '2022-07-31' [DateExpired], 'SYS-ERAMIREZ' [TokenCreated], GETDATE() [DateCreated], NULL [TokenUpdated], NULL [DateUpdated]

INSERT INTO [dbo].[FlateRate]([IdDimensional],[IdSegmentArea],[ExceededRate],[PriceRate],[AdicionalCostPerUnit],[IdCurrency],[IdCountry],[FlatRateStatus],[IdRateCategory],[DateFromValid],[DateExpired],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
SELECT 3 'IdDimensional', 2 'IdSegmentArea', 'FALSE' 'ExceededRate',  51 'PriceRate', NULL 'AdicionalCostPerUnit', 1 'IdCurrency', 'GT' [IdCountry],  'TRUE' 'FlatRateStatus',  1 [IdRateCategory], '2020-07-01' [DateFromValid], '2022-07-31' [DateExpired], 'SYS-ERAMIREZ' [TokenCreated], GETDATE() [DateCreated], NULL [TokenUpdated], NULL [DateUpdated]

INSERT INTO [dbo].[FlateRate]([IdDimensional],[IdSegmentArea],[ExceededRate],[PriceRate],[AdicionalCostPerUnit],[IdCurrency],[IdCountry],[FlatRateStatus],[IdRateCategory],[DateFromValid],[DateExpired],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
SELECT 3 'IdDimensional', 3 'IdSegmentArea', 'FALSE' 'ExceededRate',  58 'PriceRate', NULL 'AdicionalCostPerUnit', 1 'IdCurrency', 'GT' [IdCountry],  'TRUE' 'FlatRateStatus',  1 [IdRateCategory], '2020-07-01' [DateFromValid], '2022-07-31' [DateExpired], 'SYS-ERAMIREZ' [TokenCreated], GETDATE() [DateCreated], NULL [TokenUpdated], NULL [DateUpdated]

INSERT INTO [dbo].[FlateRate]([IdDimensional],[IdSegmentArea],[ExceededRate],[PriceRate],[AdicionalCostPerUnit],[IdCurrency],[IdCountry],[FlatRateStatus],[IdRateCategory],[DateFromValid],[DateExpired],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
SELECT 3 'IdDimensional', 4 'IdSegmentArea', 'FALSE' 'ExceededRate',  65 'PriceRate', NULL 'AdicionalCostPerUnit', 1 'IdCurrency', 'GT' [IdCountry],  'TRUE' 'FlatRateStatus',  1 [IdRateCategory], '2020-07-01' [DateFromValid], '2022-07-31' [DateExpired], 'SYS-ERAMIREZ' [TokenCreated], GETDATE() [DateCreated], NULL [TokenUpdated], NULL [DateUpdated]

INSERT INTO [dbo].[FlateRate]([IdDimensional],[IdSegmentArea],[ExceededRate],[PriceRate],[AdicionalCostPerUnit],[IdCurrency],[IdCountry],[FlatRateStatus],[IdRateCategory],[DateFromValid],[DateExpired],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
SELECT 3 'IdDimensional', 5 'IdSegmentArea', 'FALSE' 'ExceededRate',  74 'PriceRate', NULL 'AdicionalCostPerUnit', 1 'IdCurrency', 'GT' [IdCountry],  'TRUE' 'FlatRateStatus',  1 [IdRateCategory], '2020-07-01' [DateFromValid], '2022-07-31' [DateExpired], 'SYS-ERAMIREZ' [TokenCreated], GETDATE() [DateCreated], NULL [TokenUpdated], NULL [DateUpdated]

INSERT INTO [dbo].[FlateRate]([IdDimensional],[IdSegmentArea],[ExceededRate],[PriceRate],[AdicionalCostPerUnit],[IdCurrency],[IdCountry],[FlatRateStatus],[IdRateCategory],[DateFromValid],[DateExpired],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
SELECT 4 'IdDimensional', 1 'IdSegmentArea', 'FALSE' 'ExceededRate',  36 'PriceRate', NULL 'AdicionalCostPerUnit', 1 'IdCurrency', 'GT' [IdCountry],  'TRUE' 'FlatRateStatus',  1 [IdRateCategory], '2020-07-01' [DateFromValid], '2022-07-31' [DateExpired], 'SYS-ERAMIREZ' [TokenCreated], GETDATE() [DateCreated], NULL [TokenUpdated], NULL [DateUpdated]

INSERT INTO [dbo].[FlateRate]([IdDimensional],[IdSegmentArea],[ExceededRate],[PriceRate],[AdicionalCostPerUnit],[IdCurrency],[IdCountry],[FlatRateStatus],[IdRateCategory],[DateFromValid],[DateExpired],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
SELECT 4 'IdDimensional', 2 'IdSegmentArea', 'FALSE' 'ExceededRate',  54 'PriceRate', NULL 'AdicionalCostPerUnit', 1 'IdCurrency', 'GT' [IdCountry],  'TRUE' 'FlatRateStatus',  1 [IdRateCategory], '2020-07-01' [DateFromValid], '2022-07-31' [DateExpired], 'SYS-ERAMIREZ' [TokenCreated], GETDATE() [DateCreated], NULL [TokenUpdated], NULL [DateUpdated]

INSERT INTO [dbo].[FlateRate]([IdDimensional],[IdSegmentArea],[ExceededRate],[PriceRate],[AdicionalCostPerUnit],[IdCurrency],[IdCountry],[FlatRateStatus],[IdRateCategory],[DateFromValid],[DateExpired],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
SELECT 4 'IdDimensional', 3 'IdSegmentArea', 'FALSE' 'ExceededRate',  63 'PriceRate', NULL 'AdicionalCostPerUnit', 1 'IdCurrency', 'GT' [IdCountry],  'TRUE' 'FlatRateStatus',  1 [IdRateCategory], '2020-07-01' [DateFromValid], '2022-07-31' [DateExpired], 'SYS-ERAMIREZ' [TokenCreated], GETDATE() [DateCreated], NULL [TokenUpdated], NULL [DateUpdated]

INSERT INTO [dbo].[FlateRate]([IdDimensional],[IdSegmentArea],[ExceededRate],[PriceRate],[AdicionalCostPerUnit],[IdCurrency],[IdCountry],[FlatRateStatus],[IdRateCategory],[DateFromValid],[DateExpired],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
SELECT 4 'IdDimensional', 4 'IdSegmentArea', 'FALSE' 'ExceededRate',  70 'PriceRate', NULL 'AdicionalCostPerUnit', 1 'IdCurrency', 'GT' [IdCountry],  'TRUE' 'FlatRateStatus',  1 [IdRateCategory], '2020-07-01' [DateFromValid], '2022-07-31' [DateExpired], 'SYS-ERAMIREZ' [TokenCreated], GETDATE() [DateCreated], NULL [TokenUpdated], NULL [DateUpdated]

INSERT INTO [dbo].[FlateRate]([IdDimensional],[IdSegmentArea],[ExceededRate],[PriceRate],[AdicionalCostPerUnit],[IdCurrency],[IdCountry],[FlatRateStatus],[IdRateCategory],[DateFromValid],[DateExpired],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
SELECT 4 'IdDimensional', 5 'IdSegmentArea', 'FALSE' 'ExceededRate',  78 'PriceRate', NULL 'AdicionalCostPerUnit', 1 'IdCurrency', 'GT' [IdCountry],  'TRUE' 'FlatRateStatus',  1 [IdRateCategory], '2020-07-01' [DateFromValid], '2022-07-31' [DateExpired], 'SYS-ERAMIREZ' [TokenCreated], GETDATE() [DateCreated], NULL [TokenUpdated], NULL [DateUpdated]

INSERT INTO [dbo].[FlateRate]([IdDimensional],[IdSegmentArea],[ExceededRate],[PriceRate],[AdicionalCostPerUnit],[IdCurrency],[IdCountry],[FlatRateStatus],[IdRateCategory],[DateFromValid],[DateExpired],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
SELECT 5 'IdDimensional', 1 'IdSegmentArea', 'FALSE' 'ExceededRate',  37 'PriceRate', NULL 'AdicionalCostPerUnit', 1 'IdCurrency', 'GT' [IdCountry],  'TRUE' 'FlatRateStatus',  1 [IdRateCategory], '2020-07-01' [DateFromValid], '2022-07-31' [DateExpired], 'SYS-ERAMIREZ' [TokenCreated], GETDATE() [DateCreated], NULL [TokenUpdated], NULL [DateUpdated]

INSERT INTO [dbo].[FlateRate]([IdDimensional],[IdSegmentArea],[ExceededRate],[PriceRate],[AdicionalCostPerUnit],[IdCurrency],[IdCountry],[FlatRateStatus],[IdRateCategory],[DateFromValid],[DateExpired],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
SELECT 5 'IdDimensional', 2 'IdSegmentArea', 'FALSE' 'ExceededRate',  56 'PriceRate', NULL 'AdicionalCostPerUnit', 1 'IdCurrency', 'GT' [IdCountry],  'TRUE' 'FlatRateStatus',  1 [IdRateCategory], '2020-07-01' [DateFromValid], '2022-07-31' [DateExpired], 'SYS-ERAMIREZ' [TokenCreated], GETDATE() [DateCreated], NULL [TokenUpdated], NULL [DateUpdated]

INSERT INTO [dbo].[FlateRate]([IdDimensional],[IdSegmentArea],[ExceededRate],[PriceRate],[AdicionalCostPerUnit],[IdCurrency],[IdCountry],[FlatRateStatus],[IdRateCategory],[DateFromValid],[DateExpired],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
SELECT 5 'IdDimensional', 3 'IdSegmentArea', 'FALSE' 'ExceededRate',  64 'PriceRate', NULL 'AdicionalCostPerUnit', 1 'IdCurrency', 'GT' [IdCountry],  'TRUE' 'FlatRateStatus',  1 [IdRateCategory], '2020-07-01' [DateFromValid], '2022-07-31' [DateExpired], 'SYS-ERAMIREZ' [TokenCreated], GETDATE() [DateCreated], NULL [TokenUpdated], NULL [DateUpdated]

INSERT INTO [dbo].[FlateRate]([IdDimensional],[IdSegmentArea],[ExceededRate],[PriceRate],[AdicionalCostPerUnit],[IdCurrency],[IdCountry],[FlatRateStatus],[IdRateCategory],[DateFromValid],[DateExpired],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
SELECT 5 'IdDimensional', 4 'IdSegmentArea', 'FALSE' 'ExceededRate',  75 'PriceRate', NULL 'AdicionalCostPerUnit', 1 'IdCurrency', 'GT' [IdCountry],  'TRUE' 'FlatRateStatus',  1 [IdRateCategory], '2020-07-01' [DateFromValid], '2022-07-31' [DateExpired], 'SYS-ERAMIREZ' [TokenCreated], GETDATE() [DateCreated], NULL [TokenUpdated], NULL [DateUpdated]

INSERT INTO [dbo].[FlateRate]([IdDimensional],[IdSegmentArea],[ExceededRate],[PriceRate],[AdicionalCostPerUnit],[IdCurrency],[IdCountry],[FlatRateStatus],[IdRateCategory],[DateFromValid],[DateExpired],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
SELECT 5 'IdDimensional', 5 'IdSegmentArea', 'FALSE' 'ExceededRate',  83 'PriceRate', NULL 'AdicionalCostPerUnit', 1 'IdCurrency', 'GT' [IdCountry],  'TRUE' 'FlatRateStatus',  1 [IdRateCategory], '2020-07-01' [DateFromValid], '2022-07-31' [DateExpired], 'SYS-ERAMIREZ' [TokenCreated], GETDATE() [DateCreated], NULL [TokenUpdated], NULL [DateUpdated]

INSERT INTO [dbo].[FlateRate]([IdDimensional],[IdSegmentArea],[ExceededRate],[PriceRate],[AdicionalCostPerUnit],[IdCurrency],[IdCountry],[FlatRateStatus],[IdRateCategory],[DateFromValid],[DateExpired],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
SELECT 6 'IdDimensional', 1 'IdSegmentArea', 'TRUE' 'ExceededRate',  37 'PriceRate', 1 'AdicionalCostPerUnit', 1 'IdCurrency', 'GT' [IdCountry],  'TRUE' 'FlatRateStatus',  1 [IdRateCategory], '2020-07-01' [DateFromValid], '2022-07-31' [DateExpired], 'SYS-ERAMIREZ' [TokenCreated], GETDATE() [DateCreated], NULL [TokenUpdated], NULL [DateUpdated]

INSERT INTO [dbo].[FlateRate]([IdDimensional],[IdSegmentArea],[ExceededRate],[PriceRate],[AdicionalCostPerUnit],[IdCurrency],[IdCountry],[FlatRateStatus],[IdRateCategory],[DateFromValid],[DateExpired],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
SELECT 6 'IdDimensional', 2 'IdSegmentArea', 'TRUE' 'ExceededRate',  56 'PriceRate', 1 'AdicionalCostPerUnit', 1 'IdCurrency', 'GT' [IdCountry],  'TRUE' 'FlatRateStatus',  1 [IdRateCategory], '2020-07-01' [DateFromValid], '2022-07-31' [DateExpired], 'SYS-ERAMIREZ' [TokenCreated], GETDATE() [DateCreated], NULL [TokenUpdated], NULL [DateUpdated]

INSERT INTO [dbo].[FlateRate]([IdDimensional],[IdSegmentArea],[ExceededRate],[PriceRate],[AdicionalCostPerUnit],[IdCurrency],[IdCountry],[FlatRateStatus],[IdRateCategory],[DateFromValid],[DateExpired],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
SELECT 6 'IdDimensional', 3 'IdSegmentArea', 'TRUE' 'ExceededRate',  64 'PriceRate', 1 'AdicionalCostPerUnit', 1 'IdCurrency', 'GT' [IdCountry],  'TRUE' 'FlatRateStatus',  1 [IdRateCategory], '2020-07-01' [DateFromValid], '2022-07-31' [DateExpired], 'SYS-ERAMIREZ' [TokenCreated], GETDATE() [DateCreated], NULL [TokenUpdated], NULL [DateUpdated]

INSERT INTO [dbo].[FlateRate]([IdDimensional],[IdSegmentArea],[ExceededRate],[PriceRate],[AdicionalCostPerUnit],[IdCurrency],[IdCountry],[FlatRateStatus],[IdRateCategory],[DateFromValid],[DateExpired],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
SELECT 6 'IdDimensional', 4 'IdSegmentArea', 'TRUE' 'ExceededRate',  75 'PriceRate', 1 'AdicionalCostPerUnit', 1 'IdCurrency', 'GT' [IdCountry],  'TRUE' 'FlatRateStatus',  1 [IdRateCategory], '2020-07-01' [DateFromValid], '2022-07-31' [DateExpired], 'SYS-ERAMIREZ' [TokenCreated], GETDATE() [DateCreated], NULL [TokenUpdated], NULL [DateUpdated]

INSERT INTO [dbo].[FlateRate]([IdDimensional],[IdSegmentArea],[ExceededRate],[PriceRate],[AdicionalCostPerUnit],[IdCurrency],[IdCountry],[FlatRateStatus],[IdRateCategory],[DateFromValid],[DateExpired],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
SELECT 6 'IdDimensional', 5 'IdSegmentArea', 'TRUE' 'ExceededRate',  83 'PriceRate', 1 'AdicionalCostPerUnit', 1 'IdCurrency', 'GT' [IdCountry],  'TRUE' 'FlatRateStatus',  1 [IdRateCategory], '2020-07-01' [DateFromValid], '2022-07-31' [DateExpired], 'SYS-ERAMIREZ' [TokenCreated], GETDATE() [DateCreated], NULL [TokenUpdated], NULL [DateUpdated]

















/*--------------------------------------------
CUR_IdCurrency	CUR_Name	CUR_Symbol	CUR_ExchangeRate	CUR_Country	CUR_ExchangeRateDate
1	QUETZAL	Q.	7.8127	GT	NULL
2	LEMPIRA	L.	18.795	HN	NULL
3	BALBOA	B/	1.00	PA	NULL
4	DOLAR	$.	23.6308	US	2018-03-16 00:00:00.000
5	EURO	€.	0.7052	EU	NULL
6	PESO MEXICANO	$.	12.99	MX	2013-09-27 17:49:36.000
7	COLON	¢.	548.75	CR	NULL
---------------------------------------------*/

--SELECT * FROM [dbo].[FlateRate]
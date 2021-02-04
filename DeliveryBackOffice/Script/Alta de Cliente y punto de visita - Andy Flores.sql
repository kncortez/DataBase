-- ANDY FLORES
--Customer
INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject],
[RegexEmail], [RegexFilename], [Abbreviation])
VALUES ('ANDY FLORES', 'ANDY FLORES', '@gmail.com','^.*solicitud.*$','^andyflorestb@gmail.com|loquebuscasgt@gmail.com$','^envios_.*\.xls$','ANDY FLORES')

--VisitPoint
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] 
([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId]
,[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14790,'TODO LO QUE BUSCAS',1,'GT',139083
,'BHERRERA',GETDATE(),NULL,NULL
,300,NULL,NULL,NULL,NULL,NULL,NULL)
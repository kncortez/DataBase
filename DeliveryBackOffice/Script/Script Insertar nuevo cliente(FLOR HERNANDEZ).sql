SELECT * FROM DeliveryBackOffice.dbo.Customer;
SELECT * FROM DeliveryBackOffice.dbo.VisitPointClient;
SELECT * FROM DeliveryBackOffice.dbo.VisitPointClient WHERE CodeOfReference = 13425;
SELECT * FROM DeliveryBackOffice.dbo.Customer WHERE IdCustomer = 35;

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation])
VALUES ('FLOR DE MARIA HERNANDEZ RIVERA', 'FLOR HERNANDEZ', '@gmail.com','^.*solicitud.*$','^florh49@gmail.com$','^envios_.*\.xls$',' FLOR HERNANDEZ')
 
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (13425,'FLOR HERNANDEZ',1,'GT', 138084,'CCANO',GETDATE(),NULL,NULL,35,NULL,NULL,NULL,NULL,NULL,NULL)

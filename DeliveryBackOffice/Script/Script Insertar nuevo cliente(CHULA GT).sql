SELECT * FROM DeliveryBackOffice.dbo.Customer;
SELECT * FROM DeliveryBackOffice.dbo.VisitPointClient;
SELECT * FROM DeliveryBackOffice.dbo.VisitPointClient WHERE CodeOfReference = 13420;
SELECT * FROM DeliveryBackOffice.dbo.Customer WHERE IdCustomer = 34;

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation])
VALUES (' CHULA GT', ' CHULA GT.', 'verenamere@gmail.com','^.*solicitud.*$','^verenamere@gmail.com$','^envios_.*\.xls$','CHULA GT')
 
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (13420,'CHULA GT',1,'GT', 34,'CCANO',GETDATE(),NULL,NULL,33,NULL,NULL,NULL,NULL,NULL,NULL)

SELECT * FROM DeliveryBackOffice.dbo.Customer;
SELECT * FROM DeliveryBackOffice.dbo.VisitPointClient;
SELECT * FROM DeliveryBackOffice.dbo.VisitPointClient WHERE CodeOfReference = 13430;
SELECT * FROM DeliveryBackOffice.dbo.Customer WHERE IdCustomer = 36;

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation])
VALUES ('ELEGANT DORMITORIOS DIANNA HOME', 'ELEGANT DORMITORIOS DIANNA HOME', '@gmail.com','^.*solicitud.*$','^al350334@gmail.com$','^envios_.*\.xls$','DORMITORIOS DIANNA HOME');
 
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (13430,'ELEGANT DORMITORIOS DIANNA HOME',1,'GT', 138085,'CCANO',GETDATE(),NULL,NULL,36,NULL,NULL,NULL,NULL,NULL,NULL)

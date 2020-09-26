SELECT * FROM DeliveryBackOffice.dbo.Customer;
SELECT * FROM DeliveryBackOffice.dbo.VisitPointClient;
SELECT * FROM DeliveryBackOffice.dbo.VisitPointClient WHERE CodeOfReference = 13435;

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation])
VALUES ('SUPLIDORA DE MODA S.A.', 'SUPLIDORA DE MODA S.A.', '@shopnts.com.gt','^.*solicitud.*$','^([\w\.\-]+)@shopnts.com$','^envios_.*\.xls$','SUPLIDORA DE MODA');
 
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (13435,'New Trend Shop', 1,'GT', 138090,'CCANO',GETDATE(),NULL,NULL,37,NULL,NULL,NULL,NULL,NULL,NULL);
	
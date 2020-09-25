SELECT * FROM DeliveryBackOffice.dbo.Customer;
SELECT * FROM DeliveryBackOffice.dbo.VisitPointClient;
SELECT * FROM DeliveryBackOffice.dbo.VisitPointClient WHERE CodeOfReference = 13435;

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation])
VALUES ('SUPLIDORA DE MODA S.A.', 'New Trend Shop', '@shopnts.com.gt','^.*solicitud.*$','^compras@shopnts.com$','^envios_.*\.xls$','LIMARCA');
 
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (13435,'New Trend Shop', 1,'GT', 41,'CCANO',GETDATE(),NULL,NULL,33,NULL,NULL,NULL,NULL,NULL,NULL);
	
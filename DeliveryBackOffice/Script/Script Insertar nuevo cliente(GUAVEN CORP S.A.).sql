	
SELECT * FROM DeliveryBackOffice.dbo.Customer;
SELECT * FROM DeliveryBackOffice.dbo.VisitPointClient;
SELECT * FROM DeliveryBackOffice.dbo.VisitPointClient WHERE CodeOfReference = 13440;

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], 
[Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation])  
 VALUES ('GUAVEN CORP S.A.', 'GUAVEN CORP S.A.', '@guavencorp.com.gt', '^.*solicitud.*$',
 '^administracion@guavencorp.com$', '^envios_.*\.xls$','GUAVEN CORP S.A.');

 INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ( [CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],
 [VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
 VALUES (13440,'GUAVEN CORP S.A.', 42,'GT', NULL,'APAZ',GETDATE(),NULL,NULL, 42,NULL,NULL,NULL,NULL,NULL,NULL)

SELECT * FROM DeliveryBackOffice.dbo.Customer;
SELECT * FROM DeliveryBackOffice.dbo.VisitPointClient;
SELECT * FROM DeliveryBackOffice.dbo.VisitPointClient WHERE CodeOfReference = 13415;

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], 
[Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation])  
 VALUES ('LIMARCA S.A.', 'VIA BRAZ', '@viabraz.com.gt', '^.*solicitud.*$',
 '^([\w\.\-]+)@hotmail.com$', '^envios_.*\.xls$','VIA BRAZ');

 INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ( [CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
 VALUES (13415,'LIMARCA S.A.', 1,'GT', NULL,'APAZ', GETDATE(), 33, NULL, 16,'9 AVENIDA 13-64, COLONIA ALVARADO', 3,'Mixco', 'Guatemala','48027357', 'VIA BRAZ');

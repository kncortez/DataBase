SELECT * FROM DeliveryBackOffice.dbo.Customer;
SELECT * FROM DeliveryBackOffice.dbo.VisitPointClient;
SELECT * FROM DeliveryBackOffice.dbo.VisitPointClient WHERE CodeOfReference = 13415;

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation])
VALUES ('LIMARCA S.A.', 'LIMARCA S.A.', '@viabraz.com.gt','^.*solicitud.*$','^([\w\.\-]+)@viabraz.com.gt$','^envios_.*\.xls$','LIMARCA')
 
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (13415,'VIA BRAZ',1,'GT',137835,'CCANO',GETDATE(),NULL,NULL,33,NULL,NULL,NULL,NULL,NULL,NULL)

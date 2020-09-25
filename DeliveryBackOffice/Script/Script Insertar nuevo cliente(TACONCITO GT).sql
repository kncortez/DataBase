
SELECT * FROM DeliveryBackOffice.dbo.Customer;
SELECT * FROM DeliveryBackOffice.dbo.VisitPointClient;
SELECT * FROM DeliveryBackOffice.dbo.VisitPointClient WHERE CodeOfReference = 13445;

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], 
[Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation])  
 VALUES ('TACONCITO GT', 'TACONCITO GT', '@gmail.com', '^.*solicitud.*$',
 '^josuealexandergironl@gmail.com$', '^envios_.*\.xls$','TACONCITO GT');

 INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ( [CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],
 [VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
 VALUES (13445,'TACONCITO GT', 1,'GT', NULL,'APAZ', GETDATE(), 43, NULL, NULL,'30 ave C 11-73 Zona 7 Jardines Tikal 1', 7,'Guatemala', 'Guatemala',' 33291166 / 55290028', 'TACONCITO GT');

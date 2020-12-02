INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation])  
 VALUES ('ENCAJA', 'ENCAJA', '@encaja.club','^.*solicitud.*$','^([\w\.\-]+)@encaja.club$"','^envios_.*\.xls$','ENCAJA')

 INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])  
 VALUES (14548,'ENCAJA',1,'GT',138711,'JHERNANDEZ',GETDATE(),NULL,NULL,258,NULL,NULL,NULL,NULL,NULL,NULL)
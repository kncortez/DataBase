-- JULIO CESAR FUENTES OROZCO
INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject],
[RegexEmail], [RegexFilename], [Abbreviation])
VALUES ('JULIO CESAR FUENTES OROZCO', 'JULIO FUENTES', '@gmail.com','^.*solicitud.*$','^juliofuentesbiologo@gmail.com$','^envios_.*\.xls$','JULIO FUENTES')

INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],
[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14775,'AVERE STORE GT',1,'GT',139066,'CCANO',GETDATE(),NULL,NULL,299,NULL,NULL,NULL,NULL,NULL,NULL)

-- SUPER VITAMINAS SA
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],
[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14780,'CENTRO SAC GNC',1,'GT',139055,'CCANO',GETDATE(),NULL,NULL,116,NULL,NULL,NULL,NULL,NULL,NULL)

-- ARCA DE NOE SA
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],
[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14785,'CENTRO SAC ARCA DE NOE',1,'GT',139054,'CCANO',GETDATE(),NULL,NULL,117,NULL,NULL,NULL,NULL,NULL,NULL)


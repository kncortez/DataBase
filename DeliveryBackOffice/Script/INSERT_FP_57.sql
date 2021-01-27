-- EJEMPLO DE NUEVO CLIENTE 
INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject],
[RegexEmail], [RegexFilename], [Abbreviation])
VALUES ('VICTORIA ALEJANDRA FERNANDEZ CARRILLO', 'VICTORIA FERNANDEZ', '@gmail.com','^.*solicitud.*$','^vickyfercar90@gmail.com$','^envios_.*\.xls$','VICTORIA FERNANDEZ');

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject],
[RegexEmail], [RegexFilename], [Abbreviation])
VALUES ('CORFASE, S.A', 'CORFASE, S.A', '@gmail.com','^.*solicitud.*$','^bodega2.corfasesa@gmail.com$','^envios_.*\.xls$','CORFASE')

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject],
[RegexEmail], [RegexFilename], [Abbreviation])
VALUES ('JUSTO MANUEL SAJBÍN RODAS', 'JUSTO SAJBÍN', '@outlook.com','^.*solicitud.*$','^corporacionjar@outlook.com$','^envios_.*\.xls$','JUSTO SAJBÍN')

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject],
[RegexEmail], [RegexFilename], [Abbreviation])
VALUES ('BANCO INTERNACIONAL S.A.', 'BANCO INTERNACIONAL', '@outlook.com','^.*solicitud.*$','^fernandoblanco.mejia@outlook.com$','^envios_.*\.xls$','BANCO INTERNACIONAL')

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject],
[RegexEmail], [RegexFilename], [Abbreviation])
VALUES ('FOUR-S FASHION, S.A.', 'FOUR-S FASHION', '@gmail.com','^.*solicitud.*$','^four.sfashioncjm@gmail.com$','^envios_.*\.xls$','FOUR-S FASHION')

-- EJEMPLO DE NUEVO PUNTO
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],
[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14750,'KEITECH',1,'GT',139038,'CCANO',GETDATE(),NULL,NULL,294,NULL,NULL,NULL,NULL,NULL,NULL);

INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],
[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14755,'CORFASESA',1,'GT',139037,'CCANO',GETDATE(),NULL,NULL,295,NULL,NULL,NULL,NULL,NULL,NULL);

INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],
[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14760,'ISHOES OUTLET',1,'GT',139034,'CCANO',GETDATE(),NULL,NULL,296,NULL,NULL,NULL,NULL,NULL,NULL);

INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],
[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14761,'RUBEAUTIFUL',1,'GT',139035,'CCANO',GETDATE(),NULL,NULL,296,NULL,NULL,NULL,NULL,NULL,NULL);

INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],
[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14762,'PETRA',1,'GT',139036,'CCANO',GETDATE(),NULL,NULL,296,NULL,NULL,NULL,NULL,NULL,NULL);

INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],
[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14765,'INTERBANCO',1,'GT',139032,'CCANO',GETDATE(),NULL,NULL,297,NULL,NULL,NULL,NULL,NULL,NULL);

INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],
[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14770,'FOUR-S FASHION',1,'GT',139039,'CCANO',GETDATE(),NULL,NULL,298,NULL,NULL,NULL,NULL,NULL,NULL);
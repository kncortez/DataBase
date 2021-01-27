-- EJEMPLO DE NUEVO CLIENTE 
INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject],
[RegexEmail], [RegexFilename], [Abbreviation])
VALUES ('VICTORIA ALEJANDRA FERNANDEZ CARRILLO', 'VICTORIA ALEJANDRA FERNANDEZ CARRILLO', '@gmail.com','^.*solicitud.*$','^vickyfercar90@gmail.com$','^envios_.*\.xls$','KEITECH');

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject],
[RegexEmail], [RegexFilename], [Abbreviation])
VALUES ('CORFASE, S.A', 'CORFASE, S.A', '@gmail.com','^.*solicitud.*$','^bodega2.corfasesa@gmail.com$','^envios_.*\.xls$','CORFASESA')


INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject],
[RegexEmail], [RegexFilename], [Abbreviation])
VALUES ('JUSTO MANUEL SAJBÍN RODAS', 'JUSTO MANUEL SAJBÍN RODAS', '@outlook.com','^.*solicitud.*$','^corporacionjar@outlook.com$','^envios_.*\.xls$','ISHOES OUTLET')


INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject],
[RegexEmail], [RegexFilename], [Abbreviation])
VALUES ('JUSTO MANUEL SAJBÍN RODAS', 'JUSTO MANUEL SAJBÍN RODAS', '@outlook.com','^.*solicitud.*$','^corporacionjar@outlook.com$','^envios_.*\.xls$','RUBEAUTIFUL')

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject],
[RegexEmail], [RegexFilename], [Abbreviation])
VALUES ('JUSTO MANUEL SAJBÍN RODAS', 'JUSTO MANUEL SAJBÍN RODAS', '@outlook.com','^.*solicitud.*$','^corporacionjar@outlook.com$','^envios_.*\.xls$','PETRA')

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject],
[RegexEmail], [RegexFilename], [Abbreviation])
VALUES ('BANCO INTERNACIONAL S.A.', 'BANCO INTERNACIONAL S.A.', '@outlook.com','^.*solicitud.*$','^fernandoblanco.mejia@outlook.com$','^envios_.*\.xls$','INTERBANCO')


-- EJEMPLO DE NUEVO PUNTO
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],
[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (138845,'CASH LOGISTICS CENTRAL',1,'GT',14770,'CCANO',GETDATE(),NULL,NULL,283,NULL,NULL,NULL,NULL,NULL,NULL);

INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],
[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (138840,'CASH LOGISTICS AGENCIA TECULUTAN',1,'GT',14771,'CCANO',GETDATE(),NULL,NULL,283,NULL,NULL,NULL,NULL,NULL,NULL);

INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],
[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (138841,'CASH LOGISTICS AGENCIA ESCUINTLA',1,'GT',14772,'CCANO',GETDATE(),NULL,NULL,283,NULL,NULL,NULL,NULL,NULL,NULL);

INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],
[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (138842,'CASH LOGISTICS AGENCIA MAZATENANGO',1,'GT',14773,'CCANO',GETDATE(),NULL,NULL,283,NULL,NULL,NULL,NULL,NULL,NULL);

INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],
[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (138843,'CASH LOGISTICS AGENCIA PETÉN',1,'GT',14774,'CCANO',GETDATE(),NULL,NULL,283,NULL,NULL,NULL,NULL,NULL,NULL);

INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],
[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (138844,'CASH LOGISTICS AGENCIA XELA',1,'GT',14775,'CCANO',GETDATE(),NULL,NULL,283,NULL,NULL,NULL,NULL,NULL,NULL);
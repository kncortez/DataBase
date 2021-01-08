INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject],
[RegexEmail], [RegexFilename], [Abbreviation])
VALUES ('FDE WOMENCO', 'FDE WOMENCO', '@womencogt.com','^.*solicitud.*$','^([\w\.\-]+)@womencogt.com$','^envios_.*\.xls$','FDE WOMENCO')

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject],
[RegexEmail], [RegexFilename], [Abbreviation])
VALUES ('FDE SMART STORE 502S', 'FDE SMART STORE 502S', '@gmail.com','^.*solicitud.*$','^velasquezcumes1997@gmail.com$','^envios_.*\.xls$','FDE SMART STORE 502S')

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject],
[RegexEmail], [RegexFilename], [Abbreviation])
VALUES ('DIANA FRANSHEZCA GUANCIN ROMERO', 'DIANA FRANSHEZCA GUANCIN ROMERO', '@gmail.com','^.*solicitud.*$','^diana.franshezca99@gmail.com$','^envios_.*\.xls$','DIANA GUANCIN')

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject],
[RegexEmail], [RegexFilename], [Abbreviation])
VALUES ('FDE MOTOTOTAL S.A.', 'FDE MOTOTOTAL', '@gmail.com','^.*solicitud.*$','^motototalbm@gmail.com$','^envios_.*\.xls$','FDE MOTOTOTAL')

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject],
[RegexEmail], [RegexFilename], [Abbreviation])
VALUES ('EUNICE ODILIA DÍAZ LÓPEZ DE REYES', 'EUNICE ODILIA DÍAZ LÓPEZ DE REYES', '@puntocreativo.com.gt','^.*solicitud.*$','^sreyes@puntocreativo.com.gt$','^envios_.*\.xls$','EUNICE DÍAZ')


INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],
[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14648,'WomenCo',1,'GT',138837,'CCANO',GETDATE(),NULL,NULL,278,NULL,NULL,NULL,NULL,NULL,NULL)

INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],
[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14653,'Smart Store 502',1,'GT',138838,'CCANO',GETDATE(),NULL,NULL,279,NULL,NULL,NULL,NULL,NULL,NULL)

INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],
[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14658,'Joseph Litle Dreams',1,'GT',138611,'CCANO',GETDATE(),NULL,NULL,280,NULL,NULL,NULL,NULL,NULL,NULL)

INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],
[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14663,'Motototal',1,'GT',138908,'CCANO',GETDATE(),NULL,NULL,281,NULL,NULL,NULL,NULL,NULL,NULL)

INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],
[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14668,'Punto Creativo',1,'GT',138919,'CCANO',GETDATE(),NULL,NULL,282,NULL,NULL,NULL,NULL,NULL,NULL)

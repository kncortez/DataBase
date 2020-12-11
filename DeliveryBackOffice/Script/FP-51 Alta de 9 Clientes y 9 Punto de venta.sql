		
INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject],
[RegexEmail], [RegexFilename], [Abbreviation], [COD])
VALUES ('LUIS FERNANDO SOLIS ROMERO', 'LUIS FERNANDO SOLIS ROMERO', '@gmail.com','^.*solicitud.*$','^luis.fer.sol88@gmail.com$','^envios_.*\.xls$','LUIS SOLIS',1)		

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject],
[RegexEmail], [RegexFilename], [Abbreviation], [COD])
VALUES ('SARI´S BEAUTY SUPPLY SHOP', 'SARI´S BEAUTY SUPPLY SHOP', '@hotmail.com','^.*solicitud.*$','^sarisbs@hotmail.com$','^envios_.*\.xls$','SARI´S BEAUTY',1)

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject],
[RegexEmail], [RegexFilename], [Abbreviation], [COD])
VALUES ('PETCLICK GT', 'PETCLICK GT', '@gmail.com','^.*solicitud.*$','^petclick.gt@gmail.com$','^envios_.*\.xls$','PETCLICK GT',1)

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject],
[RegexEmail], [RegexFilename], [Abbreviation], [COD])
VALUES ('FDE AMIGAS MONTE MARIA SOCIEDAD ANONIMA', 'FDE AMIGAS MONTE MARIA SOCIEDAD ANONIMA', '@colegiomontemaria.edu.gt','^.*solicitud.*$','^([\w\.\-]+)@colegiomontemaria.edu.gt$','^envios_.*\.xls$','AMIGAS MONTE MARIA',0)

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject],
[RegexEmail], [RegexFilename], [Abbreviation], [COD])
VALUES ('FDE DISTRIBUIDORA GAMER', 'FDE DISTRIBUIDORA GAMER', '@hotmail.com','^.*solicitud.*$','^Garciaelder227@gmail.com|Yunis111@hotmail.com$','^envios_.*\.xls$','FDE DISTRIBUIDORA GAMER',1)

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject],
[RegexEmail], [RegexFilename], [Abbreviation], [COD])
VALUES ('TENDENCYS INNOVATIONS GUATEMALA, S.A.', 'TENDENCYS INNOVATIONS GUATEMALA, S.A.', '@hotmail.com','^.*solicitud.*$','^sarisbs@hotmail.com$','^envios_.*\.xls$','TENDENCYS INNOVATIONS',1)

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject],
[RegexEmail], [RegexFilename], [Abbreviation], [COD])
VALUES ('LOREM GUATEMALA', 'LOREM GUATEMALA', '@gmail.com','^.*solicitud.*$','^lorenguatemala@gmail.com$','^envios_.*\.xls$','LOREM GUATEMALA',1)

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject],
[RegexEmail], [RegexFilename], [Abbreviation], [COD])
VALUES ('HILCIAS ADIEL RUBIO OXLAJ', 'HILCIAS ADIEL RUBIO OXLAJ', '@gmail.com','^.*solicitud.*$','^adielrubio26@gmail.com$','^envios_.*\.xls$','HILCIAS ADIEL RUBIO OXLAJ',1)

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject],
[RegexEmail], [RegexFilename], [Abbreviation], [COD])
VALUES ('GRUPO ASPRO S.A', 'GRUPO ASPRO S.A', '@hotmail.com','^.*solicitud.*$','^([\w\.\-]+)@grupoaspro.com$','^envios_.*\.xls$','GRUPO ASPRO S.A',1)

INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],
[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14573,'LUIS FERNANDO SOLIS ROMERO',1,'GT',138748,'JHERNANDEZ',GETDATE(),NULL,NULL,263,NULL,NULL,NULL,NULL,NULL,NULL)

INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],
[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14578,'SARI´S BEAUTY SUPPLY SHOP',1,'GT',138739,'JHERNANDEZ',GETDATE(),NULL,NULL,264,NULL,NULL,NULL,NULL,NULL,NULL)

INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],
[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14583,'PETCLICK GT',1,'GT',138738,'JHERNANDEZ',GETDATE(),NULL,NULL,265,NULL,NULL,NULL,NULL,NULL,NULL)

INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],
[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14588,'AMIGAS DE MONTE MARIA',1,'GT',138749,'JHERNANDEZ',GETDATE(),NULL,NULL,266,NULL,NULL,NULL,NULL,NULL,NULL)

INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],
[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14593,'DISTRIBUIDORA GAMER',1,'GT',138754,'JHERNANDEZ',GETDATE(),NULL,NULL,267,NULL,NULL,NULL,NULL,NULL,NULL)

INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],
[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14598,'ENVIA.COM',1,'GT',138756,'JHERNANDEZ',GETDATE(),NULL,NULL,268,NULL,NULL,NULL,NULL,NULL,NULL)

INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],
[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14603,'LOREM GT',1,'GT',138764,'JHERNANDEZ',GETDATE(),NULL,NULL,269,NULL,NULL,NULL,NULL,NULL,NULL)

INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],
[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14608,'RUBIO UNDERWEAR',1,'GT',138765,'JHERNANDEZ',GETDATE(),NULL,NULL,270,NULL,NULL,NULL,NULL,NULL,NULL)

INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],
[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14613,'GRUPO ASPRO',1,'GT',138763,'JHERNANDEZ',GETDATE(),NULL,NULL,271,NULL,NULL,NULL,NULL,NULL,NULL)
		
INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject],
[RegexEmail], [RegexFilename], [Abbreviation], [COD])
VALUES ('LUIS FERNANDO SOLIS ROMERO', 'LUIS FERNANDO SOLIS ROMERO', '@gmail.com','^.*solicitud.*$','^luis.fer.sol88@gmail.com$','^envios_.*\.xls$','LUIS SOLIS',1)		

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject],
[RegexEmail], [RegexFilename], [Abbreviation], [COD])
VALUES ('SARI´S BEAUTY SUPPLY SHOP', 'SARI´S BEAUTY SUPPLY SHOP', '@hotmail.com','^.*solicitud.*$','^sarisbs@hotmail.com$','^envios_.*\.xls$','SARI´S BEAUTY',1)

INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],
[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14573,'LUIS FERNANDO SOLIS ROMERO',1,'GT',138748,'JHERNANDEZ',GETDATE(),NULL,NULL,263,NULL,NULL,NULL,NULL,NULL,NULL)

INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],
[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14578,'SARI´S BEAUTY SUPPLY SHOP',1,'GT',138739,'JHERNANDEZ',GETDATE(),NULL,NULL,264,NULL,NULL,NULL,NULL,NULL,NULL)
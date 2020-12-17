		
INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject],
[RegexEmail], [RegexFilename], [Abbreviation], [COD])
VALUES ('ESTEFANY ALEJANDRA ALDANA MOLINA', 'ESTEFANY ALEJANDRA ALDANA MOLINA', '@gmail.com','^.*solicitud.*$','^estef963almo@gmail.com$','^envios_.*\.xls$','ESTEFANY ALDANA', 1)	

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject],
[RegexEmail], [RegexFilename], [Abbreviation], [COD])
VALUES ('IVANIA CATALINA DE LEON GONZALEZ', 'IVANIA CATALINA DE LEON GONZALEZ', '@gmail.com','^.*solicitud.*$','^margothtrend@gmail.com$','^envios_.*\.xls$','IVANIA DE LEON', 1)

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject],
[RegexEmail], [RegexFilename], [Abbreviation], [COD])
VALUES ('GERARDO STIVEN SERMEÑO CONSTANZA', 'GERARDO STIVEN SERMEÑO CONSTANZA', '@gmail.com','^.*solicitud.*$','^petclick.gt@gmail.com$','^envios_.*\.xls$','GERARDO SERMEÑO', 1)

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject],
[RegexEmail], [RegexFilename], [Abbreviation], [COD])
VALUES ('ADELAS FASHIONS', 'ADELAS FASHIONS', '@gmail.com','^.*solicitud.*$','^adelasfachiohn3@gmail.com$','^envios_.*\.xls$','ADELAS FASHION', 1)

INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],
[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14618,'PELUCHOS PET SHOP',1,'GT',138761,'JHERNANDEZ',GETDATE(),NULL,NULL,272,NULL,NULL,NULL,NULL,NULL,NULL)

INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],
[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14623,'MARGOTH TREND',1,'GT',138791,'JHERNANDEZ',GETDATE(),NULL,NULL,273,NULL,NULL,NULL,NULL,NULL,NULL)

INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],
[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14628,'CLONES SHOP',1,'GT',138793,'JHERNANDEZ',GETDATE(),NULL,NULL,274,NULL,NULL,NULL,NULL,NULL,NULL)

INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],
[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14633,'ADELAS FASHION',1,'GT',138783,'JHERNANDEZ',GETDATE(),NULL,NULL,275,NULL,NULL,NULL,NULL,NULL,NULL)
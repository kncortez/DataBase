--FP 37 - Alta 5 Clientes
  
  
-- BARBARA MARROQUIN COBAR
INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('BARBARA MARROQUIN COBAR', 'BARBARA MARROQUIN COBAR', '@gmail.com','^.*solicitud.*$','^barbaradespell@gmail.com$','^envios_.*\.xls$','BARBARA MARROQUIN')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (13717,'IDEA TALLER GT',1,'GT',138281,'ERIVAS',GETDATE(),NULL,NULL,97,''
,7,'MIXCO','GUATEMALA','41865285','BARBARA MARROQUIN')


-- ETHEL VELASQUEZ
INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('ETHEL VELASQUEZ', 'ETHEL VELASQUEZ', '@gmail.com','^.*solicitud.*$','^ethel1506@gmail.com$','^envios_.*\.xls$','ETHEL VELASQUEZ')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (13722,'MANDOTS',1,'GT',138282,'ERIVAS',GETDATE(),NULL,NULL,98,''
,4,'VILLA NUEVA','GUATEMALA','54350045','ETHEL VELASQUEZ')


-- ANA LUCRECIA DE CHAVARRIA
INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('ANA LUCRECIA DE CHAVARRIA', 'ANA LUCRECIA DE CHAVARRIA', '@gmail.com','^.*solicitud.*$','^analucreciadechavarria@gmail.com$','^envios_.*\.xls$','ANA LUCRECIA')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (13727,'LUCKY´S BIJOU',1,'GT',138289,'ERIVAS',GETDATE(),NULL,NULL,99,''
,1,'MIXCO','GUATEMALA','42011837','ANA LUCRECIA')


-- JONATAN TACAM TAX
INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('JONATAN TACAM TAX', 'JONATAN TACAM TAX', '@gmail.com','^.*solicitud.*$','^alexander.575757@gmail.com$','^envios_.*\.xls$','JONATAN TACAM')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (13732,'CUAZZAR',1,'GT',138283,'ERIVAS',GETDATE(),NULL,NULL,100,''
,4,'TOTONICAPAN','GUATEMALA','48146601','JONATAN TACAM')


-- MARVIN LEONARDO DELGADO VASQUEZ
INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('MARVIN LEONARDO DELGADO VASQUEZ', 'MARVIN LEONARDO DELGADO VASQUEZ', '@outlook.com','^.*solicitud.*$','^importadoradelgado@outlook.com$','^envios_.*\.xls$','MARVIN DELGADO')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (13737,'DENTAL FUTURA',1,'GT',138297,'ERIVAS',GETDATE(),NULL,NULL,101,'San Juan Ostuncalco'
,2,'QUETZALTENANGO','QUETZALTENANGO','77628060 / 32113924','MARVIN DELGADO')

-- FP-39 , ALTA DE 13 CLIENTES


-- MARIA JOSE CANTILLANO
INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('MARIA JOSE CANTILLANO', 'MARIA JOSE CANTILLANO', '@gmail.com','^.*solicitud.*$','^infoninastore@gmail.com$','^envios_.*\.xls$','MARIA JOSE')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (13863,'INDUECO',1,'GT',138396,'ERIVAS',GETDATE(),NULL,NULL,126,''
,8,'GUATEMALA','GUATEMALA','40833729','INDUECO')


-- SOLUCIONES GLOBALES	
INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('SOLUCIONES GLOBALES', 'SOLUCIONES GLOBALES', '@gmail.com','^.*solicitud.*$','^robert.ariel.b@gmail.com$','^envios_.*\.xls$','SOLUCIONES')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (13868,'SOLUCIONES GLOBALES',1,'GT',138395,'ERIVAS',GETDATE(),NULL,NULL,127,'10 calle 6-48'
,9,'GUATEMALA','GUATEMALA','23249985','SOLUCIONES GLOBALES')


-- SUBLIMA JYP
INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('SUBLIMA JYP', 'SUBLIMA JYP', '@gmail.com','^.*solicitud.*$','^sublimajyp@gmail.com$','^envios_.*\.xls$','SUBLIMA JYP')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (13873,'SUBLIMA JYP',1,'GT',138394,'ERIVAS',GETDATE(),NULL,NULL,128,''
,3,'QUETZALTENANGO','QUETZALTENANGO','41127304 / 77669214','SUBLIMA JYP')


-- JULIUZ SHOP
INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('JULIUZ SHOP', 'JULIUZ SHOP', '@gmail.com','^.*solicitud.*$','^juliocbarahonaf@gmail.com$','^envios_.*\.xls$','JULIUZ SHOP')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (13878,'JULIUZ SHOP',1,'GT',138393,'ERIVAS',GETDATE(),NULL,NULL,129,''
,10,'SANTA CATARINA PINULA','GUATEMALA','51872190','JULIUZ SHOP')


-- FERNANDO PEREZ
INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('FERNANDO PEREZ', 'FERNANDO PEREZ', '@gmail.com','^.*solicitud.*$','^smartpro502@gmail.com$','^envios_.*\.xls$','FERNANDO PEREZ')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (13883,'CORPORACION SMART AND PRO S.A.',1,'GT',138379,'ERIVAS',GETDATE(),NULL,NULL,130,''
,3,'QUETZALTENANGO','QUETZALTENANGO','32225855','FERNANDO PEREZ')


-- ALEJANDRO GONZALEZ
INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('ALEJANDRO GONZALEZ', 'ALEJANDRO GONZALEZ', '@gmail.com','^.*solicitud.*$','^gonzalesleticia924@gmail.com$','^envios_.*\.xls$','ALEJANDRO')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (13888,'GONZALEZ POLO SPORT',1,'GT',138380,'ERIVAS',GETDATE(),NULL,NULL,131,''
,7,'SAN CRISTOBAL','TOTONICAPAN','50042077','ALEJANDRO')


-- EDGAR PORRAS
INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('EDGAR PORRAS', 'EDGAR PORRAS', '@provocame.com.gt','^.*solicitud.*$','^([\w\.\-]+)@provocame.com.gt$','^envios_.*\.xls$','EDGAR PORRAS')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (13893,'SISTEMAS EMPRESARIALES',1,'GT',138381,'ERIVAS',GETDATE(),NULL,NULL,132,''
,7,'MIXCO','GUATEMALA','50664118','EDGAR PORRAS')


-- AMENA MACARENA
INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('AMENA MACARENA', 'AMENA MACARENA', '@gmail.com','^.*solicitud.*$','^amenamacarena@gmail.com$','^envios_.*\.xls$','AMENA MACARENA')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (13898,'AMENA MACARENA',1,'GT',138371,'ERIVAS',GETDATE(),NULL,NULL,133,''
,17,'GUATEMALA','GUATEMALA','58155084','AMENA MACARENA')


-- DIANA GONZALEZ
INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('DIANA GONZALEZ', 'DIANA GONZALEZ', '@gmail.com','^.*solicitud.*$','^dianagonzalez014017@gmail.com$','^envios_.*\.xls$','DIANA')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (13903,'PRINCESS TUTU',1,'GT',138337,'ERIVAS',GETDATE(),NULL,NULL,134,''
,7,'QUETZALTENANGO','QUETZALTENANGO','33864478','DIANA GONZALEZ')


-- DIEGO PASTOR
INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('DIEGO PASTOR', 'DIEGO PASTOR', '@hotmail.com','^.*solicitud.*$','^diegopas2011@hotmail.com$','^envios_.*\.xls$','DIEGO')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (13908,'DIEGO PASTOR',1,'GT',138334,'ERIVAS',GETDATE(),NULL,NULL,135,''
,0,'SAN FRANCISCO EL ALTO','TOTONICAPAN','30317830','DIEGO PASTOR')


-- CURIO-CITY
INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('CURIO-CITY', 'CURIO-CITY', '@gmail.com','^.*solicitud.*$','^eliani0617@gmail.com$','^envios_.*\.xls$','DIEGO')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (13913,'CURIO-CITY',1,'GT',138335,'ERIVAS',GETDATE(),NULL,NULL,136,''
,5,'QUETZALTENANGO','QUETZALTENANGO','51554863 / 51554808','CURIO-CITY')


-- LAOS CORPORATIVA, S.A.
INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('LAOS CORPORATIVA, S.A.', 'LAOS CORPORATIVA, S.A.', '@gmail.com','^.*solicitud.*$','^implaos@gmail.com$','^envios_.*\.xls$','LAOS')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (13918,'LAOS CORPORATIVA, S.A.',1,'GT',138382,'ERIVAS',GETDATE(),NULL,NULL,137,'Boulevard el naranjo 28-98 centro empresarial fiori bodega 1'
,4,'MIXCO','GUATEMALA','52048139','LAOS')


-- MULTIPROYECTORES
INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('MULTIPROYECTOS', 'MULTIPROYECTORES', '@gmail.com','^.*solicitud.*$','^diegoar14@gmail.com$','^envios_.*\.xls$','MULTIPROYECTORES')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (13923,'MULTIPROYECTOS',1,'GT',138339,'ERIVAS',GETDATE(),NULL,NULL,138,'Via 5 0-81'
,4,'GUATEMALA','GUATEMALA','59390973','MULTIPROYECTORES')

















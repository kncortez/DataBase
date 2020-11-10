-- FP-41 - ALTA DE CLIENTES Y PUNTOS DE VENTAS


-- RAQUEL GONZALEZ

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('RAQUEL GONZALEZ', 'RAQUEL GONZALEZ', '@gmail.com','^.*solicitud.*$','^raqelg0991@gmail.com$','^envios_.*\.xls$','RAQUEL GONZALEZ')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (13928,'BAKE TO BAKE',1,'GT',138397,'ERIVAS',GETDATE(),NULL,NULL,139,''
,15,'GUATEMALA','GUATEMALA','49701099','RAQUEL GONZALEZ')


-- ELDER VELASQUEZ

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('ELDER VELASQUEZ', 'ELDER VELASQUEZ', '@gmail.com','^.*solicitud.*$','^sportsshopingt@gmail.com$','^envios_.*\.xls$','ELDER VELASQUEZ')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (13933,'SPORTS SHOPPING',1,'GT',138404,'ERIVAS',GETDATE(),NULL,NULL,140,''
,2,'MIXCO','GUATEMALA','45641250','ELDER VELASQUEZ')


-- IPHONE TRADING

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('IPHONE TRADING', 'IPHONE TRADING', '@gmail.com','^.*solicitud.*$','^rubentun60@gmail.com$','^envios_.*\.xls$','IPHONE TRADING')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (13938,'IPHONE TRADING',1,'GT',138405,'ERIVAS',GETDATE(),NULL,NULL,141,'Santa Elena, Flores, Petén'
,1,'FLORES','PETEN','33885039','IPHONE TRADING')


-- KARLA SAMAYOA

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('KARLA SAMAYOA', 'KARLA SAMAYOA', '@hotmail.com','^.*solicitud.*$','^karlasam17@hotmail.com$','^envios_.*\.xls$','KARLA SAMAYOA')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (13943,'DIJES Y MÁS GT',1,'GT',138407,'ERIVAS',GETDATE(),NULL,NULL,142,''
,3,'ESCUINTLA','ESCUINTLA','58707751','KARLA SAMAYOA')


-- LESLY ARGUETA

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('LESLY ARGUETA', 'LESLY ARGUETA', '@hotmail.com','^.*solicitud.*$','^lesly_marisa3@hotmail.com$','^envios_.*\.xls$','LESLY ARGUETA')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (13948,'LESLY ARGUETA',1,'GT',138406,'ERIVAS',GETDATE(),NULL,NULL,143,''
,7,'SAN MIGUEL PETAPA','GUATEMALA','54330232','LESLY ARGUETA')


-- ALMACÉN PARA NIÑOS

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('ALMACEN PARA NIÑOS', 'ALMACEN PARA NIÑOS', '@gmail.com','^.*solicitud.*$','^jeremiasmarconi125@gmail.com$','^envios_.*\.xls$','ALMACEN PARA NIÑOS')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (13953,'ALMACEN PARA NIÑOS',1,'GT',138409,'ERIVAS',GETDATE(),NULL,NULL,144,''
,2,'LA ESPERANZA','QUETZALTENANGO','49488790 / 35858497','ALMACEN PARA NIÑOS')


-- WALESKA SOLORZANO

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('WALESKA SOLORZANO', 'WALESKA SOLORZANO', '@gmail.com','^.*solicitud.*$','^wualestore@gmail.com$','^envios_.*\.xls$','WALESKA')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (13958,'WUALESTORE_GT',1,'GT',138410,'ERIVAS',GETDATE(),NULL,NULL,145,''
,2,'VILLA CANALES','GUATEMALA','43599699','WALESKA SOLORZANO')


-- ERICA ZURITA

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('ERICA ZURITA', 'ERICA ZURITA', '@gmail.com','^.*solicitud.*$','^gezu19@gmail.com$','^envios_.*\.xls$','ERICA ZURITA')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (13963,'VD EN LINEA',1,'GT',138408,'ERIVAS',GETDATE(),NULL,NULL,146,''
,0,'CHICHICASTENANGO','QUICHE','54158240','ERICA ZURITA')


-- MARIANA FIGUEROA

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('MARIANA FIGUEROA', 'MARIANA FIGUEROA', '@gmail.com','^.*solicitud.*$','^mariosaenzcarranza@gmail.com$','^envios_.*\.xls$','MARIANA')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (13968,'GLAM MAKEUP & HAIR',1,'GT',138413,'ERIVAS',GETDATE(),NULL,NULL,147,''
,3,'GUATEMALA','GUATEMALA','59238838','MARIANA')


-- JOEL ALBERTO GUZMÁN JIMENEZ 

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('JOEL ALBERTO GUZMÁN JIMENEZ', 'JOEL ALBERTO GUZMÁN JIMENEZ', '@gmail.com','^.*solicitud.*$','^jguzman2606@gmail.com$','^envios_.*\.xls$','JOEL GUZMAN')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (13973,'SOLUCIONES AUTOMOTRICES',1,'GT',138414,'ERIVAS',GETDATE(),NULL,NULL,148,'Plaza Prisma, Local 14 El Frutal'
,5,'VILLA NUEVA','GUATEMALA','36784838','JOEL GUZMAN')


-- JONATHAN GERNANDO CALDERÓN BOBADILLA

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('JONATHAN GERNANDO CALDERÓN BOBADILLA', 'JONATHAN GERNANDO CALDERÓN BOBADILLA', '@gmail.com','^.*solicitud.*$','^jonathanvadem@gmail.com$','^envios_.*\.xls$','JONATHAN CALDERON')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (13978,'CALDERÓN GT',1,'GT',138412,'ERIVAS',GETDATE(),NULL,NULL,149,''
,5,'VILLA NUEVA','GUATEMALA','40659746','JONATHAN CALDERÓN')


-- JOSE CHAVEZ

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('JOSE CHAVEZ', 'JOSE CHAVEZ', '@gmail.com','^.*solicitud.*$','^joserachavez1@gmail.com$','^envios_.*\.xls$','JOSE CHAVEZ')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (13983,'FRIENDS BOUTIQUE',1,'GT',138309,'ERIVAS',GETDATE(),NULL,NULL,150,''
,1,'CHIQUIMULA','CHIQUIMULA','58199822','JOSE CHAVEZ')


-- ALEX LOPEZ

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('ALEX LOPEZ', 'ALEX LOPEZ', '@gmail.com','^.*solicitud.*$','^brizzdelopez777@gmail.com$','^envios_.*\.xls$','ALEX LOPEZ')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (13988,'M&E 777',1,'GT',138415,'ERIVAS',GETDATE(),NULL,NULL,151,''
,0,'LA DEMOCRACIA','HUEHUETENANGO','32288356','ALEX LOPEZ')


-- MAGNOLIAS GT

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('MAGNOLIAS GT', 'MAGNOLIAS GT', '@gmail.com','^.*solicitud.*$','^lfgonzalez342@gmail.com$','^envios_.*\.xls$','MAGNOLIAS GT')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (13993,'MAGNOLIAS GT',1,'GT',138416,'ERIVAS',GETDATE(),NULL,NULL,152,'Blvd Los Próceres'
,10,'GUATEMALA','GUATEMALA','57817622','MAGNOLIAS GT')


-- LOGISTICA SINGULAR SOCIEDAD ANONIMA

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('LOGISTICA SINGULAR SOCIEDAD ANONIMA', 'LOGISTICA SINGULAR SOCIEDAD ANONIMA', '@catalogokoqueta.com','^.*solicitud.*$','^([\w\.\-]+)@catalogokoqueta.com$','^envios_.*\.xls$','LOGISTICA')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (13998,'CATALOGO KOQUETA',1,'GT',138418,'ERIVAS',GETDATE(),NULL,NULL,153,'29 Avenida 1-89 Centro Comercial Arco Plaza 3 nivel'
,7,'QUETZALTENANGO','QUETZALTENANGO','77281400','LOGISTICA SINGULAR')


-- ALMACENES SIMAN SOCIEDAD ANONIMA

-- PUNTO 1
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14003,'CENTRO DE DISTRIBUCION UNICOMER',1,'GT',138419,'ERIVAS',GETDATE(),NULL,NULL,119,'Calzada Atanasio Tzul 38-80'
,12,'GUATEMALA','GUATEMALA','22591500','ALMACENES SIMAN SA')

-- PUNTO 2
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14004,'CURACARO ROOSELVETL/UNICOMER',1,'GT',138420,'ERIVAS',GETDATE(),NULL,NULL,119,'Curacao Rooselveth 3705'
,11,'GUATEMALA','GUATEMALA','24208240','ALMACENES SIMAN SA')


-- CHILITO MIO

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('CHILITO MIO', 'CHILITO MIO', '@gmail.com','^.*solicitud.*$','^andreanicolle.m@gmail.com|danimpazg@gmail.com$','^envios_.*\.xls$','CHILITO MIO')

-- PUNTO 1
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14009,'CHILITO MIO ZONA 17',1,'GT',138427,'ERIVAS',GETDATE(),NULL,NULL,154,''
,17,'GUATEMALA','GUATEMALA','45614272','CHILITO MIO')

-- PUNTO 2

INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14010,'CHILITO MIO ZONA 16',1,'GT',138426,'ERIVAS',GETDATE(),NULL,NULL,154,''
,16,'GUATEMALA','GUATEMALA','30238238','CHILITO MIO')


-- SOFIA MENENDEZ

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('SOFIA MENENDEZ', 'SOFIA MENENDEZ', '@gmail.com','^.*solicitud.*$','^beauteshopmy@gmail.com$','^envios_.*\.xls$','SOFIA MENENDEZ')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14015,'M&Y BEAUTE',1,'GT',138425,'ERIVAS',GETDATE(),NULL,NULL,155,''
,8,'MIXCO','GUATEMALA','58787748','SOFIA MENENDEZ')


-- IMPORTADORA MEDICA,S.A.

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('IMPORTADORA MEDICA,S.A.', 'IMPORTADORA MEDICA,S.A.', '@impomedsa.com','^.*solicitud.*$','^([\w\.\-]+)@impomedsa.com$','^envios_.*\.xls$','IMPORTADORA MEDICA')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14020,'IMPOMED',1,'GT',138431,'ERIVAS',GETDATE(),NULL,NULL,156,'23 Calle 14-58, Edificio Crece Torre 1 Bodega DL3'
,4,'MIXCO','GUATEMALA','23163602','IMPOMED')


-- ENIO LOPEZ

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('ENIO LOPEZ', 'ENIO LOPEZ', '@gmail.com','^.*solicitud.*$','^eniojoselopez@gmail.com$','^envios_.*\.xls$','ENIO LOPEZ')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14025,'ENIO LOPEZ',1,'GT',138422,'ERIVAS',GETDATE(),NULL,NULL,157,''
,8,'MIXCO','GUATEMALA','49142859','ENIO LOPEZ')


-- BEAUTIFUL GIRL

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('BEAUTIFUL GIRL', 'BEAUTIFUL GIRL', '@gmail.com','^.*solicitud.*$','^cosmeticos.girlbeautiful610@gmail.com$','^envios_.*\.xls$','BEAUTIFUL GIRL')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14030,'BEAUTIFUL GIRL',1,'GT',138423,'ERIVAS',GETDATE(),NULL,NULL,158,''
,4,'TOTONICAPAN','TOTONICAPAN','40100350','BEAUTIFUL GIRL')


-- MISS DELIRIOS

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('MISS DELIRIOS', 'MISS DELIRIOS', '@gmail.com','^.*solicitud.*$','^wendypatriciaaldanasantos@gmail.com$','^envios_.*\.xls$','MISS DELIRIOS')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14035,'MISS DELIRIOS',1,'GT',138424,'ERIVAS',GETDATE(),NULL,NULL,159,''
,0,'VILLA CANALES','GUATEMALA','33269960 / 32246165','MISS DELIRIOS')


-- ELEGANCE

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('ELEGANCE', 'ELEGANCE', '@gmail.com','^.*solicitud.*$','^elegancejoyeriagt@gmail.com$','^envios_.*\.xls$','MISS DELIRIOS')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14040,'ELEGANCE',1,'GT',138421,'ERIVAS',GETDATE(),NULL,NULL,160,''
,2,'SAN PEDRO SACATEPEQUEZ','GUATEMALA','32160460','ELEGANCE')


-- RECICLAJES DMT, S.A.

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('RECICLAJES DMT, S.A.', 'RECICLAJES DMT, S.A.', '@vivatek.co','^.*solicitud.*$','^([\w\.\-]+)@vivatek.co$','^envios_.*\.xls$','RECICLAJES DMT')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14045,'VIVATEK',1,'GT',138429,'ERIVAS',GETDATE(),NULL,NULL,161,'Calzada Atanasio Tzul 19-97 Cortijo 1 Bodega 307'
,12,'GUATEMALA','GUATEMALA','23757800','RECICLAJES DMT, S.A.')


-- VENTAS LOCAS XELA

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('VENTAS LOCAS XELA', 'VENTAS LOCAS XELA', '@hotmail.com','^.*solicitud.*$','^metalero-66j@hotmail.com$','^envios_.*\.xls$','VENTAS LOCAS XELA')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14050,'VENTAS LOCAS XELA',1,'GT',138430,'ERIVAS',GETDATE(),NULL,NULL,162,''
,3,'QUETZALTENANGO','QUETZALTENANGO','34183071 / 40790107','VENTAS LOCAS XELA')

















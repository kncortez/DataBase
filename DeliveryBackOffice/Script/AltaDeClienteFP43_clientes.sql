-- FP-41 - ALTA DE CLIENTES Y PUNTOS DE VENTAS


-- VIVIAN GUDIEL

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('VIVIAN GUDIEL', 'VIVIAN GUDIEL', '@gmail.com','^.*solicitud.*$','^jykstore920@gmail.com$','^envios_.*\.xls$','VIVIAN GUDIEL')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14055,'J&K CHILDRENS BOUTIQUE',1,'GT',138439,'ERIVAS',GETDATE(),NULL,NULL,163,''
,8,'MIXCO','GUATEMALA','30756904','VIVIAN GUDIEL')


-- EDMUNDO TUX

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('EDMUNDO TUX', 'EDMUNDO TUX', '@gmail.com','^.*solicitud.*$','^notimundoregionnorte@gmail.com$','^envios_.*\.xls$','EDMUNDO TUX')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14060,'PUNTO EXPRESS',1,'GT',138436,'ERIVAS',GETDATE(),NULL,NULL,164,''
,0,'PETEN','PETEN','45107919 / 44957060','EDMUNDO TUX')


-- MARTA GALVEZ

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('MARTA GALVEZ', 'MARTA GALVEZ', '@gmail.com','^.*solicitud.*$','^silvitacc17@gmail.com$','^envios_.*\.xls$','MARTA GALVEZ')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14065,'FREDERICK DE GUATEMALA',1,'GT',138437,'ERIVAS',GETDATE(),NULL,NULL,165,''
,4,'MIXCO','GUATEMALA','55581421','MARTA GALVEZ')


-- JOSE MIGUEL CALDERON

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('JOSE MIGUEL CALDERON', 'JOSE MIGUEL CALDERON', '@hotmail.com','^.*solicitud.*$','^calderon_3-4-91@hotmail.com$','^envios_.*\.xls$','JOSE CALDERON')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14075,'ViAn GAMES',1,'GT',138452,'ERIVAS',GETDATE(),NULL,NULL,166,''
,9,'QUETZALTENANGO','QUETZALTENANGO','46215996','JOSE CALDERON')


-- LUXURY CONCEPT GUATEMALA S.A.

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('LUXURY CONCEPT GUATEMALA S.A.', 'LUXURY CONCEPT GUATEMALA S.A.', '@gmail.com','^.*solicitud.*$','^ysifranco01@gmail.com$','^envios_.*\.xls$','LUXURY CONCEPT')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14080,'LUXURY CONCEPT GUATEMALA S.A.',1,'GT',138454,'ERIVAS',GETDATE(),NULL,NULL,167,''
,0,'GUATEMALA','GUATEMALA','54198146 / 22597924','LUXURY CONCEPT')


-- EL REFUGIO DE LA NIÑEX -ONG-

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('EL REFUGIO DE LA NIÑEX -ONG-', 'EL REFUGIO DE LA NIÑEX -ONG-', '@refugiodelaninez.org','^.*solicitud.*$','^([\w\.\-]+)@refugiodelaninez.org$','^envios_.*\.xls$','EL REFUGIO')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14085,'EL REFUGIO DE LA NIÑEX -ONG- XELA',1,'GT',138455,'ERIVAS',GETDATE(),NULL,NULL,168,''
,3,'QUETZALTENANGO','QUETZALTENANGO','57116092','EL REFUGIO DE LA NIÑEX')

INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14086,'EL REFUGIO DE LA NIÑEX -ONG- GUATEMALA',1,'GT',138456,'ERIVAS',GETDATE(),NULL,NULL,168,''
,9,'GUATEMALA','GUATEMALA','57116092','EL REFUGIO DE LA NIÑEX')

INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14087,'EL REFUGIO DE LA NIÑEX -ONG- QUICHE',1,'GT',138458,'ERIVAS',GETDATE(),NULL,NULL,168,''
,2,'SANTA CRUZ','QUICHE','33095488','EL REFUGIO DE LA NIÑEX')

INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14088,'EL REFUGIO DE LA NIÑEX -ONG- HUEHUETENANGO',1,'GT',138457,'ERIVAS',GETDATE(),NULL,NULL,168,''
,2,'HUEHUETENANGO','HUEHUETENANGO','49879223','EL REFUGIO DE LA NIÑEX')


-- CLYDE.GT

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('CLYDE.GT', 'CLYDE.GT', '@gmail.com','^.*solicitud.*$','^emmanuelgodinez28@gmail.com$','^envios_.*\.xls$','CLYDE.GT')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14093,'CLYDE.GT',1,'GT',138459,'ERIVAS',GETDATE(),NULL,NULL,169,''
,1,'SAN ANTONIO AGUAS CALIENTES','SACATEPEQUEZ','35318791','CLYDE.GT')


-- JONATHAN HERNANDEZ

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('JONATHAN HERNANDEZ', 'JONATHAN HERNANDEZ', '@decoplacgt.com','^.*solicitud.*$','^([\w\.\-]+)@decoplacgt.com$','^envios_.*\.xls$','JONATHAN HERNANDEZ')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14098,'DECOPLAC',1,'GT',138467,'ERIVAS',GETDATE(),NULL,NULL,170,''
,2,'VILLA NUEVA','GUATEMALA','59259437','JONATHAN HERNANDEZ')


-- HEBERT HERNANDEZ

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('HEBERT HERNANDEZ', 'HEBERT HERNANDEZ', '@gmail.com','^.*solicitud.*$','hebert.hernande@gmail.com$','^envios_.*\.xls$','HEBERT HERNANDEZ')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14108,'GRUAS ROLDAN',1,'GT',138466,'ERIVAS',GETDATE(),NULL,NULL,171,''
,0,'ESCUINTLA','ESCUINTLA','35113068','HEBERT HERNANDEZ')


-- FABRITEX GUATEMALA

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('FABRITEX GUATEMALA', 'FABRITEX GUATEMALA', '@gmail.com','^.*solicitud.*$','itcoinfor@gmail.com$','^envios_.*\.xls$','FABRITEX GUATEMALA')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14113,'IT COLLECTIONS',1,'GT',138463,'ERIVAS',GETDATE(),NULL,NULL,172,''
,3,'MIXCO','GUATEMALA','52020111','FABRITEX GUATEMALA')


-- HAIKAI

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('HAIKAI', 'HAIKAI', '@gmail.com','^.*solicitud.*$','haikami28@gmail.com$','^envios_.*\.xls$','HAIKAI')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14118,'HAIKAI',1,'GT',138461,'ERIVAS',GETDATE(),NULL,NULL,173,''
,6,'MIXCO','GUATEMALA','50138919','HAIKAI')


-- ANIMAL ONLINE 

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('ANIMAL ONLINE', 'ANIMAL ONLINE', '@gmail.com','^.*solicitud.*$','jdom2186@gmail.com$','^envios_.*\.xls$','ANIMAL ONLINE')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14123,'ANIMAL ONLINE',1,'GT',138460,'ERIVAS',GETDATE(),NULL,NULL,174,''
,6,'QUETZALTENANGO','QUETZALTENANGO','42244590','ANIMAL ONLINE')


-- CASCO LOCO GT 

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('CASCO LOCO GT', 'CASCO LOCO GT', '@hotmail.com','^.*solicitud.*$','seco070781@hotmail.com$','^envios_.*\.xls$','CASCO LOCO GT')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14128,'CASCO LOCO GT',1,'GT',138471,'ERIVAS',GETDATE(),NULL,NULL,175,''
,3,'VILLA NUEVA','GUATEMALA','52520233','CASCO LOCO GT')


-- Vi Mi ELECTRONICS

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('Vi Mi ELECTRONICS', 'Vi Mi ELECTRONICS', '@gmail.com','^.*solicitud.*$','vimielectronics2@gmail.com$','^envios_.*\.xls$','Vi Mi ELECTRONICS')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14133,'Vi Mi ELECTRONICS',1,'GT',138474,'ERIVAS',GETDATE(),NULL,NULL,176,''
,5,'GUATEMALA','GUATEMALA','36525739','Vi Mi ELECTRONICS')


-- DIEGO TIÑO

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('DIEGO TIÑO', 'DIEGO TIÑO', '@gmail.com','^.*solicitud.*$','diego.gamez1992@gmail.com$','^envios_.*\.xls$','DIEGO TIÑO')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14138,'DIEGO TIÑO',1,'GT',138472,'ERIVAS',GETDATE(),NULL,NULL,177,''
,12,'PETAPA','GUATEMALA','42725226','DIEGO TIÑO')


-- NATALY

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('NATALY', 'NATALY', '@gmail.com','^.*solicitud.*$','sirlymazariegos22@gmail.com$','^envios_.*\.xls$','NATALY')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14143,'NATALY',1,'GT',138473,'ERIVAS',GETDATE(),NULL,NULL,178,''
,0,'SAN ANDRES VILLA SECA','RETALHULEU','54558346','NATALY')


-- TU MARCA TU ESTILO

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('TU MARCA TU ESTILO', 'TU MARCA TU ESTILO', '@gmail.com','^.*solicitud.*$','luisanatiorellana@gmail.com$','^envios_.*\.xls$','TU MARCA TU ESTILO')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14148,'TU MARCA TU ESTILO',1,'GT',138475,'ERIVAS',GETDATE(),NULL,NULL,179,''
,5,'VILLA NUEVA','GUATEMALA','45145906','TU MARCA TU ESTILO')





-- ALMACENES SIMAN SOCIEDAD ANONIMA

-- PUNTO 1
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14148,'RADIO SHACK /UNICOMER',1,'GT',138432,'ERIVAS',GETDATE(),NULL,NULL,119,'Calzada rooselvet 25-50 centro comercial peri roosvelt, local 25'
,7,'GUATEMALA','GUATEMALA','24728323','RADIO SHACK /UNICOMER')

-- PUNTO 2
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14149,'CURACARO SAN CRISTOBAL/UNICOMER',1,'GT',138470,'ERIVAS',GETDATE(),NULL,NULL,119,'3 calle 13-09 sector b1 ciudad san cristobal'
,8,'MIXCO','GUATEMALA','2480-8295 /99','CURACARO SAN CRISTOBAL/UNICOMER')

-- PUNTO 3
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14150,'CURACAO SEXTA AVENIDA/UNICOMER',1,'GT',138478,'ERIVAS',GETDATE(),NULL,NULL,119,'6 avenida 13-00 zona 1   6 avenida 13-00'
,1,'GUATEMALA','GUATEMALA','23822000','CURACAO SEXTA AVENIDA/UNICOMER')


-- PUNTO 4
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14151,'CURACAO PLAZUELA/UNICOMER',1,'GT',138479,'ERIVAS',GETDATE(),NULL,NULL,119,'12 calle 7-56'
,9,'GUATEMALA','GUATEMALA','24202996','CURACAO PLAZUELA/UNICOMER')


-- VENTAS UNIDAS LIMITADAS

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('VENTAS UNIDAS LIMITADAS', 'VENTAS UNIDAS LIMITADAS', '@ventasunidas.com','^.*solicitud.*$','^([\w\.\-]+)@ventasunidas.com$','^envios_.*\.xls$','VENTAS UNIDAS LIMITADAS')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14156,'VENTAS UNIDAS',1,'GT',138451,'ERIVAS',GETDATE(),NULL,NULL,180,'Avenida petapa 53-00'
,12,'GUATEMALA','GUATEMALA','24171530 / 24171500','VENTAS UNIDAS LIMITADAS')


-- ZONA MANGO

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('ZONA MANGO', 'ZONA MANGO', '@hotmail.com','^.*solicitud.*$','^zonamango@hotmail.com$','^envios_.*\.xls$','ZONA MANGO')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14161,'ZONA MANGO',1,'GT',138450,'ERIVAS',GETDATE(),NULL,NULL,181,'Sector 2, bloque b, lote 23, colonia salud publica'
,17,'GUATEMALA','GUATEMALA','22350671','ZONA MANGO')


-- MONSTER GARAGE

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('MONSTER GARAGE', 'MONSTER GARAGE', '@gmail.com','^.*solicitud.*$','^jaimejo.yong@gmail.com$','^envios_.*\.xls$','MONSTER GARAGE')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14166,'MONSTER GARAGE',1,'GT',138438,'ERIVAS',GETDATE(),NULL,NULL,182,''
,7,'VILLA NUEVA','GUATEMALA','30391318','MONSTER GARAGE')


-- DOT DOT S,A.

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('DOT DOT S,A.', 'DOT DOT S,A.', '@brandsofguatemala.com','^.*solicitud.*$','^([\w\.\-]+)@brandsofguatemala.com$','^envios_.*\.xls$','DOT DOT S,A.')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14171,'BRANDS OF GUATEMALA',1,'GT',138468,'ERIVAS',GETDATE(),NULL,NULL,183,'Ave. Las Américas 20-93 Guatemala'
,14,'GUATEMALA','GUATEMALA','40125382','DOT DOT')


-- EVOLUING

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('EVOLUING', 'EVOLUING', '@gmail.com','^.*solicitud.*$','helencita2015@gmail.com$','^envios_.*\.xls$','EVOLUING')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14176,'EVOLUING',1,'GT',138465,'ERIVAS',GETDATE(),NULL,NULL,184,''
,5,'VILLA NUEVA','GUATEMALA','58525450','EVOLUING')


-- CAN AM CENTROAMÉRICA, S.A.

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
VALUES ('CAN AM CENTROAMÉRICA, S.A.', 'CAN AM CENTROAMÉRICA, S.A.', '@gruporolsa.com','^.*solicitud.*$','^([\w\.\-]+)@gruporolsa.com$','^envios_.*\.xls$','CAN CENTROAMERICA')
  
INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14181,'CAN AM CENTROAMÉRICA, S.A.',1,'GT',138464,'ERIVAS',GETDATE(),NULL,NULL,185,'10 ave  16-38 Guatemala'
,10,'GUATEMALA','GUATEMALA','23005051','CAN AM CENTROAMERICA')

















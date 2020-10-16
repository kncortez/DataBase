  -- VALERÍA DE LEÓN
  INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
  VALUES ('VALERIA DE LEON', 'VALERIA DE LEON', '@gmail.com','^.*solicitud.*$','^valery.lm.6@gmail.com$','^envios_.*\.xls$','VALERIA DE LEON')
  
  INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
  [DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
  VALUES (13572,'LITTLE ANGELS BOUTIQUE',1,'GT',138208,'ERIVAS',GETDATE(),NULL,NULL,64,'21 ave 2-49'
  ,1,'QUETZALTENANGO','QUETZALTENANGO',360667387 / 55445973,'VALERIA DE LEON')
  
    -- RAPI EXPRESS
  INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
  VALUES ('RAPI EXPRESS', 'RAPI EXPRESS', '@gmail.com','^.*solicitud.*$','^krvh132127@gmail.com$','^envios_.*\.xls$','RAPI EXPRESS')
  
  INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
  [DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
  VALUES (13577,'RAPI EXPRESS',1,'GT',138207,'ERIVAS',GETDATE(),NULL,NULL,65,'7a ave 3-64 Col. Aceituno'
  ,2,'MAZATENANGO','SUCHITEPÉQUEZ',59231230,'RAPI EXPRESS')
  
    -- GABRIELA MÉNDEZ
  INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
  VALUES ('GABRIELA MENDEZ', 'GABRIELA MENDEZ', '@gmail.com','^.*solicitud.*$','^mendez.agabriela@gmail.com$','^envios_.*\.xls$','GABRIELA MENDEZ')
  
  INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
  [DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
  VALUES (13582,'AMARILLO STORE',1,'GT',138206,'ERIVAS',GETDATE(),NULL,NULL,66,'Ciudad'
  ,11,'MIXCO','GUATEMALA',59230364,'GABRIELA MENDEZ')
  
    -- ULTRACEM GUATEMALA, S.A.
  INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
  VALUES ('ULTRACEM GUATEMALA, S.A.', 'ULTRACEM GUATEMALA, S.A.', '@ultracem.gt','^.*solicitud.*$','^([\w\.\-]+)@ultracem.gt$','^envios_.*\.xls$','ULTRACEM GT')
  
  INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
  [DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
  VALUES (13587,'ULTRACEM GUATEMALA, S.A.',1,'GT',138214,'ERIVAS',GETDATE(),NULL,NULL,67,'2a calle 23-80 Vista Hermosa II, Edif. Avante Of. 703'
  ,15,'GUATEMALA','GUATEMALA',32903316,'ULTRACEM')
  
  -- FASHIONISTA GT
  INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
  VALUES ('FASHIONISTA GT', 'FASHIONISTA GT', '@gmail.com','^.*solicitud.*$','^villapaola93@gmail.com$','^envios_.*\.xls$','FASHIONISTA GT')
  
  INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
  [DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
  VALUES (13592,'FASHIONISTA GT',1,'GT',138209,'ERIVAS',GETDATE(),NULL,NULL,68,'San Lucas Sacatepéquez'
  ,0,'SAN LUCAS SACATEPÉQUEZ','GUATEMALA',30410476,'FASHIONISTA GT')
  
  -- MICHELLE ARAUZ
  INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
  VALUES ('MICHELLE ARAUZ', 'MICHELLE ARAUZ', '@gmail.com','^.*solicitud.*$','^michellearauzgt@gmail.com$','^envios_.*\.xls$','MICHELLE ARAUZ')
  
  INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
  [DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
  VALUES (13597,'WOU STORE',1,'GT',138210,'ERIVAS',GETDATE(),NULL,NULL,69,'Ciudad de Guatemala'
  ,0,'GUATEMALA','GUATEMALA',30140187,'MICHELLE ARAUZ')
  
  -- LUIS PEDRO LETONA
  INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
  VALUES ('LUIS PEDRO LETONA', 'LUIS PEDRO LETONA', '@gmail.com','^.*solicitud.*$','^luispe.letona@gmail.com$','^envios_.*\.xls$','LUIS LETONA')
  
  INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
  [DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
  VALUES (13602,'GROOMS SHOP',1,'GT',138212,'ERIVAS',GETDATE(),NULL,NULL,70,'Ciudad'
  ,3,'GUATEMALA','GUATEMALA',58597474,'LUIS LETONA')
  
    -- COMERCIAL LYC
  INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
  VALUES ('COMERCIAL LYC', 'COMERCIAL LYC', '@gmail.com','^.*solicitud.*$','^yoellarios23@gmail.com$','^envios_.*\.xls$','COMERCIAL LYC')
  
  INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
  [DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
  VALUES (13607,'COMERCIAL LYC',1,'GT',138213,'ERIVAS',GETDATE(),NULL,NULL,71,'Aldea Casa de Pinto, Rio Hondo, Zacapa'
  ,0,'RIO HONDO','ZACAPA',58647245,'COMERCIAL LYC')
  
  -- DISTRIBUIDORA CKLASS Y MÁS
  INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
  VALUES ('DISTRIBUIDORA CKLASS Y MÁS', 'DISTRIBUIDORA CKLASS Y MÁS', '@gmail.com','^.*solicitud.*$','^alisoncorado1@gmail.com$','^envios_.*\.xls$','DISTRIBUIDORA CKLASS')
  
  INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
  [DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
  VALUES (13612,'DISTRIBUIDORA CKLASS Y MÁS',1,'GT',138225,'ERIVAS',GETDATE(),NULL,NULL,72,''
  ,0,'ATESCATEMPA','JUTIAPA',45386003,'DISTRIBUIDORA CKLASS Y MÁS')
  
  -- FIN FEATURE 33
  
  -- INICIO FEATURE 34 - ALTA 5 CLIENTES
  
  
    -- CORPORACIÓN DGO, S.A.
  INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
  VALUES ('CORPORACIÓN DGO, S.A.', 'CORPORACIÓN DGO, S.A.', '@emaguatemala.com','^.*solicitud.*$','^([\w\.\-]+)@emaguatemala.com$','^envios_.*\.xls$','CORPORACION DGO')
  
  INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
  [DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
  VALUES (13617,'CORPORACIÓN DGO, S.A.',1,'GT',138221,'ERIVAS',GETDATE(),NULL,NULL,73,''
  ,6,'MIXCO','GUATEMALA',56338467 / 55175636,'CORPORACIÓN DGO')
  
    -- HELO DIGITAL
  INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
  VALUES ('HELO DIGITAL', 'HELO DIGITAL', '@gmail.com','^.*solicitud.*$','^helopez0105@gmail.com$','^envios_.*\.xls$','HELO DIGITAL')
  
  INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
  [DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
  VALUES (13622,'HELO DIGITAL',1,'GT',138222,'ERIVAS',GETDATE(),NULL,NULL,74,''
  ,6,'MIXCO','GUATEMALA',37409253,'HELO DIGITAL')
  
  -- COSAS MARAVILLOSAS GT
  INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
  VALUES ('COSAS MARAVILLOSAS GT', 'COSAS MARAVILLOSAS GT', '@yahoo.com','^.*solicitud.*$','^jdtica1007@yahoo.com$','^envios_.*\.xls$','COSAS MARAVILLOSAS')
  
  INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
  [DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
  VALUES (13627,'COSAS MARAVILLOSAS GT',1,'GT',138223,'ERIVAS',GETDATE(),NULL,NULL,75,''
  ,12,'GUATEMALA','GUATEMALA',43746811,'COSAS MARAVILLOSAS GT')
  
  -- ZAFRA
  INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
  VALUES ('ZAFRA', 'ZAFRA', '@gmail.com','^.*solicitud.*$','^agendajosuehurtado@gmail.com$','^envios_.*\.xls$','ZAFRA')
  
  INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
  [DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
  VALUES (13632,'ZAFRA',1,'GT',138226,'ERIVAS',GETDATE(),NULL,NULL,76,''
  ,1,'CHIQUIMULA','CHIQUIMULA',47253064,'ZAFRA')
  
  -- PREVOLUCIÓN, S.A.
  INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
  VALUES ('PREVOLUCIÓN, S.A.', 'PREVOLUCIÓN, S.A.', '@prevolucion.com','^.*solicitud.*$','^([\w\.\-]+)@prevolucion.com$','^envios_.*\.xls$','PREVOLUCION SA')
  
  INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
  [DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
  VALUES (13637,'PREVOLUCIÓN, S.A.',1,'GT',138224,'ERIVAS',GETDATE(),NULL,NULL,77,''
  ,8,'MIXCO','GUATEMALA',59954556,'PREVOLUCION S.A.')
  
  -- INSTAHOGARGT
  INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
  VALUES ('INSTAHOGARGT', 'INSTAHOGARGT', '@hotmail.es','^.*solicitud.*$','^bebe8mar@hotmail.es$','^envios_.*\.xls$','INSTAHOGARGT')
  
  INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
  [DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
  VALUES (13642,'INSTAHOGARGT',1,'GT',138238,'ERIVAS',GETDATE(),NULL,NULL,78,'1 Avenida 3-34'
  ,1,'FRAIJANES','GUATEMALA',58063510 / 54126372,'INSTAHOGARGT')
  
  -- CORPORACION FATIMA, S.A.
  INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
  VALUES ('CORPORACION FATIMA, S.A.', 'CORPORACION FATIMA, S.A.', '@fatima.com.gt','^.*solicitud.*$','^([\w\.\-]+)@fatima.com.gt$','^envios_.*\.xls$','CORPORACION FATIMA')
  
  INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
  [DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
  VALUES (13647,'CORPORACION FATIMA, S.A.',1,'GT',138239,'ERIVAS',GETDATE(),NULL,NULL,79,'31 Calle 25-56 Calzada Atanasio Tzul'
  ,12,'GUATEMALA','GUATEMALA',23838100,'CORPORACION FATIMA')
  
  -- AHK89 COPROPIEDAD
  INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
  VALUES ('AHK89 COPROPIEDAD', 'AHK89 COPROPIEDAD', '@molvu.com','^.*solicitud.*$','^([\w\.\-]+)@molvu.com$','^envios_.*\.xls$','AHK89 COPROPIEDAD')
  
  INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
  [DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
  VALUES (13652,'AHK89 COPROPIEDAD',1,'GT',138241,'ERIVAS',GETDATE(),NULL,NULL,80,'Via 4 1-30 Zona Edificio Tec 1, 2 Nivel Oficina 210'
  ,0,'GUATEMALA','GUATEMALA',22183152,'AHK89 COPROPIEDAD')
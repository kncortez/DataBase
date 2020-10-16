  -- INICIO FEATURE 34 - ALTA 5 CLIENTES
  -- v2 - SQL
  
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
  VALUES (13652,'AHK89 COPROPIEDAD',1,'GT',138241,'ERIVAS',GETDATE(),NULL,NULL,80,'Vía 4 1-30 Zona 4 Edificio Tec 1, 2 Nivel Oficina 210'
  ,0,'GUATEMALA','GUATEMALA',22183152,'AHK89 COPROPIEDAD')
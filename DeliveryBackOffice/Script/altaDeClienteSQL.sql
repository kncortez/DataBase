  -- ZAPATERIA PUNTO CASUAL METAMERCADO CLIENTE Y PUNTO DE VENTA #1
  INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
  VALUES ('ZAPATERIA PUNTO CASUAL', 'ZAPATERIA PUNTO CASUAL', '@hotmail.com','^.*solicitud.*$','^chejo_33@hotmail.com$','^envios_.*\.xls$','ZAPATERIA METAMERCADO')
  
  INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
  [DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
  VALUES (13561,'ZAPATERIA PUNTO CASUAL METAMERCADO',1,'GT',138202,'ERIVAS',GETDATE(),NULL,NULL,62,'Metamercado Mixco San Juan local 294 y 295'
  ,4,'MIXCO','GUATEMALA',0,'ZAPATERIA PUNTO CASUAL')

    -- ZAPATERIA PUNTO CASUAL SAN CRISTÓBAL PUNTO DE VENTA #2
  
  INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
  [DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
  VALUES (13562,'ZAPATERIA PUNTO CASUAL SAN CRISTÓBAL',1,'GT',138203,'ERIVAS',GETDATE(),NULL,NULL,62,'5 Calle 6-24 Sector C1 San Cristóbal'
  ,8,'MIXCO','GUATEMALA',54280683,'ZAPATERIA PUNTO CASUAL')
  
  -- VIRUTAS GT
  INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
  VALUES ('VIRUS GT', 'VIRUS GT', '@gmail.com','^.*solicitud.*$','^virutasgt@gmail.com$','^envios_.*\.xls$','VIRUTAS GT')
  
  INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
  [DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
  VALUES (13567,'VIRUTAS GT',1,'GT',138201,'ERIVAS',GETDATE(),NULL,NULL,63,'Km 14.5 Carr. al Pacífico San Mateo 2 casa F10'
  ,4,'VILLA NUEVA','GUATEMALA',50502490,'VIRUTAS GT')
  
  
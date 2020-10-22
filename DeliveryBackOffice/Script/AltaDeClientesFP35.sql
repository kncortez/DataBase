--FP 35 - Alta 12 Clientes

-- DIVINA'S SHOE
  INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
  VALUES ('DIVINAS SHOE', 'DIVINAS SHOE', '@hotmail.com','^.*solicitud.*$','^rosamaru1_1994@hotmail.com$','^envios_.*\.xls$','DIVINAS SHOE')
  
  INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
  [DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
  VALUES (13657,'DIVINAS SHOE',1,'GT',138265,'ERIVAS',GETDATE(),NULL,NULL,81,''
  ,3,'GUATEMALA','GUATEMALA',59880333,'DIVINAS SHOE')
  
  
  -- CARLOS ALEJANDRO MORALES VEGA
  INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
  VALUES ('CARLOS ALEJANDRO MORALES VEGA', 'CARLOS ALEJANDRO MORALES VEGA', '@gmail.com','^.*solicitud.*$','^camv.040694@gmail.com$','^envios_.*\.xls$','CARLOS MORALES')
  
  INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
  [DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
  VALUES (13662,'CARLOS ALEJANDRO MORALES VEGA',1,'GT',138267,'ERIVAS',GETDATE(),NULL,NULL,82,''
  ,6,'VILLA NUEVA','GUATEMALA',52589407,'CARLOS MORALES')
  
  
  -- HECHO A MANO
  INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
  VALUES ('HECHO A MANO', 'HECHO A MANO', '@gmail.com','^.*solicitud.*$','^aliceediazs26@gmail.com$','^envios_.*\.xls$','HECHO A MANO')
  
  INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
  [DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
  VALUES (13667,'HECHO A MANO',1,'GT',138266,'ERIVAS',GETDATE(),NULL,NULL,83,''
  ,8,'MIXCO','GUATEMALA',55950914,'HECHO A MANO')
  
  
   -- TIENDA 365
  INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
  VALUES ('TIENDA 365', 'TIENDA 365', '@gmail.com','^.*solicitud.*$','^tienda365@guatemala@gmail.com$','^envios_.*\.xls$','TIENDA 365')
  
  INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
  [DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
  VALUES (13672,'TIENDA 365',1,'GT',138263,'ERIVAS',GETDATE(),NULL,NULL,84,'San Miguel Petapa, Guatemala'
  ,0,'GUATEMALA','GUATEMALA',37611661,'TIENDA 365')
  
  
   -- BYRON ESTUARDO MARROQUIN CASTRO
  INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
  VALUES ('BYRON ESTUARDO MARROQUIN CASTRO', 'BYRON ESTUARDO MARROQUIN CASTRO', '@gmail.com','^.*solicitud.*$','^castro.byron878@gmail.com$','^envios_.*\.xls$','BYRON MARROQUIN')
  
  INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
  [DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
  VALUES (13677,'CAS MAR',1,'GT',138264,'ERIVAS',GETDATE(),NULL,NULL,85,''
  ,11,'GUATEMALA','GUATEMALA',54370130,'BYRON ESTUARDO')
  
  
   -- TOMAX, S.A.
  INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
  VALUES ('TOMAX, S.A.', 'TOMAX, S.A.', '@gmail.com','^.*solicitud.*$','^tomaxguate@gmail.com$','^envios_.*\.xls$','TOMAX, S.A.')
  
  INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
  [DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
  VALUES (13682,'TOMAX, S.A.',1,'GT',138268,'ERIVAS',GETDATE(),NULL,NULL,86,''
  ,12,'GUATEMALA','GUATEMALA',56917239,'TOMAX, S.A.')
  
  
  -- TEXTILES LO NUESTRO
  INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
  VALUES ('TEXTILES LO NUESTRO', 'TEXTILES LO NUESTRO', '@gmail.com','^.*solicitud.*$','^recinosbeder@gmail.com$','^envios_.*\.xls$','TEXTILES')
  
  INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
  [DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
  VALUES (13687,'TEXTILES LO NUESTRO',1,'GT',138256,'ERIVAS',GETDATE(),NULL,NULL,87,''
  ,8,'HUEHUETENANGO','HUEHUETENANGO',45408065,'TEXTILES LO NUESTRO')
  
  
  -- D-ART GUATEMALA
  INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
  VALUES ('D-ART GUATEMALA', 'D-ART GUATEMALA', '@gmail.com','^.*solicitud.*$','^d.artguatemala@gmail.com$','^envios_.*\.xls$','D-ART GT')
  
  INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
  [DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
  VALUES (13692,'D-ART GUATEMALA',1,'GT',138258,'ERIVAS',GETDATE(),NULL,NULL,88,''
  ,9,'MIXCO','GUATEMALA',58806014 / 30193411,'D-ART GUATEMALA')
  
  
   -- ANDRES OCHOA
  INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
  VALUES ('ANDRES OCHOA', 'ANDRES OCHOA', '@hotmail.com','^.*solicitud.*$','^nordic8a69@hotmail.com$','^envios_.*\.xls$','ANDRES OCHOA')
  
  INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
  [DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
  VALUES (13697,'MULTI SERVICIOS SPEED NET',1,'GT',138257,'ERIVAS',GETDATE(),NULL,NULL,89,'Puerto San José'
  ,0,'SAN JOSÉ','ESCUINTLA',56304405,'ANDRES OCHOA')
  
  
  -- SANDY PEREZ
  INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
  VALUES ('SANDY PEREZ', 'SANDY PEREZ', '@gmail.com','^.*solicitud.*$','^julisspz1992@gmail.com$','^envios_.*\.xls$','SANDY PEREZ')
  
  INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
  [DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
  VALUES (13702,'SANDALIAS A LA MODA',1,'GT',138244,'ERIVAS',GETDATE(),NULL,NULL,90,'Colonia Quinta Samayoa, Ciudad de Guatemala'
  ,7,'GUATEMALA','GUATEMALA',59330027,'SANDY PEREZ')
  
  
    -- ARGO INVERSIONES INDUSTRIALES
  INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
  VALUES ('ARGO INVERSIONES INDUSTRIALES', 'ARGO INVERSIONES INDUSTRIALES', '@argo-inversiones.com','^.*solicitud.*$','^([\w\.\-]+)@argo-inversiones.gt$','^envios_.*\.xls$','ARGO')
  
  INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
  [DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
  VALUES (13707,'ARGO INVERSIONES INDUSTRIALES',1,'GT',138245,'ERIVAS',GETDATE(),NULL,NULL,91,''
  ,15,'GUATEMALA','GUATEMALA',41582046,'ARGO INVERSIONES INDUSTRIALES')
  

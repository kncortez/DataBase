  -- HEALTHCARE GT: NUEVO CLIENTE Y NUEVO PUNTO
  INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
  VALUES ('HEALTHCARE GT', 'HEALTHCARE GT', '@hotmail.com','^.*solicitud.*$','^eliquan91@hotmail.com$','^envios_.*\.xls$','HEALTHCARE')
  INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
  VALUES (13275,'HealthCare GT',1,'GT',137854,'CCANO',GETDATE(),NULL,NULL,16,NULL,NULL,NULL,NULL,NULL,NULL)

  -- PEPE & MORE: NUEVO PUNTO
  INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
  VALUES (13256,'Pepe & More Boca del Monte',1,'GT',137852,'CCANO',GETDATE(),NULL,NULL,12,NULL,NULL,NULL,NULL,NULL,NULL)

  -- SANTILLANA: NUEVO CLIENTE Y NUEVO PUNTO
  INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
  VALUES ('EDITORIAL SANTILLANA', 'EDITORIAL SANTILLANA', '@santillana.com','^.*solicitud.*$','^([\w\.\-]+)@.santillana.com$','^envios_.*\.xls$','SANTILLANA')
  INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
  VALUES (13280,'Editorial Santillana',1,'GT',137866,'CCANO',GETDATE(),NULL,NULL,17,NULL,NULL,NULL,NULL,NULL,NULL)

  -- WATE NEEDS: NUEVO CLIENTE Y NUEVO PUNTO
  INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
  VALUES ('WATE NEEDS', 'WATE NEEDS', '@gmail.com','^.*solicitud.*$','^asturias.sebastian@gmail.com$','^envios_.*\.xls$','WATE NEEDS')
  INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
  VALUES (13285,'Wate Needs',1,'GT',137891,'CCANO',GETDATE(),NULL,NULL,18,NULL,NULL,NULL,NULL,NULL,NULL)
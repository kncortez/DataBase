  INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
  VALUES ('DISTRIBUIDOR INMUNOTEC ID 1640845 EB', 'DISTRIBUIDOR INMUNOTEC', '@gmail.com','^.*solicitud.*$','^margarita.arrivillaga@gmail.com$','^envios_.*\.xls$','INMUNOTEC')
  INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
  VALUES (13400,'DISTRIBUIDOR INMUNOTEC ID1640845 EB',1,'GT',138027,'CCANO',GETDATE(),NULL,NULL,30,NULL,NULL,NULL,NULL,NULL,NULL)

  INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
  VALUES ('ONLINE VARIEDADES', 'ONLINE VARIEDADES', '@gmail.com','^.*solicitud.*$','^princjohana.2009@gmail.com$','^envios_.*\.xls$','ONLINE VARIEDADES')
  INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
  VALUES (13405,'ONLINE VARIEDADES',1,'GT',138021,'CCANO',GETDATE(),NULL,NULL,31,NULL,NULL,NULL,NULL,NULL,NULL)

  INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
  VALUES ('LIBRERÍA LOGOS CAFÉ', 'LIBRERÍA LOGOS CAFÉ', '@hotmail.com','^.*solicitud.*$','^rosales_miguel_@hotmail.com$','^envios_.*\.xls$','LIBRERÍA LOGOS CAFÉ')
  INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
  VALUES (13410,'LIBRERIA LOGOS CAFE',1,'GT',138003,'CCANO',GETDATE(),NULL,NULL,32,NULL,NULL,NULL,NULL,NULL,NULL)
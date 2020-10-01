INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation])   
 VALUES ('ELENA DEL CARMEN AYALA HERNANDEZ', 'ELENA DEL CARMEN AYALA HERNANDEZ', '@gmail.com','^.*solicitud.*$','^ayalaelena95@gmail.com','^envios_.*\.xls$','GTALGOBONITO')
​
 INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation])   
 VALUES ('HYPER SHOP', 'HYPER SHOP', '@labrujulapublicidad.com','^.*solicitud.*$','^([\w\.\-]+)@labrujulapublicidad.com$','^envios_.*\.xls$','HYPER SHOP')
​
  INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])  
  VALUES (13470,'ELENA DEL CARMEN AYALA HERNANDEZ',1,'GT',138112,'CCANO',GETDATE(),NULL,NULL,44,NULL,NULL,NULL,NULL,NULL,NULL)
​
  INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])  
  VALUES (13475,'HYPER SHOP',1,'GT',138111,'CCANO',GETDATE(),NULL,NULL,45,NULL,NULL,NULL,NULL,NULL,NULL)
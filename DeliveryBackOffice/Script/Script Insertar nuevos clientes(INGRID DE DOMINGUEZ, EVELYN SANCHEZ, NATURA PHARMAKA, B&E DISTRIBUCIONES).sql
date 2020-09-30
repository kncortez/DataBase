INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], 
[Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation])  
 VALUES ('INGRID ELIZABETH RODRIGUEZ GARICA DE DOMINGUEZ', 'INGRID DE DOMINGUEZ', '@gmail.com', '^.*solicitud.*$', '^dedominguez.ingrid@gmail.com$', '^envios_.*\.xls$','Ingrid de Domínguez');

 INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ( [CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],
 [VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
 VALUES (13450,'INGRID ELIZABETH RODRIGUEZ GARICA DE DOMINGUEZ', 1,'GT', 138106,'CCANO', GETDATE(), NULL, NULL, 40, '7 Calle 13-32 Quinta Samayoa Apto. C', 7, 'Guatemala', 'Guatemala', '40315208',
 'INGRID DE DOMINGUEZ');

 ---
 
 INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], 
[Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation])  
 VALUES ('EVELYN YOHANA SANCHEZ MERIDA', 'EVELYN SANCHEZ', '@gmail.com', '^.*solicitud.*$', '^anasanz816@gmail.com$', '^envios_.*\.xls$', 'EVELYN SANCHEZ');

 INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ( [CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],
 [VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
 VALUES (13455,'EVELYN YOHANA SANCHEZ MERIDA', 1,'GT', 138107,'CCANO', GETDATE(), NULL, NULL, 41,  '21 Av. final Alameda Norte (extremo de buses transurbanos)', 18, 'Guatemala', 'Guatemala', '59793970',
 'ANASANZ816');

 ---

  INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], 
[Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation])  
 VALUES ('NATURA PHARMAKA', 'NATURA PHARMAKA', '@gmail.com', '^.*solicitud.*$', '^evelynpaniaguag@gmail.com$', '^envios_.*\.xls$', 'NATURA PHARMAKA');

 INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ( [CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],
 [VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
 VALUES (13460,'NATURA PHARMAKA', 1,'GT', 138108,'CCANO', GETDATE(), NULL, NULL, 42,  'Km16.5 Carr. El Salvador, Crece Olmeca, Res. Rancho Verde, Manz.C Sec.I Casa 24', 0, 'Fraijanes', 'Guatemala', '51751300',
 'NATURA PHARMAKA');

 ---

   INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], 
[Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation])  
 VALUES ('B&E DISTRIBUCIONES', 'B&E DISTRIBUCIONES', '@distribucionesbye.com', '^.*solicitud.*$', '^samuel@distribucionesbye.com$', '^envios_.*\.xls$', 'B&E DISTRIBUCIONES');

 INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ( [CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],
 [VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
 VALUES (13465,'B&E DISTRIBUCIONES', 1,'GT', 138109,'CCANO', GETDATE(), NULL, NULL, 43,  '6 Calle A 13-62 Colonia Quinta Samayoa', 7, 'Guatemala', 'Guatemala', '47397152',
 'B&E DISTRIBUCIONES');
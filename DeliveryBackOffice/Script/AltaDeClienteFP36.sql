--FP 36 - Alta 1 Clientes
  
  
    -- PABLO RENE BOBADILLA CASASOLA
  INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject], [RegexEmail], [RegexFilename], [Abbreviation]) 
  VALUES ('PABLO RENÉ BOBADILLA CASASOLA', 'PABLO RENÉ BOBADILLA CASASOLA', '@gmail.com','^.*solicitud.*$','^libroscristianosgt@gmail.com$','^envios_.*\.xls$','PABLO BOBADILLA')
  
  INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],
  [DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
  VALUES (13712,'PABLO RENÉ BOBADILLA CASASOLA',1,'GT',138269,'ERIVAS',GETDATE(),NULL,NULL,96,''
  ,12,'GUATEMALA','GUATEMALA','46959558','PABLO BOBADILLA')
  

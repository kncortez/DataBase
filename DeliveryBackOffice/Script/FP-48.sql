 INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])  
 VALUES (13261,'AURUM & FORCIA',1,'GT',138695,'JHERNANDEZ',GETDATE(),NULL,NULL,13,NULL,NULL,NULL,NULL,NULL,NULL)

 INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])  
 VALUES (13262,'DISTRIBUIDORA 502',1,'GT',138697,'JHERNANDEZ',GETDATE(),NULL,NULL,13,NULL,NULL,NULL,NULL,NULL,NULL)
 
 update [DeliveryBackOffice].[dbo].[Customer] SET RegexEmail = '^guatedepot@icloud.com|aurumyforcia@icloud.com|distribuidora502@icloud.com$' WHERE IdCustomer = 13
 update [DeliveryBackOffice].[dbo].[Customer] SET Name = 'NEGOCIOS CORPORATIVOS HR, S.A.' WHERE IdCustomer = 13
 update [DeliveryBackOffice].[dbo].[Customer] SET Description = 'NEGOCIOS CORPORATIVOS HR, S.A.' WHERE IdCustomer = 13 
 update [DeliveryBackOffice].[dbo].[Customer] SET Abbreviation = 'NEGOCIOS CORPORATIVOS HR' WHERE IdCustomer = 13
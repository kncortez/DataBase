		
INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject],
[RegexEmail], [RegexFilename], [Abbreviation], [COD])
VALUES ('KING TOYS', 'KING TOYS', '@hotmail.com','^.*solicitud.*$','^nancyeli_@hotmail.com$','^envios_.*\.xls$','KING TOYS',1)		

INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject],
[RegexEmail], [RegexFilename], [Abbreviation], [COD])
VALUES ('MYNOR ABRAHAM PEREZ SANTIZO', 'MYNOR ABRAHAM PEREZ SANTIZO', '@gmail.com','^.*solicitud.*$','^perezsantizo23@gmail.com $','^envios_.*\.xls$','MYNOR PEREZ',1)

update [DeliveryBackOffice].[dbo].[Customer] SET RegexEmail = '^sacwup2020@gmail.com|nathaliapaizvillavicenio@gmail.com$' WHERE IdCustomer = 9

INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],
[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14563,'KING TOYS',1,'GT',138731,'JHERNANDEZ',GETDATE(),NULL,NULL,261,NULL,NULL,NULL,NULL,NULL,NULL)

INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],
[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14568,'MYNOR PEREZ',1,'GT',138726,'JHERNANDEZ',GETDATE(),NULL,NULL,262,NULL,NULL,NULL,NULL,NULL,NULL)

INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],
[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (13206,'GRUPO ANMANA, S.A.',1,'GT',138727,'JHERNANDEZ',GETDATE(),NULL,NULL,9,NULL,NULL,NULL,NULL,NULL,NULL)
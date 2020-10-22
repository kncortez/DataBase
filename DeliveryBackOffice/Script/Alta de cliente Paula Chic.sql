		
INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject],
[RegexEmail], [RegexFilename], [Abbreviation])
VALUES ('PAULA CHIC', 'PAULA CHIC', '@gmail.com','^.*solicitud.*$','^dianamaradiagajp@gmail.
com$','^envios_.*\.xls$','PAULACHIC')		



INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],
[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (13480,'ZONA 6',1,'GT',138154,'CGODINEZ',GETDATE(),NULL,NULL,46,NULL,NULL,NULL,NULL,NULL,NULL)



INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],
[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (13481,'ZONA 18',1,'GT',138153,'CGODINEZ',GETDATE(),NULL,NULL,46,NULL,NULL,NULL,NULL,NULL,NULL)
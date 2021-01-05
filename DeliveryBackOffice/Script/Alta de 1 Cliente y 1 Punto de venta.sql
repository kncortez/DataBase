INSERT INTO [DeliveryBackOffice].[dbo].[Customer] ([Name], [Description], [Domain], [RegexSubject],
[RegexEmail], [RegexFilename], [Abbreviation])
VALUES ('INVERSIONES SAMALA, SOCIEDAD ANONIMA', 'INVERSIONES SAMALA', '@outlook.com','^.*solicitud.*$','^glforzadelivery@outlook.com$','^envios_.*\.xls$','INVERSIONES SAMALA')

INSERT INTO [DeliveryBackOffice].[dbo].[VisitPointClient] ([CodeOfReference],[DescriptionOfClient],
[StatusClient],[CountryId],[VisitPointId],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],
[CustomerID],[Address],[Zone],[Town],[Department],[Phone],[ContactName])
VALUES (14643,'GASOLINERAS DON ARTURO',1,'GT',138909,'CCANO',GETDATE(),NULL,NULL,277,NULL,NULL,NULL,NULL,NULL,NULL)
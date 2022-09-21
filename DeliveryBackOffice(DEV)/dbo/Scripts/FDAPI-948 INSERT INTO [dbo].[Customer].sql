USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[Customer] ([Name]
, [Description]
, [Domain]
, [RegexSubject]
, [RegexEmail]
, [RegexFilename]
, [Abbreviation]
, [IdCustomerType]
, [CountryID]
, [DateUpService]
, [RowSatus]
, [TokenCreated]
, [DateCreated])
	VALUES ('Cliente Referenciado', 'Clientes sin usuario', '@forzadelivery', '^.*solicitud.*$', '^test-id@forzalatam.com$', '^envios_.*\.xls$', 'Cliente Referenciado', (SELECT IdCustomerType FROM CustomerType WHERE Description = 'INDIVIDUAL'), 'GT', '2022-09-20 12:36:08.737', 1, 'SYS-OMORALES', '2022-09-20 12:36:08.737')


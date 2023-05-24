USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[ConfigExternalPlatform] ([ExternalPlatformId]
, [ConfigParameterName]
, [ConfigParameterValue]
, [ConfigMaxValidDate]
, [RowStatus]
, [TokenCreated]
, [DateCreated])
	VALUES ((SELECT IdExternalPlatform FROM CatExternalPlatform WHERE NameExternalPlatform = 'HermesInvoiceHelper' AND RowStatus = 1), 'VpCodeOfReference', '999', NULL, 1, 'SYS-OMORALES', GETDATE()),
	((SELECT IdExternalPlatform FROM CatExternalPlatform WHERE NameExternalPlatform = 'HermesInvoiceHelper' AND RowStatus = 1), 'Email', 'cesar.aquino@forzadelivery.com', NULL, 1, 'SYS-OMORALES', GETDATE()),
	((SELECT IdExternalPlatform FROM CatExternalPlatform WHERE NameExternalPlatform = 'HermesInvoiceHelper' AND RowStatus = 1), 'Retries', '5', NULL, 1, 'SYS-OMORALES', GETDATE())
GO

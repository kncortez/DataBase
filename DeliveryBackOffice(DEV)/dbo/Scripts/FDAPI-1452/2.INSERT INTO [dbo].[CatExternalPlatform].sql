USE [DeliveryBackOffice]
GO

	INSERT INTO [dbo].[CatExternalPlatform] ([NameExternalPlatform]
	, [RowStatus]
	, [TokenCreated]
	, [DateCreated])
		VALUES ('HermesInvoiceHelper', 1, 'SYS-OMORALES', GETDATE())
GO


USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[CatExternalPlatform] ([NameExternalPlatform]
, [RowStatus]
, [TokenCreated]
, [DateCreated])
	VALUES ('SMSLinehaulsAct', 1, 'SYS-OMORALES', GETDATE())
GO

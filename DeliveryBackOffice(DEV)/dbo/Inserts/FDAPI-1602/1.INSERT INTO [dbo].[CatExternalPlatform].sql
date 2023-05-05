USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[CatExternalPlatform] ([NameExternalPlatform]
, [RowStatus]
, [TokenCreated]
, [DateCreated])
	VALUES ('SMSTwo-StepVerificationCourierApp', 1, 'SYS-OMORALES', GETDATE())
GO

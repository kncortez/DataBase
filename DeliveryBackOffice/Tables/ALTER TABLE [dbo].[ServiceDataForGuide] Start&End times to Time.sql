USE [DeliveryBackOffice]
GO

ALTER TABLE [DeliveryBackOffice].[dbo].[ServiceDataForGuide] ALTER COLUMN [StartTime] TIME(7);
ALTER TABLE [DeliveryBackOffice].[dbo].[ServiceDataForGuide] ALTER COLUMN [EndTime] TIME(7);
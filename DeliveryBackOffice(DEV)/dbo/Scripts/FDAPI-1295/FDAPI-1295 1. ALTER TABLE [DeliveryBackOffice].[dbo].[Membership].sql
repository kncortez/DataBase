USE [DeliveryBackOffice]
GO

ALTER TABLE [DeliveryBackOffice].[dbo].[Membership]
ADD [AccumulatedPoints] INT NULL

EXECUTE sp_addextendedproperty N'MS_Description', N'Puntos acumulados durante un periodo de vigencia de membresía', N'SCHEMA', N'dbo', N'TABLE', N'Membership', N'COLUMN', N'AccumulatedPoints'
GO

ALTER TABLE [DeliveryBackOffice].[dbo].[Membership]
ADD [AvailablePoints] INT NULL

EXECUTE sp_addextendedproperty N'MS_Description', N'Puntos disponibles para usar', N'SCHEMA', N'dbo', N'TABLE', N'Membership', N'COLUMN', N'AvailablePoints'
GO

ALTER TABLE [DeliveryBackOffice].[dbo].[Membership]
ADD [PointsExpirationDate] DATETIME NULL

EXECUTE sp_addextendedproperty N'MS_Description', N'Fecha de expiración de puntos', N'SCHEMA', N'dbo', N'TABLE', N'Membership', N'COLUMN', N'PointsExpirationDate'
GO

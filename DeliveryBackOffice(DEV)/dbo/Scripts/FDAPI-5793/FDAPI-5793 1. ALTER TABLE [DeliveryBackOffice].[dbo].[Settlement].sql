USE [DeliveryBackOffice]
GO

ALTER TABLE [DeliveryBackOffice].[dbo].[Settlement]
ADD TypeSettlement INT NOT NULL DEFAULT 0

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de poblados públicos y privados', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Settlement', @level2type = N'COLUMN', @level2name = N'TypeSettlement';
GO
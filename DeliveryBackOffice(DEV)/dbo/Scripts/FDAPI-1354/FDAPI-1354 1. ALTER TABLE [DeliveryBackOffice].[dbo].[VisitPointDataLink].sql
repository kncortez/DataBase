USE [DeliveryBackOffice]
GO

ALTER TABLE [DeliveryBackOffice].[dbo].[VisitPointDataLink]
ADD IsOnlyVisitPoint BIT NULL DEFAULT 0

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador si el token corresponde a un flujo el cual solo debe generar punto de visita', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointDataLink', @level2type = N'COLUMN', @level2name = N'IsOnlyVisitPoint';
GO
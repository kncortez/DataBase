USE [DeliveryBackOffice];
GO

ALTER TABLE [DeliveryBackOffice].[dbo].[DeliveryOrder]
ADD DeliveryETA DATETIME NULL

EXEC sys.sp_addextendedproperty 
	-- Descripción
	@name=N'MS_Description'
	, @value=N'Indica el tiempo estimado de entrega de la guía, cálculado'
	-- Esquema
	, @level0type=N'SCHEMA'
	, @level0name=N'dbo'
	-- Tabla
	, @level1type=N'TABLE'
	, @level1name=N'DeliveryOrder'
	-- Columna
	, @level2type=N'COLUMN'
	, @level2name=N'DeliveryETA'
ALTER TABLE [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]
ADD SystemOrigin INT NULL

ALTER TABLE [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]
ADD CONSTRAINT FK_DeliveryOrderDetail_SystemOrigin FOREIGN KEY ([SystemOrigin]) REFERENCES [DeliveryBackOffice].[dbo].[CatSystem]([SysIdSystem])

USE [DeliveryBackOffice];
GO

EXEC sys.sp_addextendedproperty 
	-- Esquema
	@level0type=N'SCHEMA'
	, @level0name=N'dbo'
	-- Tabla
	, @level1type=N'TABLE'
	, @level1name=N'DeliveryOrderDetail'
	-- Columna
	, @level2type=N'COLUMN'
	, @level2name=N'SystemOrigin'
	-- Descripción
	, @name=N'MS_Description'
	, @value=N'Identificador del sistema de origen de la tabla CatSystem.'

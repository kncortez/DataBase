ALTER TABLE [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]
ADD DeliveryAttemptId BIGINT NULL

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
	, @level2name=N'DeliveryAttemptId'
	-- Descripción
	, @name=N'MS_Description'
	, @value=N'Identificador del intento de entrega de la tabla DeliveryAttempt.'

ALTER TABLE [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]
ADD CONSTRAINT FK_DeliveryOrderDetail_DeliveryAttempt FOREIGN KEY ([DeliveryAttemptId]) REFERENCES [DeliveryBackOffice].[dbo].[DeliveryAttempt]([ID])
ALTER TABLE [DeliveryBackOffice].[dbo].[CatTypeIncidence]
ADD ValidatesLocation BIT NOT NULL DEFAULT 0

USE [DeliveryBackOffice];
GO

EXEC sys.sp_addextendedproperty 
	-- Esquema
	@level0type=N'SCHEMA'
	, @level0name=N'dbo'
	-- Tabla
	, @level1type=N'TABLE'
	, @level1name=N'CatTypeIncidence'
	-- Columna
	, @level2type=N'COLUMN'
	, @level2name=N'ValidatesLocation'
	-- Descripción
	, @name=N'MS_Description'
	, @value=N'Indicativo si incidencia valida ubicación para procesamiento.'

ALTER TABLE [DeliveryBackOffice].[dbo].[CatTypeIncidence]
ADD HasConfirmationProcess BIT NOT NULL DEFAULT 0

USE [DeliveryBackOffice];
GO

EXEC sys.sp_addextendedproperty 
	-- Esquema
	@level0type=N'SCHEMA'
	, @level0name=N'dbo'
	-- Tabla
	, @level1type=N'TABLE'
	, @level1name=N'CatTypeIncidence'
	-- Columna
	, @level2type=N'COLUMN'
	, @level2name=N'HasConfirmationProcess'
	-- Descripción
	, @name=N'MS_Description'
	, @value=N'Indicativo si incidencia genera proceso de confirmación de incidencia.'

ALTER TABLE [DeliveryBackOffice].[dbo].[CatTypeIncidence]
ADD NotifiesOrigin BIT NOT NULL DEFAULT 0

USE [DeliveryBackOffice];
GO

EXEC sys.sp_addextendedproperty 
	-- Esquema
	@level0type=N'SCHEMA'
	, @level0name=N'dbo'
	-- Tabla
	, @level1type=N'TABLE'
	, @level1name=N'CatTypeIncidence'
	-- Columna
	, @level2type=N'COLUMN'
	, @level2name=N'NotifiesOrigin'
	-- Descripción
	, @name=N'MS_Description'
	, @value=N'Indicativo si incidencia genera una notificación para el remitente.'
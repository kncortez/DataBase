USE [DeliveryBackOffice];
GO

CREATE TABLE NoLaborCalendar (
	IdNoLaborCalendar BIGINT NOT NULL IDENTITY(1,1),

	NoLaborDate DATE NOT NULL,

	RowStatus BIT NOT NULL DEFAULT 0,
	DateCreated DATETIME NOT NULL,
	TokenCreated NVARCHAR(50) NOT NULL,
	DateUpdated DATETIME NULL,
	TokenUpdated NVARCHAR(50) NULL,

	PRIMARY KEY(IdNoLaborCalendar),
	CONSTRAINT UQ_NoLaborCalendar_NoRepeats UNIQUE ([NoLaborDate])
);

-- Tabla
EXEC sys.sp_addextendedproperty 
	-- Descripción
	@name=N'MS_Description'
	, @value=N'Tabla de días los cuales se consideran no laborales y deben omitirse en el cálculo de fechas'
	-- Esquema
	, @level0type=N'SCHEMA'
	, @level0name=N'dbo'
	-- Tabla
	, @level1type=N'TABLE'
	, @level1name=N'NoLaborCalendar'

-- Columnas
EXEC sys.sp_addextendedproperty 
	-- Descripción
	@name=N'MS_Description'
	, @value=N'Identificador del registro.'
	-- Esquema
	, @level0type=N'SCHEMA'
	, @level0name=N'dbo'
	-- Tabla
	, @level1type=N'TABLE'
	, @level1name=N'NoLaborCalendar'
	-- Columna
	, @level2type=N'COLUMN'
	, @level2name=N'IdNoLaborCalendar'
	
EXEC sys.sp_addextendedproperty 
	-- Descripción
	@name=N'MS_Description'
	, @value=N'Fecha la cual debe ser ignorada por procesos.'
	-- Esquema
	, @level0type=N'SCHEMA'
	, @level0name=N'dbo'
	-- Tabla
	, @level1type=N'TABLE'
	, @level1name=N'NoLaborCalendar'
	-- Columna
	, @level2type=N'COLUMN'
	, @level2name=N'NoLaborDate'
	
EXEC sys.sp_addextendedproperty 
	-- Descripción
	@name=N'MS_Description'
	, @value=N'Estado lógico del registro.'
	-- Esquema
	, @level0type=N'SCHEMA'
	, @level0name=N'dbo'
	-- Tabla
	, @level1type=N'TABLE'
	, @level1name=N'NoLaborCalendar'
	-- Columna
	, @level2type=N'COLUMN'
	, @level2name=N'RowStatus'
	
EXEC sys.sp_addextendedproperty 
	-- Descripción
	@name=N'MS_Description'
	, @value=N'Fecha de creación del registro.'
	-- Esquema
	, @level0type=N'SCHEMA'
	, @level0name=N'dbo'
	-- Tabla
	, @level1type=N'TABLE'
	, @level1name=N'NoLaborCalendar'
	-- Columna
	, @level2type=N'COLUMN'
	, @level2name=N'DateCreated'
	
EXEC sys.sp_addextendedproperty 
	-- Descripción
	@name=N'MS_Description'
	, @value=N'Token de creación del registro.'
	-- Esquema
	, @level0type=N'SCHEMA'
	, @level0name=N'dbo'
	-- Tabla
	, @level1type=N'TABLE'
	, @level1name=N'NoLaborCalendar'
	-- Columna
	, @level2type=N'COLUMN'
	, @level2name=N'TokenCreated'
	
EXEC sys.sp_addextendedproperty 
	-- Descripción
	@name=N'MS_Description'
	, @value=N'Última fecha de actualización del registro.'
	-- Esquema
	, @level0type=N'SCHEMA'
	, @level0name=N'dbo'
	-- Tabla
	, @level1type=N'TABLE'
	, @level1name=N'NoLaborCalendar'
	-- Columna
	, @level2type=N'COLUMN'
	, @level2name=N'DateUpdated'
	
EXEC sys.sp_addextendedproperty 
	-- Descripción
	@name=N'MS_Description'
	, @value=N'Último token de actualización del registro.'
	-- Esquema
	, @level0type=N'SCHEMA'
	, @level0name=N'dbo'
	-- Tabla
	, @level1type=N'TABLE'
	, @level1name=N'NoLaborCalendar'
	-- Columna
	, @level2type=N'COLUMN'
	, @level2name=N'TokenUpdated'
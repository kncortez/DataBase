USE [DeliveryBackOffice];
GO

CREATE TABLE DayForDeliveryCoverage (
	IdDayForDeliveryCoverage BIGINT NOT NULL IDENTITY(1,1),
	HubLogisticsOrigin INT NOT NULL,
	HubLogisticsDestiny INT NOT NULL,

	DaysToAdd INT NOT NULL,

	RowStatus BIT NOT NULL DEFAULT 0,
	DateCreated DATETIME NOT NULL,
	TokenCreated NVARCHAR(50) NOT NULL,
	DateUpdated DATETIME NULL,
	TokenUpdated NVARCHAR(50) NULL,

	PRIMARY KEY(IdDayForDeliveryCoverage),
	CONSTRAINT FK_DayForDeliveryCoverage_OriginHub FOREIGN KEY ([HubLogisticsOrigin]) REFERENCES [DeliveryBackOffice].[dbo].[HubLogistics]([IdHubLogistic]),
	CONSTRAINT FK_DayForDeliveryCoverage_DestinyHub FOREIGN KEY ([HubLogisticsDestiny]) REFERENCES [DeliveryBackOffice].[dbo].[HubLogistics]([IdHubLogistic]),
	CONSTRAINT CHK_DayForDeliveryCoverage_Days CHECK ([DaysToAdd] >= 0)
);

-- Tabla
EXEC sys.sp_addextendedproperty 
	-- Descripción
	@name=N'MS_Description'
	, @value=N'Tabla de cobertura de HUB a HUB para adición de días en cálculo de ETA de entrega de guías'
	-- Esquema
	, @level0type=N'SCHEMA'
	, @level0name=N'dbo'
	-- Tabla
	, @level1type=N'TABLE'
	, @level1name=N'DayForDeliveryCoverage'

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
	, @level1name=N'DayForDeliveryCoverage'
	-- Columna
	, @level2type=N'COLUMN'
	, @level2name=N'IdDayForDeliveryCoverage'
	
EXEC sys.sp_addextendedproperty 
	-- Descripción
	@name=N'MS_Description'
	, @value=N'Identificador del hub de origen de la tabla HubLogistics.'
	-- Esquema
	, @level0type=N'SCHEMA'
	, @level0name=N'dbo'
	-- Tabla
	, @level1type=N'TABLE'
	, @level1name=N'DayForDeliveryCoverage'
	-- Columna
	, @level2type=N'COLUMN'
	, @level2name=N'HubLogisticsOrigin'
	
EXEC sys.sp_addextendedproperty 
	-- Descripción
	@name=N'MS_Description'
	, @value=N'Identificador del hub de destino de la tabla HubLogistics.'
	-- Esquema
	, @level0type=N'SCHEMA'
	, @level0name=N'dbo'
	-- Tabla
	, @level1type=N'TABLE'
	, @level1name=N'DayForDeliveryCoverage'
	-- Columna
	, @level2type=N'COLUMN'
	, @level2name=N'HubLogisticsDestiny'
	
EXEC sys.sp_addextendedproperty 
	-- Descripción
	@name=N'MS_Description'
	, @value=N'Dias por adicionar en el cálculo de tiempo estimado de entrega de la guía.'
	-- Esquema
	, @level0type=N'SCHEMA'
	, @level0name=N'dbo'
	-- Tabla
	, @level1type=N'TABLE'
	, @level1name=N'DayForDeliveryCoverage'
	-- Columna
	, @level2type=N'COLUMN'
	, @level2name=N'DaysToAdd'
	
EXEC sys.sp_addextendedproperty 
	-- Descripción
	@name=N'MS_Description'
	, @value=N'Estado lógico del registro.'
	-- Esquema
	, @level0type=N'SCHEMA'
	, @level0name=N'dbo'
	-- Tabla
	, @level1type=N'TABLE'
	, @level1name=N'DayForDeliveryCoverage'
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
	, @level1name=N'DayForDeliveryCoverage'
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
	, @level1name=N'DayForDeliveryCoverage'
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
	, @level1name=N'DayForDeliveryCoverage'
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
	, @level1name=N'DayForDeliveryCoverage'
	-- Columna
	, @level2type=N'COLUMN'
	, @level2name=N'TokenUpdated'
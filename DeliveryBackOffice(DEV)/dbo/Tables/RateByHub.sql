CREATE TABLE [dbo].[RateByHub] (
    [RbhId]                   INT             IDENTITY (1, 1) NOT NULL,
    [RbhIdRate]               INT             NOT NULL,
    [RbhIdHubSource]          INT             NOT NULL,
    [RbhIdHubDestiny]         INT             NOT NULL,
    [RbhIdTypeService]        INT             NOT NULL,
    [RbhRate]                 DECIMAL (12, 2) NOT NULL,
    [RbhFragileRate]          DECIMAL (14, 2) NULL,
    [RbhInsuranceRate]        DECIMAL (14, 2) NULL,
    [RbhCollectedRate]        DECIMAL (14, 2) NULL,
    [RbhWeightAdditionalRate] DECIMAL (14, 2) NULL,
    [RbhWeightLimit]          INT             NULL,
    [RbhWeightMeasure]        NVARCHAR (3)    NULL,
    [RbhDeliveryAttempts]     INT             NULL,
    [RbhCurrency]             NVARCHAR (3)    NOT NULL,
    [RbhRowStatus]            BIT             NOT NULL,
    [RbhTokenCreated]         VARCHAR (50)    NOT NULL,
    [RbhDateCreated]          DATETIME        NOT NULL,
    [RbhTokenUpdated]         VARCHAR (50)    NULL,
    [RvDateUpdated]           DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([RbhId] ASC),
    CONSTRAINT [FKRbhHubDestiny] FOREIGN KEY ([RbhIdHubDestiny]) REFERENCES [dbo].[HubLogistics] ([IdHubLogistic]),
    CONSTRAINT [FKRbhHubSource] FOREIGN KEY ([RbhIdHubSource]) REFERENCES [dbo].[HubLogistics] ([IdHubLogistic]),
    CONSTRAINT [FKRbhRate] FOREIGN KEY ([RbhIdRate]) REFERENCES [dbo].[RateHeader] ([RheId]),
    CONSTRAINT [FKRbhTypeService] FOREIGN KEY ([RbhIdTypeService]) REFERENCES [dbo].[CatTypeService] ([CtsId])
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificador del registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateByHub',
    @level2type = N'COLUMN',
    @level2name = N'RbhId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Referencia id tarifario(RateHeader)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateByHub',
    @level2type = N'COLUMN',
    @level2name = N'RbhIdRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'id de hub origen',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateByHub',
    @level2type = N'COLUMN',
    @level2name = N'RbhIdHubSource'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'id de hub destino',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateByHub',
    @level2type = N'COLUMN',
    @level2name = N'RbhIdHubDestiny'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Referencia al tipo de servicio(CatTypeService)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateByHub',
    @level2type = N'COLUMN',
    @level2name = N'RbhIdTypeService'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Valor de tarifario',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateByHub',
    @level2type = N'COLUMN',
    @level2name = N'RbhRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'tarifa por articulo fragil',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateByHub',
    @level2type = N'COLUMN',
    @level2name = N'RbhFragileRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'tarifa de seguro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateByHub',
    @level2type = N'COLUMN',
    @level2name = N'RbhInsuranceRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'tarifa de recolección',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateByHub',
    @level2type = N'COLUMN',
    @level2name = N'RbhCollectedRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'tarifa por peso adicional',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateByHub',
    @level2type = N'COLUMN',
    @level2name = N'RbhWeightAdditionalRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'limite de peso',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateByHub',
    @level2type = N'COLUMN',
    @level2name = N'RbhWeightLimit'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'medida de peso',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateByHub',
    @level2type = N'COLUMN',
    @level2name = N'RbhWeightMeasure'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'intentos de entrega',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateByHub',
    @level2type = N'COLUMN',
    @level2name = N'RbhDeliveryAttempts'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'moneda',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateByHub',
    @level2type = N'COLUMN',
    @level2name = N'RbhCurrency'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado(1 Activo, 0 Inactivo)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateByHub',
    @level2type = N'COLUMN',
    @level2name = N'RbhRowStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien creó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateByHub',
    @level2type = N'COLUMN',
    @level2name = N'RbhTokenCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creación del registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateByHub',
    @level2type = N'COLUMN',
    @level2name = N'RbhDateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien modificó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateByHub',
    @level2type = N'COLUMN',
    @level2name = N'RbhTokenUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de modificación del registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateByHub',
    @level2type = N'COLUMN',
    @level2name = N'RvDateUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tabla que contiene información de tarifarios por hub',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateByHub',
    @level2type = NULL,
    @level2name = NULL
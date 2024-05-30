CREATE TABLE [dbo].[RateByCustomerBySegmentByService] (
    [RcdId]                   BIGINT          IDENTITY (1, 1) NOT NULL,
    [RcdIdCustomer]           INT             NOT NULL,
    [RcdIdCatService]         INT             NOT NULL,
    [RcdIdRateSegment]        INT             NULL,
    [RcdRate]                 DECIMAL (14, 2) NOT NULL,
    [RcdFragileRate]          DECIMAL (14, 2) NULL,
    [RcdInsuranceRate]        DECIMAL (14, 2) NULL,
    [RcdCollectedRate]        DECIMAL (14, 2) NULL,
    [RcdWeightAdditionalRate] DECIMAL (14, 2) NULL,
    [RcdWeightLimit]          INT             NULL,
    [RcdWeightMeasure]        NVARCHAR (3)    NULL,
    [RcdDeliveryAttempts]     INT             NULL,
    [RcdCurrency]             NVARCHAR (3)    NOT NULL,
    [RcdRowStatus]            BIT             NOT NULL,
    [RcdTokenCreated]         VARCHAR (50)    NOT NULL,
    [RcdDateCreated]          DATETIME        NOT NULL,
    [RcdTokenUpdated]         VARCHAR (50)    NULL,
    [RcdDateUpdated]          DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([RcdId] ASC),
    CONSTRAINT [FKRcdCatSerivice] FOREIGN KEY ([RcdIdCatService]) REFERENCES [dbo].[CatTypeService] ([CtsId]),
    CONSTRAINT [FKRcdCustomer] FOREIGN KEY ([RcdIdCustomer]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [FKRcdRateSegment] FOREIGN KEY ([RcdIdRateSegment]) REFERENCES [dbo].[CatRateSegment] ([CrsId])
);




GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificacion del registro ',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateByCustomerBySegmentByService',
    @level2type = N'COLUMN',
    @level2name = N'RcdId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Referencia a la tabla Customer',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateByCustomerBySegmentByService',
    @level2type = N'COLUMN',
    @level2name = N'RcdIdCustomer'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Referencia a la tabla CatTypeService',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateByCustomerBySegmentByService',
    @level2type = N'COLUMN',
    @level2name = N'RcdIdCatService'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Referencia a la tabla CatRateSegment',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateByCustomerBySegmentByService',
    @level2type = N'COLUMN',
    @level2name = N'RcdIdRateSegment'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tarifa por peso adicional',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateByCustomerBySegmentByService',
    @level2type = N'COLUMN',
    @level2name = N'RcdWeightAdditionalRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tarifa',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateByCustomerBySegmentByService',
    @level2type = N'COLUMN',
    @level2name = N'RcdRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tarifa por artículo frágil',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateByCustomerBySegmentByService',
    @level2type = N'COLUMN',
    @level2name = N'RcdFragileRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tarifa de seguro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateByCustomerBySegmentByService',
    @level2type = N'COLUMN',
    @level2name = N'RcdInsuranceRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tarifa de recolección',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateByCustomerBySegmentByService',
    @level2type = N'COLUMN',
    @level2name = N'RcdCollectedRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'limite de peso',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateByCustomerBySegmentByService',
    @level2type = N'COLUMN',
    @level2name = N'RcdWeightLimit'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Medida de peso',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateByCustomerBySegmentByService',
    @level2type = N'COLUMN',
    @level2name = N'RcdWeightMeasure'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Intentos de entrega',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateByCustomerBySegmentByService',
    @level2type = N'COLUMN',
    @level2name = N'RcdDeliveryAttempts'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Moneda',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateByCustomerBySegmentByService',
    @level2type = N'COLUMN',
    @level2name = N'RcdCurrency'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado(1 Activo, 0 Inactivo)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateByCustomerBySegmentByService',
    @level2type = N'COLUMN',
    @level2name = N'RcdRowStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien creó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateByCustomerBySegmentByService',
    @level2type = N'COLUMN',
    @level2name = N'RcdTokenCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateByCustomerBySegmentByService',
    @level2type = N'COLUMN',
    @level2name = N'RcdDateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien modificó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateByCustomerBySegmentByService',
    @level2type = N'COLUMN',
    @level2name = N'RcdTokenUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de modificación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateByCustomerBySegmentByService',
    @level2type = N'COLUMN',
    @level2name = N'RcdDateUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tarifas aplicadas por cliente por tipo de servicio',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateByCustomerBySegmentByService',
    @level2type = NULL,
    @level2name = NULL
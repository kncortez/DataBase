CREATE TABLE [dbo].[RateData] (
    [IdRateData]        BIGINT          IDENTITY (1, 1) NOT NULL,
    [RateId]            INT             NOT NULL,
    [TypeServiceId]     INT             NULL,
    [TypeSegmentId]     INT             NULL,
    [HubSourceId]       INT             NULL,
    [HubDestinyId]      INT             NULL,
    [ArticleId]         INT             NULL,
    [RateValue]         DECIMAL (14, 2) NOT NULL,
    [RowStatus]         BIT             NOT NULL,
    [TokenCreated]      VARCHAR (50)    NOT NULL,
    [DateCreated]       DATETIME        NOT NULL,
    [TokenUpdated]      VARCHAR (50)    NULL,
    [DateUpdated]       DATETIME        NULL,
    [LimitHourDelivery] TIME (7)        NULL,
    [LimitHourPickup]   TIME (7)        NULL,
    [WeightFrom]        DECIMAL (12, 2) NULL,
    [WeightTo]          DECIMAL (12, 2) NULL,
    [PackagesFrom]      INT             NULL,
    [PackagesTo]        INT             NULL,
    PRIMARY KEY CLUSTERED ([IdRateData] ASC),
    CONSTRAINT [FKRateArticuleId] FOREIGN KEY ([ArticleId]) REFERENCES [dbo].[ArticleByCustomer] ([AbcId]),
    CONSTRAINT [FKRateDetId] FOREIGN KEY ([RateId]) REFERENCES [dbo].[RateHeader] ([RheId]),
    CONSTRAINT [FKRateHubDestinyId] FOREIGN KEY ([HubDestinyId]) REFERENCES [dbo].[HubLogistics] ([IdHubLogistic]),
    CONSTRAINT [FKRateHubSourceId] FOREIGN KEY ([HubSourceId]) REFERENCES [dbo].[HubLogistics] ([IdHubLogistic]),
    CONSTRAINT [FKRateSegmentId] FOREIGN KEY ([TypeSegmentId]) REFERENCES [dbo].[CatRateSegment] ([CrsId]),
    CONSTRAINT [FKRateServiceId] FOREIGN KEY ([TypeServiceId]) REFERENCES [dbo].[CatTypeService] ([CtsId])
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador único de la tarifa.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateData', @level2type = N'COLUMN', @level2name = N'IdRateData';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la tarifa. Referencia a tabla RateHeader', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateData', @level2type = N'COLUMN', @level2name = N'RateId';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del tipo de servicio. Referencia a tabla CatTypeService', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateData', @level2type = N'COLUMN', @level2name = N'TypeServiceId';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del tipo de segmento. Referencia a tabla CatRateSegment', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateData', @level2type = N'COLUMN', @level2name = N'TypeSegmentId';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del hub de origen. Referencia a tabla HubLogistics', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateData', @level2type = N'COLUMN', @level2name = N'HubSourceId';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del hub de destino.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateData', @level2type = N'COLUMN', @level2name = N'HubDestinyId';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del artículo. Referencia a tabla ArticleByCustomer', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateData', @level2type = N'COLUMN', @level2name = N'ArticleId';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor de la tarifa.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateData', @level2type = N'COLUMN', @level2name = N'RateValue';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de la registro (activo/inactivo).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateData', @level2type = N'COLUMN', @level2name = N'RowStatus';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación de la registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateData', @level2type = N'COLUMN', @level2name = N'TokenCreated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateData', @level2type = N'COLUMN', @level2name = N'DateCreated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de última actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateData', @level2type = N'COLUMN', @level2name = N'TokenUpdated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de última actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateData', @level2type = N'COLUMN', @level2name = N'DateUpdated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Hora límite para entrega.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateData', @level2type = N'COLUMN', @level2name = N'LimitHourDelivery';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Hora límite para recogida.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateData', @level2type = N'COLUMN', @level2name = N'LimitHourPickup';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Peso desde en tarifario por peso.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateData', @level2type = N'COLUMN', @level2name = N'WeightFrom';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Peso hasta en tarifario por peso.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateData', @level2type = N'COLUMN', @level2name = N'WeightTo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Paquetes hasta en tarifario por paquetes.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateData', @level2type = N'COLUMN', @level2name = N'PackagesTo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Paquetes desde en tarifario por paquetes.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateData', @level2type = N'COLUMN', @level2name = N'PackagesFrom';


GO
CREATE NONCLUSTERED INDEX [idx_TypeSegmentId]
    ON [dbo].[RateData]([TypeSegmentId] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_RateId_TypeSegmentId_TypeServiceId_RowStatus]
    ON [dbo].[RateData]([RateId] ASC, [TypeSegmentId] ASC, [TypeServiceId] ASC, [RowStatus] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_RateHeader]
    ON [dbo].[RateData]([RateId] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_ArticleId]
    ON [dbo].[RateData]([ArticleId] ASC);

GO



EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tabla que almacena precio por articulo, segmento, tipo de servicio y tarifario',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateData',
    @level2type = NULL,
    @level2name = NULL
CREATE TABLE [dbo].[RateCOD] (
    [IdRateCOD]           BIGINT          IDENTITY (1, 1) NOT NULL,
    [RateId]              INT             NOT NULL,
    [TypeServiceId]       INT             NOT NULL,
    [TypeSegmentId]       INT             NOT NULL,
    [CODRate]             DECIMAL (12, 2) NOT NULL,
    [CODExempt]           DECIMAL (12, 2) NULL,
    [CreditCardSurcharge] DECIMAL (12, 2) NULL,
    [RowStatus]           INT             NOT NULL,
    [TokenCreated]        VARCHAR (50)    NOT NULL,
    [DateCreated]         DATETIME        NOT NULL,
    [TokenUpdated]        VARCHAR (50)    NULL,
    [DateUpdated]         DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([IdRateCOD] ASC),
    FOREIGN KEY ([RateId]) REFERENCES [dbo].[RateHeader] ([RheId]),
    FOREIGN KEY ([TypeSegmentId]) REFERENCES [dbo].[CatRateSegment] ([CrsId]),
    FOREIGN KEY ([TypeServiceId]) REFERENCES [dbo].[CatTypeService] ([CtsId])
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador único de la tarifa COD.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateCOD', @level2type = N'COLUMN', @level2name = N'IdRateCOD';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la tarifa asociada. Referencia a la tabla RateHeader', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateCOD', @level2type = N'COLUMN', @level2name = N'RateId';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del tipo de servicio. Referencia a tabla CatTypeService', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateCOD', @level2type = N'COLUMN', @level2name = N'TypeServiceId';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del tipo de segmento. Referencia a la tabla CatRateSegment', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateCOD', @level2type = N'COLUMN', @level2name = N'TypeSegmentId';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tarifa de pago contra entrega (COD - Cash on Delivery).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateCOD', @level2type = N'COLUMN', @level2name = N'CODRate';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto exento de pago contra entrega.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateCOD', @level2type = N'COLUMN', @level2name = N'CODExempt';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Sobrecargo por pago con tarjeta de crédito.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateCOD', @level2type = N'COLUMN', @level2name = N'CreditCardSurcharge';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado (1 Activo, 0 Inactivo)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateCOD', @level2type = N'COLUMN', @level2name = N'RowStatus';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación de la tarifa COD.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateCOD', @level2type = N'COLUMN', @level2name = N'TokenCreated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación de la tarifa COD.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateCOD', @level2type = N'COLUMN', @level2name = N'DateCreated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de última actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateCOD', @level2type = N'COLUMN', @level2name = N'TokenUpdated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de última actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateCOD', @level2type = N'COLUMN', @level2name = N'DateUpdated';

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tabla que comision, tipo de segmento y tipo de servicio y porcentaje de seguro de COD',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateCOD',
    @level2type = NULL,
    @level2name = NULL

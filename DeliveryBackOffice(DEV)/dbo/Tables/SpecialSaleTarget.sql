CREATE TABLE [dbo].[SpecialSaleTarget] (
    [IdSpecialSaleTarget] INT          IDENTITY (1, 1) NOT NULL,
    [SpecialSaleId]       INT          NOT NULL,
    [SalesPipeLineId]     INT          NULL,
    [CustomerTypeid]      INT          NULL,
    [CustomerId]          INT          NULL,
    [TypeServiceId]       INT          NULL,
    [TypeProductId]       INT          NULL,
    [RowStatus]           BIT          NOT NULL,
    [TokenCreated]        VARCHAR (50) NOT NULL,
    [DateCreated]         DATETIME     NOT NULL,
    [TokenUpdated]        VARCHAR (50) NULL,
    [DateUpdated]         DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([IdSpecialSaleTarget] ASC),
    CONSTRAINT [FKTargetCustomer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [FKTargetCustomerType] FOREIGN KEY ([CustomerTypeid]) REFERENCES [dbo].[CustomerType] ([IdCustomerType]),
    CONSTRAINT [FKTargetPipe] FOREIGN KEY ([SalesPipeLineId]) REFERENCES [dbo].[CatSalePipelines] ([IdSalePipeLine]),
    CONSTRAINT [FKTargetProduct] FOREIGN KEY ([TypeProductId]) REFERENCES [dbo].[CatTypeProduct] ([IdTypeProduct]),
    CONSTRAINT [FKTargetSale] FOREIGN KEY ([SpecialSaleId]) REFERENCES [dbo].[SpecialSale] ([IdSpecialSale]),
    CONSTRAINT [FKTargetTypeService] FOREIGN KEY ([TypeServiceId]) REFERENCES [dbo].[CatTypeService] ([CtsId])
);

GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador único del registro de destino de venta especial.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SpecialSaleTarget', @level2type = N'COLUMN', @level2name = N'IdSpecialSaleTarget';

GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la venta especial a la que pertenece este destino. Referencia a tabla SpecialSale', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SpecialSaleTarget', @level2type = N'COLUMN', @level2name = N'SpecialSaleId';

GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del canal de ventas al que aplica la oferta especial. Referencia a tabla CatSalePipelines', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SpecialSaleTarget', @level2type = N'COLUMN', @level2name = N'SalesPipeLineId';

GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Tipo de cliente. Referencia a tabla CustomerType', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SpecialSaleTarget', @level2type = N'COLUMN', @level2name = N'CustomerTypeid';

GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Cliente al que se dirige la venta especial.Referencia a la tabla Customer.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SpecialSaleTarget', @level2type = N'COLUMN', @level2name = N'CustomerId';

GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del tipo de servicio al que aplica la venta especial. Referencia a tabla CatTypeService', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SpecialSaleTarget', @level2type = N'COLUMN', @level2name = N'TypeServiceId';

GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del tipo de producto al que aplica la venta especial. Referencia a tabla CatTypeProduct', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SpecialSaleTarget', @level2type = N'COLUMN', @level2name = N'TypeProductId';

GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro (1 Activo, 0 Inactivo).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SpecialSaleTarget', @level2type = N'COLUMN', @level2name = N'RowStatus';

GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Token que identifica la creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SpecialSaleTarget', @level2type = N'COLUMN', @level2name = N'TokenCreated';

GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha en la que se creó el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SpecialSaleTarget', @level2type = N'COLUMN', @level2name = N'DateCreated';

GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Token que identifica la última actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SpecialSaleTarget', @level2type = N'COLUMN', @level2name = N'TokenUpdated';

GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha en la que se realizó la última actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SpecialSaleTarget', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tabla destino de ventas especiales',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'SpecialSaleTarget',
    @level2type = NULL,
    @level2name = NULL


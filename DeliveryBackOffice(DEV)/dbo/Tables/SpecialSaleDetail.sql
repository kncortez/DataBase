CREATE TABLE [dbo].[SpecialSaleDetail] (
    [IdSpecialSaleDetail] INT             IDENTITY (1, 1) NOT NULL,
    [SpecialSaleId]       INT             NOT NULL,
    [UnitId]              INT             NOT NULL,
    [Value]               DECIMAL (12, 2) NULL,
    [TypeDiscountId]      INT             NOT NULL,
    [RowStatus]           BIT             NOT NULL,
    [TokenCreated]        VARCHAR (50)    NOT NULL,
    [DateCreated]         DATETIME        NOT NULL,
    [TokenUpdated]        VARCHAR (50)    NULL,
    [DateUpdated]         DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([IdSpecialSaleDetail] ASC),
    CONSTRAINT [FKDiscountSale] FOREIGN KEY ([SpecialSaleId]) REFERENCES [dbo].[SpecialSale] ([IdSpecialSale]),
    CONSTRAINT [FKDiscountType] FOREIGN KEY ([TypeDiscountId]) REFERENCES [dbo].[CatTypeDiscount] ([IdCatTypeDiscount]),
    CONSTRAINT [FKDiscountUnit] FOREIGN KEY ([UnitId]) REFERENCES [dbo].[Unit] ([IdUnit])
);

GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador único del detalle de la venta especial.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SpecialSaleDetail', @level2type = N'COLUMN', @level2name = N'IdSpecialSaleDetail';

GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la venta especial a la que pertenece este detalle. Referencia a tabla SpecialSale', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SpecialSaleDetail', @level2type = N'COLUMN', @level2name = N'SpecialSaleId';

GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la unidad. Referencia a tabla Unit', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SpecialSaleDetail', @level2type = N'COLUMN', @level2name = N'UnitId';

GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Valor aplicado en la venta especial.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SpecialSaleDetail', @level2type = N'COLUMN', @level2name = N'Value';

GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Tipo de descuento aplicado. Referencia a tabla CatTypeDiscount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SpecialSaleDetail', @level2type = N'COLUMN', @level2name = N'TypeDiscountId';

GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro (1 Activo, 0 Inactivo).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SpecialSaleDetail', @level2type = N'COLUMN', @level2name = N'RowStatus';

GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Token que identifica la creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SpecialSaleDetail', @level2type = N'COLUMN', @level2name = N'TokenCreated';

GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha en la que se creó el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SpecialSaleDetail', @level2type = N'COLUMN', @level2name = N'DateCreated';

GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Token que identifica la última actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SpecialSaleDetail', @level2type = N'COLUMN', @level2name = N'TokenUpdated';

GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha en la que se realizó la última actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SpecialSaleDetail', @level2type = N'COLUMN', @level2name = N'DateUpdated';

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tabla detalle de ventas especiales',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'SpecialSaleDetail',
    @level2type = NULL,
    @level2name = NULL

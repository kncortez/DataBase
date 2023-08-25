CREATE TABLE [dbo].[ProductMKP] (
    [IdProductMKP]          INT            NOT NULL,
    [CatProductMKP_Id]      INT            NOT NULL,
    [ProductNameMKP]        NCHAR (100)    NOT NULL,
    [DescriptionProductMKP] NCHAR (200)    NOT NULL,
    [DiscountType]          INT            NULL,
    [DiscountValue]         DECIMAL (5, 2) NULL,
    [Stock]                 INT            NULL,
    [RowStatus]             BIT            NOT NULL,
    [DateCreated]           NCHAR (10)     NOT NULL,
    [TokenCreated]          NCHAR (10)     NOT NULL,
    [DateUpdated]           NCHAR (10)     NULL,
    [TokenUpdated]          NCHAR (10)     NULL,
    CONSTRAINT [PK_IdProductMKP] PRIMARY KEY CLUSTERED ([IdProductMKP] ASC),
    CONSTRAINT [FK_ProductMKP1_CatProductMKP1] FOREIGN KEY ([CatProductMKP_Id]) REFERENCES [dbo].[CatProductMKP] ([IdCatProductMKP])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que actualiza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProductMKP', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha que actualiza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProductMKP', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProductMKP', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProductMKP', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProductMKP', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad en existencia del producto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProductMKP', @level2type = N'COLUMN', @level2name = N'Stock';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor del descuento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProductMKP', @level2type = N'COLUMN', @level2name = N'DiscountValue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipo de descuento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProductMKP', @level2type = N'COLUMN', @level2name = N'DiscountType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del Producto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProductMKP', @level2type = N'COLUMN', @level2name = N'DescriptionProductMKP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del Producto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProductMKP', @level2type = N'COLUMN', @level2name = N'ProductNameMKP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla CatTypeProductMKP', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProductMKP', @level2type = N'COLUMN', @level2name = N'CatProductMKP_Id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla CatProductMKP', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProductMKP', @level2type = N'COLUMN', @level2name = N'IdProductMKP';


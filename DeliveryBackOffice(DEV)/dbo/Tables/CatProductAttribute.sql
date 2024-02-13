CREATE TABLE [dbo].[CatProductAttribute] (
    [IdCatProductAttribute]              INT            IDENTITY (1, 1) NOT NULL,
    [CatProductId]                       INT            NOT NULL,
    [CatProductAttributeDescription]     NVARCHAR (300) NULL,
    [CatProductAttributeDescriptionLong] NVARCHAR (500) NULL,
    [CatProductAttributeIcon]            NVARCHAR (50)  NULL,
    [CatProductAtributeOrder]            INT            NOT NULL,
    [RowStatus]                          BIT            NOT NULL,
    [TokenCreated]                       NVARCHAR (50)  NOT NULL,
    [DateCreated]                        DATETIME       NOT NULL,
    [TokenUpdated]                       NVARCHAR (50)  NULL,
    [DateUpdated]                        DATETIME       NULL,
    CONSTRAINT [PK_CatProductAttribute] PRIMARY KEY CLUSTERED ([IdCatProductAttribute] ASC),
    CONSTRAINT [FK_CatProductAttribute_CatProduct] FOREIGN KEY ([CatProductId]) REFERENCES [dbo].[CatProduct] ([IdCatProduct])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de modificación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductAttribute', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de modificación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductAttribute', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductAttribute', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductAttribute', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductAttribute', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Orden de aparición del atributo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductAttribute', @level2type = N'COLUMN', @level2name = N'CatProductAtributeOrder';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ícono del atributo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductAttribute', @level2type = N'COLUMN', @level2name = N'CatProductAttributeIcon';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre largo del atributo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductAttribute', @level2type = N'COLUMN', @level2name = N'CatProductAttributeDescriptionLong';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del atributo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductAttribute', @level2type = N'COLUMN', @level2name = N'CatProductAttributeDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Producto al que pertenece el atributo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductAttribute', @level2type = N'COLUMN', @level2name = N'CatProductId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del atributo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductAttribute', @level2type = N'COLUMN', @level2name = N'IdCatProductAttribute';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Atributos por producto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductAttribute';


CREATE TABLE [dbo].[CatProductDescription] (
    [IdCatProductDescription]    INT            IDENTITY (1, 1) NOT NULL,
    [CatProductId]               INT            NOT NULL,
    [CatProductDescriptionTitle] NVARCHAR (50)  NOT NULL,
    [CatProductDescription]      NVARCHAR (100) NULL,
    [CatProductDescriptionOrder] INT            NOT NULL,
    [RowStatus]                  BIT            NOT NULL,
    [TokenCreated]               NVARCHAR (50)  NULL,
    [DateCreated]                DATETIME       NOT NULL,
    [TokenUpdated]               NVARCHAR (50)  NULL,
    [DateUpdated]                DATETIME       NULL,
    CONSTRAINT [PK_CatProductDescription] PRIMARY KEY CLUSTERED ([IdCatProductDescription] ASC),
    CONSTRAINT [FK_CatProductDescription_CatProduct] FOREIGN KEY ([CatProductId]) REFERENCES [dbo].[CatProduct] ([IdCatProduct])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de modificación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductDescription', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de modificación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductDescription', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductDescription', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductDescription', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductDescription', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Orden', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductDescription', @level2type = N'COLUMN', @level2name = N'CatProductDescriptionOrder';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción de cada descripción por producto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductDescription', @level2type = N'COLUMN', @level2name = N'CatProductDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Título de la descripción del producto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductDescription', @level2type = N'COLUMN', @level2name = N'CatProductDescriptionTitle';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Producto al que pertenece el la descripción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductDescription', @level2type = N'COLUMN', @level2name = N'CatProductId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del atributo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductDescription', @level2type = N'COLUMN', @level2name = N'IdCatProductDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Lista de descripciones por producto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductDescription';


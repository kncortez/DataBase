CREATE TABLE [dbo].[CatProductImage] (
    [IdCatProductImage]            INT             IDENTITY (1, 1) NOT NULL,
    [CatProductId]                 INT             NOT NULL,
    [CatProductImageSmallImageURL] NVARCHAR (200)  NULL,
    [CatProductImageLargeImageURL] NVARCHAR (200)  NULL,
    [CatProductImageOrder]         INT             NOT NULL,
    [CatProductImageResolutionX]   DECIMAL (18, 2) NULL,
    [CatProductImageResolutionY]   DECIMAL (18, 2) NULL,
    [RowStatus]                    BIT             NOT NULL,
    [TokenCreated]                 NVARCHAR (50)   NOT NULL,
    [DateCreated]                  DATETIME        NULL,
    [TokenUpdated]                 NVARCHAR (50)   NULL,
    [DateUpdated]                  DATETIME        NULL,
    CONSTRAINT [PK_CatProductImage] PRIMARY KEY CLUSTERED ([IdCatProductImage] ASC),
    CONSTRAINT [FK_CatProductImage_CatProduct] FOREIGN KEY ([CatProductId]) REFERENCES [dbo].[CatProduct] ([IdCatProduct])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de modificación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductImage', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de modificación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductImage', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductImage', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductImage', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductImage', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Resolución de imagen Y', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductImage', @level2type = N'COLUMN', @level2name = N'CatProductImageResolutionY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Resolución de imagen X', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductImage', @level2type = N'COLUMN', @level2name = N'CatProductImageResolutionX';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Orden de aparición de las imágenes', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductImage', @level2type = N'COLUMN', @level2name = N'CatProductImageOrder';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Imagen grande', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductImage', @level2type = N'COLUMN', @level2name = N'CatProductImageLargeImageURL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Imagen en miniatura', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductImage', @level2type = N'COLUMN', @level2name = N'CatProductImageSmallImageURL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Producto al que pertenece la imagen', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductImage', @level2type = N'COLUMN', @level2name = N'CatProductId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la imagen', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductImage', @level2type = N'COLUMN', @level2name = N'IdCatProductImage';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Listado de imágenes por producto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductImage';


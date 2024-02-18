CREATE TABLE [dbo].[CatProductImage] (
    [IdCatProductImage]            INT            IDENTITY (1, 1) NOT NULL,
    [CatProductImageSmallImageURL] NVARCHAR (200) NULL,
    [CatProductImageLargeImageURL] NVARCHAR (200) NULL,
    [CatProductImageOrder]         INT            NOT NULL,
    [RowStatus]                    BIT            NOT NULL,
    [TokenCreated]                 NVARCHAR (50)  NOT NULL,
    [DateCreated]                  DATETIME       NOT NULL,
    [TokenUpdated]                 NVARCHAR (50)  NULL,
    [DateUpdated]                  DATETIME       NULL,
    [CatSubscriptionId]            INT            NULL,
    [CatMembershipId]              INT            NULL,
    [CatProductImageBigImageURL]   NVARCHAR (200) NULL,
    CONSTRAINT [PK_CatProductImage] PRIMARY KEY CLUSTERED ([IdCatProductImage] ASC),
    CONSTRAINT [FK_CatProductImage_CatMembership] FOREIGN KEY ([CatMembershipId]) REFERENCES [dbo].[CatMembership] ([IdCatMembership]),
    CONSTRAINT [FK_CatProductImage_CatSubscription] FOREIGN KEY ([CatSubscriptionId]) REFERENCES [dbo].[CatSubscription] ([IdCatSubscription])
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



GO



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Orden de aparición de las imágenes', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductImage', @level2type = N'COLUMN', @level2name = N'CatProductImageOrder';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Imagen grande', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductImage', @level2type = N'COLUMN', @level2name = N'CatProductImageLargeImageURL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Imagen en miniatura', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductImage', @level2type = N'COLUMN', @level2name = N'CatProductImageSmallImageURL';


GO



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la imagen', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductImage', @level2type = N'COLUMN', @level2name = N'IdCatProductImage';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Listado de imágenes por producto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductImage';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id relacion con tabla CatSubscription', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductImage', @level2type = N'COLUMN', @level2name = N'CatSubscriptionId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Imagen grande para marketplace', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductImage', @level2type = N'COLUMN', @level2name = N'CatProductImageBigImageURL';


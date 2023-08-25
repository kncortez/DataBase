CREATE TABLE [dbo].[MarketplaceCarouselImage] (
    [IdCarouselImage]  INT             IDENTITY (1, 1) NOT NULL,
    [ImageURL]         NVARCHAR (200)  NOT NULL,
    [ImageResolutionX] DECIMAL (18, 2) NULL,
    [ImageResolutionY] DECIMAL (18)    NULL,
    [ImageOrder]       INT             NOT NULL,
    [RowStatus]        BIT             NOT NULL,
    [TokenCreated]     NVARCHAR (50)   NOT NULL,
    [DateCreated]      DATETIME        NOT NULL,
    [TokenUpdated]     NVARCHAR (50)   NULL,
    [DateUpdated]      DATETIME        NULL,
    CONSTRAINT [PK_MarketplaceCarouselImage] PRIMARY KEY CLUSTERED ([IdCarouselImage] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de modificación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceCarouselImage', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de modificación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceCarouselImage', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceCarouselImage', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceCarouselImage', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceCarouselImage', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Order de aparición de imágenes', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceCarouselImage', @level2type = N'COLUMN', @level2name = N'ImageOrder';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Resolución de imagen Y', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceCarouselImage', @level2type = N'COLUMN', @level2name = N'ImageResolutionY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Resolución de imagen X', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceCarouselImage', @level2type = N'COLUMN', @level2name = N'ImageResolutionX';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Imagen en carrousel', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceCarouselImage', @level2type = N'COLUMN', @level2name = N'ImageURL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del atributo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceCarouselImage', @level2type = N'COLUMN', @level2name = N'IdCarouselImage';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Lista de imágenes del carrousel', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceCarouselImage';


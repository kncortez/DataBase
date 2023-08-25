CREATE TABLE [dbo].[MarketplaceCarouselImage_bkp] (
    [IdCarouselImage]  BIGINT         IDENTITY (1, 1) NOT NULL,
    [ImageURL]         NVARCHAR (500) NOT NULL,
    [ImageResolutionX] NVARCHAR (25)  NOT NULL,
    [ImageResolutionY] NVARCHAR (25)  NOT NULL,
    [ImageOrder]       INT            NOT NULL,
    [RowStatus]        BIT            NOT NULL,
    [DateCreated]      NCHAR (10)     NOT NULL,
    [TokenCreated]     NCHAR (10)     NOT NULL,
    [DateUpdated]      NCHAR (10)     NULL,
    [TokenUpdated]     NCHAR (10)     NULL,
    CONSTRAINT [PK_MarketplaceCarouselImage_bkp] PRIMARY KEY CLUSTERED ([IdCarouselImage] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que actualiza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceCarouselImage_bkp', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha que actualiza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceCarouselImage_bkp', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceCarouselImage_bkp', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceCarouselImage_bkp', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceCarouselImage_bkp', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Orden de la imagen', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceCarouselImage_bkp', @level2type = N'COLUMN', @level2name = N'ImageOrder';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dimension Y de la imagen', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceCarouselImage_bkp', @level2type = N'COLUMN', @level2name = N'ImageResolutionY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dimension X de la imagen', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceCarouselImage_bkp', @level2type = N'COLUMN', @level2name = N'ImageResolutionX';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Url de imagen', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceCarouselImage_bkp', @level2type = N'COLUMN', @level2name = N'ImageURL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla IdCarouselImage', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceCarouselImage_bkp', @level2type = N'COLUMN', @level2name = N'IdCarouselImage';


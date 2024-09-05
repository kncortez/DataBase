CREATE TABLE [dbo].[MovilAppCarouselImage] (
    [IdCarouselImage] INT            IDENTITY (1, 1) NOT NULL,
    [SDImageURL]      NVARCHAR (200) NOT NULL,
    [MDImageURL]      NVARCHAR (200) NOT NULL,
    [LDImageURL]      NVARCHAR (200) NOT NULL,
    [ImageOrder]      INT            NOT NULL,
    [RowStatus]       BIT            NOT NULL,
    [HyperlinkURL]    NVARCHAR (200) NULL,
    [IdCountry]		  NVARCHAR (2)	 NULL,
    [TokenCreated]    NVARCHAR (50)  NOT NULL,
    [DateCreated]     DATETIME       NOT NULL,
    [TokenUpdated]    NVARCHAR (50)  NULL,
    [DateUpdated]     DATETIME       NULL,
    CONSTRAINT [PK_MovilAppCarouselImage] PRIMARY KEY CLUSTERED ([IdCarouselImage] ASC)
);
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del atributo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MovilAppCarouselImage', @level2type=N'COLUMN',@level2name=N'IdCarouselImage'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Imagen en carrousel SD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MovilAppCarouselImage', @level2type=N'COLUMN',@level2name=N'SDImageURL'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Imagen en carrousel MD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MovilAppCarouselImage', @level2type=N'COLUMN',@level2name=N'MDImageURL'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Imagen en carrousel LD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MovilAppCarouselImage', @level2type=N'COLUMN',@level2name=N'LDImageURL'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Order de aparición de imágenes' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MovilAppCarouselImage', @level2type=N'COLUMN',@level2name=N'ImageOrder'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MovilAppCarouselImage', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'URL de hipervínculo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MovilAppCarouselImage', @level2type = N'COLUMN', @level2name = N'HyperlinkURL';
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'identificador del pais para la imagen' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MovilAppCarouselImage', @level2type=N'COLUMN',@level2name=N'IdCountry'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MovilAppCarouselImage', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MovilAppCarouselImage', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario de modificación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MovilAppCarouselImage', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de modificación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MovilAppCarouselImage', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Lista de imágenes del carrousel' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MovilAppCarouselImage'
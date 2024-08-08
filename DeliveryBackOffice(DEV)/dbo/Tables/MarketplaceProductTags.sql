
CREATE TABLE [dbo].[MarketplaceProductTags] (
    [IdMarketplaceProductTags]          INT            IDENTITY (1, 1) NOT NULL,
    [MarketplaceProductTagsName]        NVARCHAR (50)  NULL,
    [MarketplaceProductTagsDescription] NVARCHAR (100) NOT NULL,
    [MarketplaceProductTagsOrder]       INT            NOT NULL,
    [RowStatus]                         BIT            NOT NULL,
    [TokenCreated]                      NVARCHAR (50)  NOT NULL,
    [DateCreated]                       DATETIME       NOT NULL,
    [TokenUpdated]                      NVARCHAR (50)  NULL,
    [DateUpdated]                       DATETIME       NULL,
    [IdCountry]                         NVARCHAR (2)   NULL,
    CONSTRAINT [PK_MarketplaceProductTags] PRIMARY KEY CLUSTERED ([IdMarketplaceProductTags] ASC)
);


GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identicador de la etiqueta' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MarketplaceProductTags', @level2type=N'COLUMN',@level2name=N'IdMarketplaceProductTags'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Título de etiqueta' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MarketplaceProductTags', @level2type=N'COLUMN',@level2name=N'MarketplaceProductTagsName'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripción de la etiqueta' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MarketplaceProductTags', @level2type=N'COLUMN',@level2name=N'MarketplaceProductTagsDescription'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Order de aparición de etiquetas' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MarketplaceProductTags', @level2type=N'COLUMN',@level2name=N'MarketplaceProductTagsOrder'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MarketplaceProductTags', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MarketplaceProductTags', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MarketplaceProductTags', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario de modificación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MarketplaceProductTags', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de modificación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MarketplaceProductTags', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Etiquetas de productos en el marketplace' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MarketplaceProductTags'
GO



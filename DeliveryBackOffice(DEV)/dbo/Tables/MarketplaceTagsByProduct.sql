CREATE TABLE [dbo].[MarketplaceTagsByProduct] (
    [IdMarketplaceTagsByProduct] INT           IDENTITY (1, 1) NOT NULL,
    [MarketplaceProductTagsId]   INT           NOT NULL,
    [CatProductId]               INT           NOT NULL,
    [RowStatus]                  BIT           NOT NULL,
    [TokenCreated]               NVARCHAR (50) NOT NULL,
    [DateCreated]                DATETIME      NOT NULL,
    [TokenUpdated]               NVARCHAR (50) NULL,
    [DateUpdated]                DATETIME      NULL,
    [CatSubscriptionId]          INT           NULL,
    [CatMembershipId]            INT           NULL,
    CONSTRAINT [FK_MarketplaceTagsByProduct_CatProduct] FOREIGN KEY ([CatProductId]) REFERENCES [dbo].[CatProduct] ([IdCatProduct]),
    CONSTRAINT [FK_MarketplaceTagsByProduct_CatSubscription] FOREIGN KEY ([CatSubscriptionId]) REFERENCES [dbo].[CatSubscription] ([IdCatSubscription]),
    CONSTRAINT [FK_MarketplaceTagsByProduct_MarketplaceProductTags] FOREIGN KEY ([MarketplaceProductTagsId]) REFERENCES [dbo].[MarketplaceProductTags] ([IdMarketplaceProductTags])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de modificación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceTagsByProduct', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de modificación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceTagsByProduct', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceTagsByProduct', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceTagsByProduct', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceTagsByProduct', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del producto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceTagsByProduct', @level2type = N'COLUMN', @level2name = N'CatProductId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identicador de la etiqueta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceTagsByProduct', @level2type = N'COLUMN', @level2name = N'MarketplaceProductTagsId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la tabla', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceTagsByProduct', @level2type = N'COLUMN', @level2name = N'IdMarketplaceTagsByProduct';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Varias etiquetas para varios productos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceTagsByProduct';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id relacion con tabla CatSubscription', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceTagsByProduct', @level2type = N'COLUMN', @level2name = N'CatSubscriptionId';


CREATE TABLE [dbo].[MarketplaceCartDetail] (
    [IdMarketplaceCartDetail] INT            IDENTITY (1, 1) NOT NULL,
    [MarketplaceCartId]       INT            NOT NULL,
    [CatProductId]            INT            NOT NULL,
    [RowStatus]               BIT            NOT NULL,
    [TokenCreated]            NVARCHAR (50)  NOT NULL,
    [DateCreated]             DATETIME       NOT NULL,
    [TokenUpdated]            NVARCHAR (50)  NULL,
    [DateUpdated]             DATETIME       NULL,
    [TypeProduct]             NVARCHAR (300) NULL,
    CONSTRAINT [PK_MarketplaceCartDetail] PRIMARY KEY CLUSTERED ([IdMarketplaceCartDetail] ASC),
    CONSTRAINT [FK_MarketplaceCartDetail_CatSubscription] FOREIGN KEY ([CatProductId]) REFERENCES [dbo].[CatSubscription] ([IdCatSubscription]),
    CONSTRAINT [FK_MarketplaceCartDetail_MarketplaceCart] FOREIGN KEY ([MarketplaceCartId]) REFERENCES [dbo].[MarketplaceCart] ([IdMarketplaceCart])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de modificación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceCartDetail', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de modificación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceCartDetail', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceCartDetail', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceCartDetail', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceCartDetail', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Encabezado del carrito', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceCartDetail', @level2type = N'COLUMN', @level2name = N'MarketplaceCartId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceCartDetail', @level2type = N'COLUMN', @level2name = N'IdMarketplaceCartDetail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Detalle de carrito de productos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceCartDetail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Producto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceCartDetail', @level2type = N'COLUMN', @level2name = N'CatProductId';


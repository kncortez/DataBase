CREATE TABLE [dbo].[MarketplaceCart] (
    [IdMarketplaceCart] INT           IDENTITY (1, 1) NOT NULL,
    [AccountId]         BIGINT        NOT NULL,
    [RowStatus]         BIT           NOT NULL,
    [TokenCreated]      NVARCHAR (50) NOT NULL,
    [DateCreated]       DATETIME      NOT NULL,
    [TokenUpdated]      NVARCHAR (50) NULL,
    [DateUpdated]       DATETIME      NULL,
    CONSTRAINT [PK_MarketplaceCart] PRIMARY KEY CLUSTERED ([IdMarketplaceCart] ASC),
    CONSTRAINT [FK_MarketplaceCart_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([AccIdAccount])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de modificación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceCart', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de modificación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceCart', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceCart', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceCart', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceCart', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Carrito de productos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MarketplaceCart';


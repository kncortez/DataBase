CREATE TABLE [dbo].[ExpressAccountServiceCart] (
    [IdExpressAccountServiceCart] BIGINT        IDENTITY (1, 1) NOT NULL,
    [AccountId]                   BIGINT        NOT NULL,
    [CustomerId]                  INT           NULL,
    [CustomerPortfolioId]         INT           NULL,
    [IsPending]                   BIT           NOT NULL,
    [RowStatus]                   BIT           NOT NULL,
    [DateCreated]                 DATETIME      NOT NULL,
    [TokenCreated]                NVARCHAR (50) NOT NULL,
    [DateUpdated]                 DATETIME      NULL,
    [TokenUpdated]                NVARCHAR (50) NULL,
    CONSTRAINT [PK_ExpressAccountServiceCart] PRIMARY KEY CLUSTERED ([IdExpressAccountServiceCart] ASC),
    CONSTRAINT [FK_ExpressAccountServiceCart_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([AccIdAccount]),
    CONSTRAINT [FK_ExpressAccountServiceCart_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([IdCustomer])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'usuario de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExpressAccountServiceCart', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'usaurio que crea elr egistro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExpressAccountServiceCart', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'inidca si el registro esta activo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExpressAccountServiceCart', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicativo si el carrito de compras esta pendiente de finalizarse', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExpressAccountServiceCart', @level2type = N'COLUMN', @level2name = N'IsPending';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'identificador de servicio de carrito cuenta express center', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExpressAccountServiceCart', @level2type = N'COLUMN', @level2name = N'IdExpressAccountServiceCart';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fecha de actualización ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExpressAccountServiceCart', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExpressAccountServiceCart', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del cliente a quien le pertenece el carrito de compras de la tabla VisitPointByClientPortfolio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExpressAccountServiceCart', @level2type = N'COLUMN', @level2name = N'CustomerPortfolioId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del cliente a quien le pertenece el carrito de compras de la tabla Customer', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExpressAccountServiceCart', @level2type = N'COLUMN', @level2name = N'CustomerId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificaciónd e cuenta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExpressAccountServiceCart', @level2type = N'COLUMN', @level2name = N'AccountId';


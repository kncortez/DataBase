CREATE TABLE [dbo].[DeliveryLinkProducts] (
    [IdDeliveryLinkProducts] INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [DeliveryLinkId]         INT             NOT NULL,
    [ProductId]              INT             NOT NULL,
    [Quantity]               INT             NULL,
    [Price]                  DECIMAL (14, 2) NOT NULL,
    [RowStatus]              BIT             NOT NULL,
    [UserCreated]            NVARCHAR (50)   NOT NULL,
    [DateCreated]            DATETIME        NOT NULL,
    [UserUpdated]            NVARCHAR (50)   NULL,
    [DateUpdated]            DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([IdDeliveryLinkProducts] ASC),
    CONSTRAINT [FK_DeliveryLinkProducts_DeliveryLinkId] FOREIGN KEY ([DeliveryLinkId]) REFERENCES [dbo].[DeliveryLink] ([IdDeliveryLink]),
    CONSTRAINT [FK_DeliveryLinkProducts_ProductId] FOREIGN KEY ([ProductId]) REFERENCES [dbo].[Product] ([IdProduct])
);



GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificador de la tabla',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLinkProducts',
    @level2type = N'COLUMN',
    @level2name = N'IdDeliveryLinkProducts'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Link relacionado (FK a DeliveryLink)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLinkProducts',
    @level2type = N'COLUMN',
    @level2name = N'DeliveryLinkId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificador del producto (FK a Product)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLinkProducts',
    @level2type = N'COLUMN',
    @level2name = N'ProductId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Cantidad de productos',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLinkProducts',
    @level2type = N'COLUMN',
    @level2name = N'Quantity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Precio al comprar',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLinkProducts',
    @level2type = N'COLUMN',
    @level2name = N'Price'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado lógico',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLinkProducts',
    @level2type = N'COLUMN',
    @level2name = N'RowStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Usuario de creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLinkProducts',
    @level2type = N'COLUMN',
    @level2name = N'UserCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLinkProducts',
    @level2type = N'COLUMN',
    @level2name = N'DateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Usuario de modificación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLinkProducts',
    @level2type = N'COLUMN',
    @level2name = N'UserUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de modificación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLinkProducts',
    @level2type = N'COLUMN',
    @level2name = N'DateUpdated'
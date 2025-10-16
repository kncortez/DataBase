CREATE TABLE [dbo].[ShippingContainer] (
    [IdContainer]        BIGINT        IDENTITY (1, 1) NOT NULL,
    [ReferenceContainer] NVARCHAR (50) NOT NULL,
    [IdCustomer]         INT           NOT NULL,
    [IdStatusContainer]  INT           NOT NULL,
    [CountGuides]        INT           NULL,
    [RowStatus]          BIT           DEFAULT ((1)) NOT NULL,
    [UserCreated]        NVARCHAR (50) NOT NULL,
    [DateCreated]        DATETIME      NOT NULL,
    [TokenCreated]       NVARCHAR (50) NOT NULL,
    [UserUpdated]        NVARCHAR (50) NULL,
    [DateUpdated]        DATETIME      NULL,
    [TokenUpdated]       NVARCHAR (50) NULL,
    CONSTRAINT [PK_ShippingContainer] PRIMARY KEY CLUSTERED ([IdContainer] ASC),
    CONSTRAINT [FK_ShippingContainer_CatShipContainerStatus] FOREIGN KEY ([IdStatusContainer]) REFERENCES [dbo].[CatShipContainerStatus] ([IdCatStatus]),
    CONSTRAINT [FK_ShippingContainer_Customer] FOREIGN KEY ([IdCustomer]) REFERENCES [dbo].[Customer] ([IdCustomer])
);


GO
CREATE NONCLUSTERED INDEX [IX_ShippingContainer_ReferenceContainer_IdCustomer]
    ON [dbo].[ShippingContainer]([ReferenceContainer] ASC, [IdCustomer] ASC, [RowStatus] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ShippingContainer', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ShippingContainer', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que realizó la actualización del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ShippingContainer', @level2type = N'COLUMN', @level2name = N'UserUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ShippingContainer', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ShippingContainer', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que realizó la creación del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ShippingContainer', @level2type = N'COLUMN', @level2name = N'UserCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ShippingContainer', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de guías', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ShippingContainer', @level2type = N'COLUMN', @level2name = N'CountGuides';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del contenedor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ShippingContainer', @level2type = N'COLUMN', @level2name = N'IdStatusContainer';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ShippingContainer', @level2type = N'COLUMN', @level2name = N'IdCustomer';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la referencia del contenedor ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ShippingContainer', @level2type = N'COLUMN', @level2name = N'ReferenceContainer';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del contenedor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ShippingContainer', @level2type = N'COLUMN', @level2name = N'IdContainer';


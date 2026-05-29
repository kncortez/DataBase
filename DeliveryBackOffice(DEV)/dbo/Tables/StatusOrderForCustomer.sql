CREATE TABLE [dbo].[StatusOrderForCustomer] (
    [CustomerId]    INT     NOT NULL,
    [StatusOrderId] TINYINT NOT NULL,
    [PublicStatus]  BIT     NOT NULL,
    CONSTRAINT [PK_StatusOrderForCustomer] PRIMARY KEY CLUSTERED ([CustomerId] ASC, [StatusOrderId] ASC),
    CONSTRAINT [FK_StatusOrderForCustomer_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [FK_StatusOrderForCustomer_StatusOrder] FOREIGN KEY ([StatusOrderId]) REFERENCES [dbo].[StatusOrder] ([StatusOrderId])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indica si el estado de la orden es visible para el cliente (1) o no (0). Permite personalizar la visualización de estados en función del cliente.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StatusOrderForCustomer', @level2type = N'COLUMN', @level2name = N'PublicStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del estado de la orden. FK hacia la tabla StatusOrder.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StatusOrderForCustomer', @level2type = N'COLUMN', @level2name = N'StatusOrderId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del cliente. FK hacia la tabla Customer.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StatusOrderForCustomer', @level2type = N'COLUMN', @level2name = N'CustomerId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para relacionar los estados de una Guía con un cliente específico, permitiendo personalizar la visualización de estados en función del cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StatusOrderForCustomer';


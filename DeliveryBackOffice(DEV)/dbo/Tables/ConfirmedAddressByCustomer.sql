CREATE TABLE [dbo].[ConfirmedAddressByCustomer] (
    [IdConfirmedAddressByCustomer] BIGINT        IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CustomerId]                   INT           NOT NULL,
    [ConfirmedAddressId]           BIGINT        NOT NULL,
    [RowStatus]                    BIT           CONSTRAINT [DF__Confirmed__RowSt__0C31A3E9] DEFAULT ((1)) NOT NULL,
    [DateCreated]                  DATETIME      NOT NULL,
    [TokenCreated]                 NVARCHAR (50) NOT NULL,
    [DateUpdated]                  DATETIME      NULL,
    [TokenUpdated]                 NVARCHAR (50) NULL,
    CONSTRAINT [PK__Confirme__47DA9DEC2D2550A0] PRIMARY KEY CLUSTERED ([IdConfirmedAddressByCustomer] ASC),
    CONSTRAINT [FK_ConfirmedAddressByCustomer_ConfirmedAddress] FOREIGN KEY ([ConfirmedAddressId]) REFERENCES [dbo].[ConfirmedAddress] ([IdConfirmedAddress]),
    CONSTRAINT [FK_ConfirmedAddressByCustomer_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [UK_ConfirmedAddressByCustomer_CustomerAddress] UNIQUE NONCLUSTERED ([CustomerId] ASC, [ConfirmedAddressId] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmedAddressByCustomer', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmedAddressByCustomer', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmedAddressByCustomer', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmedAddressByCustomer', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmedAddressByCustomer', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la dirección de la tabla ConfirmedAddress.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmedAddressByCustomer', @level2type = N'COLUMN', @level2name = N'ConfirmedAddressId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del cliente de la tabla Customer.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmedAddressByCustomer', @level2type = N'COLUMN', @level2name = N'CustomerId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmedAddressByCustomer', @level2type = N'COLUMN', @level2name = N'IdConfirmedAddressByCustomer';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla que relaciona clientes con direcciones confirmadas.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfirmedAddressByCustomer';


CREATE TABLE [dbo].[CodBankAccount] (
    [CodBankAccountId] INT            NOT NULL,
    [CustomerId]       INT            NOT NULL,
    [BankId]           INT            NOT NULL,
    [BankAccountId]    NVARCHAR (50)  NOT NULL,
    [BankAccountName]  NVARCHAR (200) NULL,
    [BankAccountType]  NVARCHAR (40)  NOT NULL,
    [CurrencyId]       INT            NOT NULL,
    [RowStatus]        BIT            NOT NULL,
    [TokenCreated]     NVARCHAR (50)  NOT NULL,
    [DateCreated]      DATETIME       NOT NULL,
    [TokenUpdated]     NVARCHAR (50)  NULL,
    [DateUpdated]      DATETIME       NULL,
    CONSTRAINT [PK_CodBankAccount] PRIMARY KEY CLUSTERED ([CodBankAccountId] ASC),
    CONSTRAINT [FK_CodBankAccount_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [FK_CodBankAccount_DeliveryBank] FOREIGN KEY ([BankId]) REFERENCES [dbo].[DeliveryBank] ([Id_bank]),
    CONSTRAINT [FK_CodBankAccount_DeliveryCurrency] FOREIGN KEY ([CurrencyId]) REFERENCES [dbo].[DeliveryCurrency] ([Currency_Id])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cuentas bancarias de clientes por COD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodBankAccount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de cuenta bancaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodBankAccount', @level2type = N'COLUMN', @level2name = N'CodBankAccountId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodBankAccount', @level2type = N'COLUMN', @level2name = N'CustomerId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del banco', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodBankAccount', @level2type = N'COLUMN', @level2name = N'BankId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de cuenta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodBankAccount', @level2type = N'COLUMN', @level2name = N'BankAccountId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre de la cuenta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodBankAccount', @level2type = N'COLUMN', @level2name = N'BankAccountName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipo de cuenta

Monetaria, ahorros', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodBankAccount', @level2type = N'COLUMN', @level2name = N'BankAccountType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipo de moneda', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodBankAccount', @level2type = N'COLUMN', @level2name = N'CurrencyId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de la cuenta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodBankAccount', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodBankAccount', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodBankAccount', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodBankAccount', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodBankAccount', @level2type = N'COLUMN', @level2name = N'DateUpdated';


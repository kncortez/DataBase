CREATE TABLE [dbo].[AccountServiceCart] (
    [IdAccountServiceCart] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [AccountId]            BIGINT        NOT NULL,
    [IsPending]            BIT           CONSTRAINT [DF__AccountSe__IsPen__2A61254E] DEFAULT ((1)) NOT NULL,
    [RowStatus]            BIT           CONSTRAINT [DF__AccountSe__RowSt__2B554987] DEFAULT ((1)) NOT NULL,
    [TokenCreated]         NVARCHAR (50) NOT NULL,
    [DateCreated]          DATETIME      NOT NULL,
    [TokenUpdated]         NVARCHAR (50) NULL,
    [DateUpdated]          DATETIME      NULL,
    CONSTRAINT [PK__AccountS__98CDC45FA2464CEA] PRIMARY KEY CLUSTERED ([IdAccountServiceCart] ASC),
    CONSTRAINT [FK_AccountServiceCart_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([AccIdAccount])
);






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountServiceCart', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountServiceCart', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountServiceCart', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountServiceCart', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountServiceCart', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indica si el carrito de compras esta pendiente de finalizar.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountServiceCart', @level2type = N'COLUMN', @level2name = N'IsPending';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la cuenta de Account.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountServiceCart', @level2type = N'COLUMN', @level2name = N'AccountId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountServiceCart', @level2type = N'COLUMN', @level2name = N'IdAccountServiceCart';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de carrito de compras por cuenta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountServiceCart';


GO
CREATE NONCLUSTERED INDEX [IDX_AccountId_IsPending_RowStatus_IdAccountServiceCart]
    ON [dbo].[AccountServiceCart]([AccountId] ASC, [IsPending] ASC, [RowStatus] ASC, [IdAccountServiceCart] ASC);


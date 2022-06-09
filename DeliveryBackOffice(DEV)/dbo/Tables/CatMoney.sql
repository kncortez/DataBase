CREATE TABLE [dbo].[CatMoney] (
    [IdCatMoney]   INT            IDENTITY (1, 1) NOT NULL,
    [CurrencyId]   INT            NOT NULL,
    [Type]         VARCHAR (10)   NOT NULL,
    [Value]        DECIMAL (8, 2) NOT NULL,
    [RowStatus]    BIT            CONSTRAINT [DF_CatMoney_RowStatus] DEFAULT ('TRUE') NOT NULL,
    [TokenCreated] NVARCHAR (50)  NOT NULL,
    [DateCreated]  DATETIME       NOT NULL,
    [TokenUpdated] NVARCHAR (50)  NULL,
    [DateUpdated]  DATETIME       NULL,
    CONSTRAINT [PK_CatMoney_IdCatMoney] PRIMARY KEY CLUSTERED ([IdCatMoney] ASC),
    CONSTRAINT [FK_CatMoney_CurrencyId] FOREIGN KEY ([CurrencyId]) REFERENCES [dbo].[DeliveryCurrency] ([Currency_Id])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catálogo para almacenar las denominaciones por divisa.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatMoney';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla CatMoney', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatMoney', @level2type = N'COLUMN', @level2name = N'IdCatMoney';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla DeliveryCurrency, que indica el id de la divisa.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatMoney', @level2type = N'COLUMN', @level2name = N'CurrencyId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipo del dinero, BILLETE o MONEDA.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatMoney', @level2type = N'COLUMN', @level2name = N'Type';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor del dinero.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatMoney', @level2type = N'COLUMN', @level2name = N'Value';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de la fila, TRUE o FALSE.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatMoney', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que creo la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatMoney', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora en la que se creo la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatMoney', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que actualizó la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatMoney', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora en la que se actualizó la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatMoney', @level2type = N'COLUMN', @level2name = N'DateUpdated';


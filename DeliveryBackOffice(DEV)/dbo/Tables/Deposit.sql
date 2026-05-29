CREATE TABLE [dbo].[Deposit] (
    [IdDeposit]            BIGINT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [TransactionNumber]    BIGINT          NOT NULL,
    [TransactionDate]      DATETIME        NOT NULL,
    [TransactionCode]      INT             NOT NULL,
    [Reference]            NVARCHAR (15)   NOT NULL,
    [Amount]               DECIMAL (19, 4) NOT NULL,
    [Balance]              DECIMAL (19, 4) NOT NULL,
    [UserIdDeposit]        NVARCHAR (50)   NOT NULL,
    [UserNameDeposit]      NVARCHAR (50)   NOT NULL,
    [UserNickNameDeposit]  NVARCHAR (50)   NOT NULL,
    [UserDocumentNumber]   NVARCHAR (20)   NOT NULL,
    [CurrencyISO]          NVARCHAR (10)   NOT NULL,
    [CurrencyIdExternal]   INT             NOT NULL,
    [ClientIdExternal]     BIGINT          NOT NULL,
    [ClientCardCode]       NVARCHAR (15)   NOT NULL,
    [ClientNameExternal]   NVARCHAR (500)  NOT NULL,
    [VisitPointIdExternal] BIGINT          NOT NULL,
    [VisitPointName]       NVARCHAR (100)  NOT NULL,
    [BankIdExternal]       INT             NOT NULL,
    [BankCardCode]         NVARCHAR (50)   NOT NULL,
    [BankNameExternal]     NVARCHAR (50)   NOT NULL,
    [BankAccountNumber]    NVARCHAR (50)   NOT NULL,
    [BankAccountIsMak]     BIT             NOT NULL,
    [BankAccountIsIBAN]    BIT             NOT NULL,
    [BankAccountIsSWIFT]   BIT             NOT NULL,
    [TerminalId]           INT             NOT NULL,
    [TerminalSerie]        NVARCHAR (50)   NOT NULL,
    [RowStatus]            BIT             NOT NULL,
    [TokenCreated]         NVARCHAR (100)  NOT NULL,
    [DateCreated]          DATETIME        NOT NULL,
    [TokenUpdated]         NVARCHAR (100)  NULL,
    [DateUpdated]          DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([IdDeposit] ASC)
);




GO
CREATE UNIQUE INDEX IX_Deposit_TransactionNumber ON dbo.Deposit(TransactionNumber);

GO
CREATE INDEX IX_Deposit_TraCode_TerSerie_TraDate ON dbo.Deposit (TransactionCode, TerminalSerie, TransactionDate);

GO


GO


GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Registro de depósitos monetarios recibidos por Efectibox.',
@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit';
	
GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del depósito (PK).',
@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'IdDeposit';

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Número de transacción externo (único).',
@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'TransactionNumber';

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha/hora del depósito.',
@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'TransactionDate';

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Código de la transacción de Efectibox (No necesariamente único).',
@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'TransactionCode';

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Referencia externa (routeCode).',
@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'Reference';

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Importe total del depósito.',
@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'Amount';

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Saldo restante del depósito (Amount menos aplicaciones a manifiestos).',
@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'Balance';

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'ID del usuario externo que registró el depósito.',
@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'UserIdDeposit';

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del usuario externo que registró el depósito.',
@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'UserNameDeposit';

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Alias del usuario externo que registró el depósito.',
@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'UserNickNameDeposit';

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Identificación del usuario externo que registró el depósito.',
@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'UserDocumentNumber';

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Código de moneda externo (idealmente ISO 4217).',
@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'CurrencyISO';

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador externo de Efectibox de la moneda asociada al monto.',
@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'CurrencyIdExternal';

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del cliente/comercio externo.',
@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'ClientIdExternal';

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Código/tarjeta del cliente externo (cardCode).',
@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'ClientCardCode';

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del cliente/comercio externo.',
@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'ClientNameExternal';

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del punto de visita del cliente externo.',
@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'VisitPointIdExternal';

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del punto de visita externo.',
@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'VisitPointName';

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del banco externo.',
@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'BankIdExternal';

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Código/tarjeta del banco externo.',
@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'BankCardCode';

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del banco externo.',
@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'BankNameExternal';

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Número de cuenta bancaria externa.',
@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'BankAccountNumber';

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Indicador específico externo.',
@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'BankAccountIsMak';

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Indicador externo booleano de si la cuenta utiliza formato IBAN.',
@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'BankAccountIsIBAN';

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Indicador externo booleano de si la cuenta posee código SWIFT.',
@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'BankAccountIsSWIFT';

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador externo de la terminal donde se procesó la transacción.',
@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'TerminalId';

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Serie o etiqueta de la terminal.',
@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'TerminalSerie';

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Estado lógico: 1=Activo, 0=Inactivo.',
@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'RowStatus';

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Token de creación.',
@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'TokenCreated';

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha/hora de creación del registro.',
@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'DateCreated';

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Token de última actualización.',
@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'TokenUpdated';

GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha/hora de la última actualización.',
@level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'DateUpdated';

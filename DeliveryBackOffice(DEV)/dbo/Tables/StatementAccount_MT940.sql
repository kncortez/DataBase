CREATE TABLE [dbo].[StatementAccount_MT940] (
    [Account]                  BIGINT          NOT NULL,
    [SequenceNumber]           VARCHAR (20)    NOT NULL,
    [Reference]                VARCHAR (50)    NULL,
    [Currency]                 CHAR (3)        NOT NULL,
    [TransactionDate]          DATE            NOT NULL,
    [TransactionType]          CHAR (1)        NOT NULL,
    [TransactionAmount]        DECIMAL (18, 2) NOT NULL,
    [TransactionOperationType] VARCHAR (10)    NULL,
    [TransactionReference]     BIGINT          NULL,
    [TransactionDescription]   VARCHAR (255)   NULL,
    [OpeningBalance]           DECIMAL (18, 2) NOT NULL,
    [OpeningBalanceType]       CHAR (1)        NOT NULL,
    [ClosingBalance]           DECIMAL (18, 2) NOT NULL,
    [ClosingBalanceType]       CHAR (1)        NOT NULL,
    [CreationDate]             DATETIME        CONSTRAINT [DF_MT940_CreationDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [CK_MT940_ClosingBalanceType] CHECK ([ClosingBalanceType]='D' OR [ClosingBalanceType]='C'),
    CONSTRAINT [CK_MT940_Currency] CHECK ([Currency] like '[A-Z][A-Z][A-Z]'),
    CONSTRAINT [CK_MT940_OpeningBalanceType] CHECK ([OpeningBalanceType]='D' OR [OpeningBalanceType]='C'),
    CONSTRAINT [CK_MT940_TransactionType] CHECK ([TransactionType]='D' OR [TransactionType]='C')
);


GO
CREATE NONCLUSTERED INDEX [IX_MT940_TransactionReference]
    ON [dbo].[StatementAccount_MT940]([TransactionReference] ASC) WHERE ([TransactionReference] IS NOT NULL);


GO
CREATE NONCLUSTERED INDEX [IX_MT940_SequenceNumber]
    ON [dbo].[StatementAccount_MT940]([SequenceNumber] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_MT940_Cuenta_Fecha]
    ON [dbo].[StatementAccount_MT940]([Account] ASC, [TransactionDate] ASC);


CREATE TABLE [dbo].[StatementAccount_MT940_Temp] (
    [Account]                  BIGINT          NULL,
    [SequenceNumber]           VARCHAR (20)    NULL,
    [Reference]                VARCHAR (50)    NULL,
    [Currency]                 CHAR (3)        NULL,
    [TransactionDate]          DATE            NULL,
    [TransactionType]          CHAR (1)        NULL,
    [TransactionAmount]        DECIMAL (18, 2) NULL,
    [TransactionOperationType] VARCHAR (10)    NULL,
    [TransactionReference]     BIGINT          NULL,
    [TransactionDescription]   VARCHAR (255)   NULL,
    [OpeningBalance]           DECIMAL (18, 2) NULL,
    [OpeningBalanceType]       CHAR (1)        NULL,
    [ClosingBalance]           DECIMAL (18, 2) NULL,
    [ClosingBalanceType]       CHAR (1)        NULL
);


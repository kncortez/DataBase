CREATE TABLE [dbo].[TransactionType] (
    [IdTransactionType] INT            IDENTITY (1, 1) NOT NULL,
    [Name]              NVARCHAR (100) NOT NULL,
    [Description]       NVARCHAR (200) NOT NULL,
    [RowStatus]         BIT            NOT NULL,
    [TokenCreated]      NVARCHAR (50)  NOT NULL,
    [DateCreated]       DATETIME       NOT NULL,
    [TokenUpdated]      NVARCHAR (50)  NULL,
    [DateUpdated]       DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdTransactionType] ASC)
);


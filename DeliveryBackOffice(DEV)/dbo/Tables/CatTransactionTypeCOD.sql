CREATE TABLE [dbo].[CatTransactionTypeCOD] (
    [IdCatTransactionTypeCOD] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [TransactionType]         NVARCHAR (10) NOT NULL,
    [Description]             NVARCHAR (50) NOT NULL,
    [BankId]                  INT           NOT NULL,
    [RowStatus]               BIT           CONSTRAINT [DF_CatTransactionTypeCOD_RowStatus] DEFAULT ('TRUE') NOT NULL,
    [TokenCreated]            NVARCHAR (50) NOT NULL,
    [DateCreated]             DATETIME      CONSTRAINT [DF_CatTransactionTypeCOD_DateCreated] DEFAULT (getdate()) NOT NULL,
    [TokenUpdated]            NVARCHAR (50) NULL,
    [DateUpdated]             DATETIME      NULL,
    CONSTRAINT [PK_CatTransactionTypeCOD_IdCatTransactionTypeCOD] PRIMARY KEY CLUSTERED ([IdCatTransactionTypeCOD] ASC),
    CONSTRAINT [FK_CatTransactionTypeCOD_DeliveryBank] FOREIGN KEY ([BankId]) REFERENCES [dbo].[DeliveryBank] ([Id_bank]),
    CONSTRAINT [UK_CatTransactionTypeCOD_TransactionType_BankId] UNIQUE NONCLUSTERED ([TransactionType] ASC, [BankId] ASC)
);


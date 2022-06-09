CREATE TABLE [dbo].[CatDebitAccountCOD] (
    [IdCatDebitAccountCOD] INT           IDENTITY (1, 1) NOT NULL,
    [AccountNumber]        NVARCHAR (50) NOT NULL,
    [BankId]               INT           NOT NULL,
    [RowStatus]            BIT           CONSTRAINT [DF_CatDebitAccountCOD_RowStatus] DEFAULT ('TRUE') NOT NULL,
    [TokenCreated]         NVARCHAR (50) NOT NULL,
    [DateCreated]          DATETIME      CONSTRAINT [DF_CatDebitAccountCOD_DateCreated] DEFAULT (getdate()) NOT NULL,
    [TokenUpdated]         NVARCHAR (50) NULL,
    [DateUpdated]          DATETIME      NULL,
    [CatAccountTypeCODId]  INT           NULL,
    CONSTRAINT [PK_CatDebitAccountCOD_IdCatDebitAccountCOD] PRIMARY KEY CLUSTERED ([IdCatDebitAccountCOD] ASC),
    FOREIGN KEY ([CatAccountTypeCODId]) REFERENCES [dbo].[CatAccountTypeCOD] ([IdCatAccountTypeCOD]),
    CONSTRAINT [FK_CatDebitAccountCOD_DeliveryBank] FOREIGN KEY ([BankId]) REFERENCES [dbo].[DeliveryBank] ([Id_bank]),
    CONSTRAINT [UK_CatDebitAccountCOD_AccountNumber] UNIQUE NONCLUSTERED ([AccountNumber] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipo de cuenta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatDebitAccountCOD', @level2type = N'COLUMN', @level2name = N'CatAccountTypeCODId';


CREATE TABLE [dbo].[BankAccountCheck] (
    [IdConfirmAccount]            INT           IDENTITY (1, 1) NOT NULL,
    [NumAccount]                  VARCHAR (50)  NOT NULL,
    [NameAccount]                 VARCHAR (MAX) NOT NULL,
    [BankId]                      INT           NOT NULL,
    [TypeAccountId]               INT           NOT NULL,
    [CustomerId]                  INT           NULL,
    [CatStatusBankAccountCheckId] INT           NULL,
    [TokenCreated]                NVARCHAR (50) NULL,
    [DateCreate]                  DATETIME      NULL,
    [TokenUpdate]                 NVARCHAR (50) NULL,
    [DateUpdate]                  DATETIME      NULL,
    [RowStatus]                   BIT           NULL,
    PRIMARY KEY CLUSTERED ([IdConfirmAccount] ASC),
    CONSTRAINT [FK_BankAccountCheck_Bank] FOREIGN KEY ([BankId]) REFERENCES [dbo].[DeliveryBank] ([Id_bank]),
    CONSTRAINT [FK_BankAccountCheck_CatBankAccountType] FOREIGN KEY ([TypeAccountId]) REFERENCES [dbo].[CatBankAccountType] ([IdBankAccountType]),
    CONSTRAINT [FK_BankAccountCheck_CatStatusBankAccountCheck] FOREIGN KEY ([CatStatusBankAccountCheckId]) REFERENCES [dbo].[CatStatusBankAccountCheck] ([IdCatStatusBankAccountCheck]),
    CONSTRAINT [FK_BankAccountCheck_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([IdCustomer])
);


GO
CREATE NONCLUSTERED INDEX [IX_CA_IdBank]
    ON [dbo].[BankAccountCheck]([BankId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CA_NumAccount]
    ON [dbo].[BankAccountCheck]([NumAccount] ASC);


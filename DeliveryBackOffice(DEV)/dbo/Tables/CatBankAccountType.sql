CREATE TABLE [dbo].[CatBankAccountType] (
    [IdBankAccountType] INT           IDENTITY (1, 1) NOT NULL,
    [BankAccountType]   NVARCHAR (50) NOT NULL,
    [RowStatus]         BIT           CONSTRAINT [DF_CatBankAccountType_RowStatus] DEFAULT ('TRUE') NOT NULL,
    [TokenCreated]      NVARCHAR (50) NOT NULL,
    [DateCreated]       DATETIME      NOT NULL,
    [TokenUpdated]      NVARCHAR (50) NULL,
    [DateUpdated]       DATETIME      NULL,
    CONSTRAINT [PK_CatBankAccountType] PRIMARY KEY CLUSTERED ([IdBankAccountType] ASC)
);


CREATE TABLE [dbo].[CatBankColumnRuleCOD] (
    [IdCatBankColumnRuleCOD] INT           IDENTITY (1, 1) NOT NULL,
    [CatBankColumnCODId]     INT           NOT NULL,
    [CatRuleCODId]           INT           NOT NULL,
    [RowStatus]              BIT           CONSTRAINT [DF_CatBankColumnRuleCOD_RowStatus] DEFAULT ('TRUE') NOT NULL,
    [TokenCreated]           NVARCHAR (50) NOT NULL,
    [DateCreated]            DATETIME      CONSTRAINT [DF_CatBankColumnRuleCOD_DateCreated] DEFAULT (getdate()) NOT NULL,
    [TokenUpdated]           NVARCHAR (50) NULL,
    [DateUpdated]            DATETIME      NULL,
    CONSTRAINT [PK_CatBankColumnRuleCOD_IdCatBankColumnRuleCOD] PRIMARY KEY CLUSTERED ([IdCatBankColumnRuleCOD] ASC),
    CONSTRAINT [FK_CatBankColumnRuleCOD_CatBankColumnCOD] FOREIGN KEY ([CatBankColumnCODId]) REFERENCES [dbo].[CatBankColumnCOD] ([IdCatBankColumnCOD]),
    CONSTRAINT [FK_CatBankColumnRuleCOD_CatRuleCOD] FOREIGN KEY ([CatRuleCODId]) REFERENCES [dbo].[CatRuleCOD] ([IdCatRuleCOD]),
    CONSTRAINT [UK_CatBankColumnRuleCOD_CatBankColumnCODId_CatRuleCODId] UNIQUE NONCLUSTERED ([CatBankColumnCODId] ASC, [CatRuleCODId] ASC)
);


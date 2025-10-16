CREATE TABLE [dbo].[CatBankColumnCOD] (
    [IdCatBankColumnCOD] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [BankId]             INT           NOT NULL,
    [CatColumnCODId]     INT           NOT NULL,
    [Order]              INT           NOT NULL,
    [RowStatus]          BIT           CONSTRAINT [DF_CatBankColumnCOD_RowStatus] DEFAULT ('TRUE') NOT NULL,
    [TokenCreated]       NVARCHAR (50) NOT NULL,
    [DateCreated]        DATETIME      CONSTRAINT [DF_CatBankColumnCOD_DateCreated] DEFAULT (getdate()) NOT NULL,
    [TokenUpdated]       NVARCHAR (50) NULL,
    [DateUpdated]        DATETIME      NULL,
    CONSTRAINT [PK_CatBankColumnCOD_IdCatBankColumnCOD] PRIMARY KEY CLUSTERED ([IdCatBankColumnCOD] ASC),
    CONSTRAINT [FK_CatBankColumnCOD_CatColumnCOD] FOREIGN KEY ([CatColumnCODId]) REFERENCES [dbo].[CatColumnCOD] ([IdCatColumnCOD]),
    CONSTRAINT [FK_CatBankColumnCOD_DeliveryBank] FOREIGN KEY ([BankId]) REFERENCES [dbo].[DeliveryBank] ([Id_bank]),
    CONSTRAINT [UK_CatBankColumnCOD_BankId_CatColumnCODId] UNIQUE NONCLUSTERED ([BankId] ASC, [CatColumnCODId] ASC)
);


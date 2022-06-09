CREATE TABLE [dbo].[CatCorrelativeCOD] (
    [IdCatCorrelativeCOD] INT           IDENTITY (1, 1) NOT NULL,
    [Begin]               INT           CONSTRAINT [DF_CatCorrelativeCOD_Begin] DEFAULT ((1)) NOT NULL,
    [End]                 INT           NOT NULL,
    [Last]                INT           CONSTRAINT [DF_CatCorrelativeCOD_Last] DEFAULT ((1)) NOT NULL,
    [BankId]              INT           NOT NULL,
    [RowStatus]           BIT           CONSTRAINT [DF_CatCorrelativeCOD_RowStatus] DEFAULT ('TRUE') NOT NULL,
    [TokenCreated]        NVARCHAR (50) NOT NULL,
    [DateCreated]         DATETIME      CONSTRAINT [DF_CatCorrelativeCOD_DateCreated] DEFAULT (getdate()) NOT NULL,
    [TokenUpdated]        NVARCHAR (50) NULL,
    [DateUpdated]         DATETIME      NULL,
    CONSTRAINT [PK_CatCorrelativeCOD_IdCatCorrelativeCOD] PRIMARY KEY CLUSTERED ([IdCatCorrelativeCOD] ASC),
    CONSTRAINT [FK_CatCorrelativeCOD_DeliveryBank] FOREIGN KEY ([BankId]) REFERENCES [dbo].[DeliveryBank] ([Id_bank]),
    CONSTRAINT [UK_CatCorrelativeCOD_Begin_End_BankId] UNIQUE NONCLUSTERED ([Begin] ASC, [End] ASC, [BankId] ASC)
);


CREATE TABLE [dbo].[CatEmailProcessCOD] (
    [IdCatEmailProcessCOD]  INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CatReceiverEmailCODId] INT           NOT NULL,
    [CatProcessCODId]       INT           NOT NULL,
    [RowStatus]             BIT           CONSTRAINT [DF_CatEmailProcessCOD_RowStatus] DEFAULT ('TRUE') NOT NULL,
    [TokenCreated]          NVARCHAR (50) NOT NULL,
    [DateCreated]           DATETIME      CONSTRAINT [DF_CatEmailProcessCOD_DateCreated] DEFAULT (getdate()) NOT NULL,
    [TokenUpdated]          NVARCHAR (50) NULL,
    [DateUpdated]           DATETIME      NULL,
    CONSTRAINT [PK_CatEmailProcessCOD_IdCatEmailProcessCOD] PRIMARY KEY CLUSTERED ([IdCatEmailProcessCOD] ASC),
    CONSTRAINT [FK_CatEmailProcessCOD_CatProcessCOD] FOREIGN KEY ([CatProcessCODId]) REFERENCES [dbo].[CatProcessCOD] ([IdCatProcessCOD]),
    CONSTRAINT [FK_CatEmailProcessCOD_CatReceiverEmailCOD] FOREIGN KEY ([CatReceiverEmailCODId]) REFERENCES [dbo].[CatReceiverEmailCOD] ([IdCatReceiverEmailCOD]),
    CONSTRAINT [UK_CatEmailProcessCOD_CatProcessCODId_CatReceiverEmailCODId] UNIQUE NONCLUSTERED ([CatProcessCODId] ASC, [CatReceiverEmailCODId] ASC)
);


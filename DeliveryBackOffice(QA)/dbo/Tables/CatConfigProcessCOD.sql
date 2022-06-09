CREATE TABLE [dbo].[CatConfigProcessCOD] (
    [IdCatConfigProcessCOD] INT           IDENTITY (1, 1) NOT NULL,
    [CatProcessCODId]       INT           NOT NULL,
    [CatScheduleCODId]      INT           NOT NULL,
    [RowStatus]             BIT           CONSTRAINT [DF_CatConfigProcessCOD_RowStatus] DEFAULT ('TRUE') NOT NULL,
    [TokenCreated]          NVARCHAR (50) NOT NULL,
    [DateCreated]           DATETIME      CONSTRAINT [DF_CatConfigProcessCOD_DateCreated] DEFAULT (getdate()) NOT NULL,
    [TokenUpdated]          NVARCHAR (50) NULL,
    [DateUpdated]           DATETIME      NULL,
    CONSTRAINT [PK_CatConfigProcessCOD_IdCatConfigProcessCOD] PRIMARY KEY CLUSTERED ([IdCatConfigProcessCOD] ASC),
    CONSTRAINT [FK_CatProcessCOD_IdCatProcessCOD_CatConfigProcessCOD_CatProcessCODId] FOREIGN KEY ([CatProcessCODId]) REFERENCES [dbo].[CatProcessCOD] ([IdCatProcessCOD]),
    CONSTRAINT [FK_CatScheduleCOD_IdCatScheduleCOD_CatConfigProcessCOD_CatScheduleCODId] FOREIGN KEY ([CatScheduleCODId]) REFERENCES [dbo].[CatScheduleCOD] ([IdCatScheduleCOD]),
    CONSTRAINT [UK_CatConfigProcessCOD_CatProcessCODId_CatScheduleCODId] UNIQUE NONCLUSTERED ([CatProcessCODId] ASC, [CatScheduleCODId] ASC)
);


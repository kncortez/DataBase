CREATE TABLE [dbo].[CatColumnCOD] (
    [IdCatColumnCOD]           INT           IDENTITY (1, 1) NOT NULL,
    [ColumnName]               NVARCHAR (50) NOT NULL,
    [BatchDetailCODColumnName] NVARCHAR (50) NOT NULL,
    [RowStatus]                BIT           CONSTRAINT [DF_CatColumn_RowStatus] DEFAULT ('TRUE') NOT NULL,
    [TokenCreated]             NVARCHAR (50) NOT NULL,
    [DateCreated]              DATETIME      CONSTRAINT [DF_CatColumn_DateCreated] DEFAULT (getdate()) NOT NULL,
    [TokenUpdated]             NVARCHAR (50) NULL,
    [DateUpdated]              DATETIME      NULL,
    CONSTRAINT [PK_CatColumnCOD_IdCatColumnCOD] PRIMARY KEY CLUSTERED ([IdCatColumnCOD] ASC),
    CONSTRAINT [UK_CatColumnCOD_ColumnName_BatchDetailCODColumnName] UNIQUE NONCLUSTERED ([ColumnName] ASC, [BatchDetailCODColumnName] ASC)
);


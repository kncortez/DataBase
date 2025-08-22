CREATE TABLE [dbo].[CatAccountTypeCOD] (
    [IdCatAccountTypeCOD] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [AccountType]         NVARCHAR (50) NOT NULL,
    [Description]         NVARCHAR (50) NULL,
    [RowStatus]           BIT           CONSTRAINT [DF_CatAccountTypeCOD_RowStatus] DEFAULT ('TRUE') NOT NULL,
    [TokenCreated]        NVARCHAR (50) NOT NULL,
    [DateCreated]         DATETIME      CONSTRAINT [DF_CatAccountTypeCOD_DateCreated] DEFAULT (getdate()) NOT NULL,
    [TokenUpdated]        NVARCHAR (50) NULL,
    [DateUpdated]         DATETIME      NULL,
    CONSTRAINT [PK_CatAccountTypeCOD_IdCatAccountTypeCOD] PRIMARY KEY CLUSTERED ([IdCatAccountTypeCOD] ASC),
    CONSTRAINT [UK_CatAccountTypeCOD_AccountType] UNIQUE NONCLUSTERED ([AccountType] ASC)
);


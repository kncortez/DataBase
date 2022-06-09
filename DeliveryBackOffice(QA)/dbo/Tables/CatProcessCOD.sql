CREATE TABLE [dbo].[CatProcessCOD] (
    [IdCatProcessCOD] INT             IDENTITY (1, 1) NOT NULL,
    [Name]            NVARCHAR (50)   NOT NULL,
    [Description]     NVARCHAR (1000) NOT NULL,
    [RowStatus]       BIT             CONSTRAINT [DF_CatProcessCOD_RowStatus] DEFAULT ('TRUE') NOT NULL,
    [TokenCreated]    NVARCHAR (50)   NOT NULL,
    [DateCreated]     DATETIME        CONSTRAINT [DF_CatProcessCOD_DateCreated] DEFAULT (getdate()) NOT NULL,
    [TokenUpdated]    NVARCHAR (50)   NULL,
    [DateUpdated]     DATETIME        NULL,
    CONSTRAINT [PK_CatProcessCOD_IdCatProcessCOD] PRIMARY KEY CLUSTERED ([IdCatProcessCOD] ASC),
    CONSTRAINT [UK_CatProcessCOD_Name] UNIQUE NONCLUSTERED ([Name] ASC)
);


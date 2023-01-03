CREATE TABLE [dbo].[CatAttribute] (
    [IdCatAttribute] INT           IDENTITY (1, 1) NOT NULL,
    [AttributeName]  NVARCHAR (50) NOT NULL,
    [RowStatus]      BIT           NOT NULL,
    [TokenCreated]   NVARCHAR (50) NOT NULL,
    [DateCreated]    DATETIME      NOT NULL,
    [TokenUpdated]   NVARCHAR (50) NULL,
    [DateUpdated]    DATETIME      NULL,
    CONSTRAINT [PK_CatAttribute] PRIMARY KEY CLUSTERED ([IdCatAttribute] ASC)
);


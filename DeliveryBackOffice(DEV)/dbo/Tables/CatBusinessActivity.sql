CREATE TABLE [dbo].[CatBusinessActivity] (
    [IdBusinessActivity]          INT            IDENTITY (1, 1) NOT NULL,
    [BusinessActivityName]        NVARCHAR (75)  NOT NULL,
    [BusinessActivityDescription] NVARCHAR (200) NULL,
    [RowStatus]                   BIT            NOT NULL,
    [TokenCreated]                NVARCHAR (50)  NOT NULL,
    [DateCreated]                 DATETIME       NOT NULL,
    [TokenUpdated]                NVARCHAR (50)  NULL,
    [DateUpdated]                 DATETIME       NULL,
    CONSTRAINT [PK_CatBusinessActivity] PRIMARY KEY CLUSTERED ([IdBusinessActivity] ASC)
);


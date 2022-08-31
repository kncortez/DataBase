CREATE TABLE [dbo].[CatTypeAct] (
    [IdCatTypeAct]   INT            IDENTITY (1, 1) NOT NULL,
    [ActName]        NVARCHAR (50)  NOT NULL,
    [ActDescription] NVARCHAR (200) NULL,
    [RowStatus]      BIT            DEFAULT ((1)) NOT NULL,
    [TokenCreated]   NVARCHAR (50)  NOT NULL,
    [DateCreated]    DATETIME       NOT NULL,
    [TokenUpdated]   NVARCHAR (50)  NULL,
    [DateUpdated]    DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdCatTypeAct] ASC)
);


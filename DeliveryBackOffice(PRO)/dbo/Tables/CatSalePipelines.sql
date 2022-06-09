CREATE TABLE [dbo].[CatSalePipelines] (
    [IdSalePipeLine] INT           IDENTITY (1, 1) NOT NULL,
    [Name]           VARCHAR (50)  NOT NULL,
    [ShortName]      VARCHAR (10)  NOT NULL,
    [Description]    VARCHAR (100) NULL,
    [RowStatus]      BIT           NOT NULL,
    [TokenCreated]   VARCHAR (50)  NOT NULL,
    [DateCreated]    DATETIME      NOT NULL,
    [TokenUpdated]   VARCHAR (50)  NULL,
    [DateUpdated]    DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdSalePipeLine] ASC)
);


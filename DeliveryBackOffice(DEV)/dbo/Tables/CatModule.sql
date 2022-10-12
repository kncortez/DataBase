CREATE TABLE [dbo].[CatModule] (
    [ModIdModule]       INT           IDENTITY (1, 1) NOT NULL,
    [ModName]           VARCHAR (100) NOT NULL,
    [ModIdModuleParent] INT           NULL,
    [ModPath]           VARCHAR (200) NOT NULL,
    [ModDescription]    VARCHAR (150) NULL,
    [ModOrder]          INT           NOT NULL,
    [ModMetadata]       VARCHAR (50)  NULL,
    [ModVisible]        BIT           NOT NULL,
    [ModRowStatus]      BIT           NOT NULL,
    [ModTokenCreated]   VARCHAR (50)  NOT NULL,
    [ModDateCreated]    DATETIME      NOT NULL,
    [ModTokenUpdated]   VARCHAR (50)  NULL,
    [ModDateUpdated]    DATETIME      NULL,
    [ModGroup]          INT           NULL,
    PRIMARY KEY CLUSTERED ([ModIdModule] ASC),
    FOREIGN KEY ([ModIdModuleParent]) REFERENCES [dbo].[CatModule] ([ModIdModule])
);






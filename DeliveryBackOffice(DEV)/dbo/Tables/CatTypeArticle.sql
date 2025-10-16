CREATE TABLE [dbo].[CatTypeArticle] (
    [TarId]           INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [TarIdPackage]    INT          NOT NULL,
    [TarName]         VARCHAR (50) NOT NULL,
    [TarRowStatus]    BIT          NOT NULL,
    [TarTokenCreated] VARCHAR (50) NOT NULL,
    [TarDateCreated]  DATETIME     NOT NULL,
    [TarTokenUpdated] VARCHAR (50) NULL,
    [TarDateUpdated]  DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([TarId] ASC),
    FOREIGN KEY ([TarIdPackage]) REFERENCES [dbo].[CatPackage] ([PckId])
);


CREATE TABLE [dbo].[CatArticle] (
    [ArtId]            INT             IDENTITY (1, 1) NOT NULL,
    [ArtIdTypeArticle] INT             NOT NULL,
    [ArtName]          VARCHAR (50)    NOT NULL,
    [ArtShowDefault]   BIT             NOT NULL,
    [ArtRowStatus]     BIT             NOT NULL,
    [ArtTokenCreated]  VARCHAR (50)    NOT NULL,
    [ArtDateCreated]   DATETIME        NOT NULL,
    [ArtTokenUpdated]  VARCHAR (50)    NULL,
    [ArtDateUpdated]   DATETIME        NULL,
    [ArtHeight]        DECIMAL (18, 2) NULL,
    [ArtWidth]         DECIMAL (18, 2) NULL,
    [ArtLength]        DECIMAL (18, 2) NULL,
    [ArtMassWeight]    DECIMAL (18, 2) NULL,
    PRIMARY KEY CLUSTERED ([ArtId] ASC),
    FOREIGN KEY ([ArtIdTypeArticle]) REFERENCES [dbo].[CatTypeArticle] ([TarId])
);


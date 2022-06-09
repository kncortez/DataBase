CREATE TABLE [dbo].[CatRateSegment] (
    [CrsId]           INT           IDENTITY (1, 1) NOT NULL,
    [CrsName]         VARCHAR (100) NOT NULL,
    [CrsShortName]    VARCHAR (3)   NOT NULL,
    [CrsDescription]  VARCHAR (200) NULL,
    [CrsRowStatus]    BIT           NOT NULL,
    [CrsTokenCreated] VARCHAR (50)  NOT NULL,
    [CrsDateCreated]  DATETIME      NOT NULL,
    [CrsTokenUpdated] VARCHAR (50)  NULL,
    [CrsDateUpdated]  DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([CrsId] ASC)
);


CREATE TABLE [dbo].[CatTypeAccount] (
    [TacIdTypeAccount] INT           IDENTITY (1, 1) NOT NULL,
    [TacShortName]     VARCHAR (3)   NOT NULL,
    [TacName]          VARCHAR (30)  NOT NULL,
    [TacDescription]   VARCHAR (100) NOT NULL,
    [TacRowStatus]     BIT           NOT NULL,
    [TacTokenCreated]  VARCHAR (50)  NOT NULL,
    [TacDateCreated]   DATE          NOT NULL,
    [TacTokenUpdated]  VARCHAR (50)  NULL,
    [TacDateUpdated]   DATE          NULL,
    PRIMARY KEY CLUSTERED ([TacIdTypeAccount] ASC)
);


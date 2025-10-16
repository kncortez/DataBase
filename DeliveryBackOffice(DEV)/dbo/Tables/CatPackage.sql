CREATE TABLE [dbo].[CatPackage] (
    [PckId]           INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [PckName]         VARCHAR (50) NOT NULL,
    [PckRowStatus]    BIT          NOT NULL,
    [PckTokenCreated] VARCHAR (50) NOT NULL,
    [PckDateCreated]  DATETIME     NOT NULL,
    [PckTokenUpdated] VARCHAR (50) NULL,
    [PckDateUpdated]  DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([PckId] ASC)
);


CREATE TABLE [dbo].[CatLinehaul_03122021] (
    [IdLinehaul]       INT            IDENTITY (1, 1) NOT NULL,
    [IdRoute]          INT            NOT NULL,
    [IdHubOrigin]      INT            NOT NULL,
    [IdHubDestination] INT            NOT NULL,
    [Emails]           NVARCHAR (MAX) NOT NULL,
    [RowStatus]        BIT            NOT NULL,
    [TokenCreated]     VARCHAR (50)   NOT NULL,
    [DateCreated]      DATETIME       NOT NULL,
    [TokenUpdated]     VARCHAR (50)   NULL,
    [DateUpdated]      DATETIME       NULL
);


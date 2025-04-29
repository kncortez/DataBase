CREATE TABLE [dbo].[CatLinehaul] (
    [IdLinehaul]       INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [IdRoute]          INT            NOT NULL,
    [IdHubOrigin]      INT            NOT NULL,
    [IdHubDestination] INT            NOT NULL,
    [Emails]           NVARCHAR (MAX) NOT NULL,
    [RowStatus]        BIT            NOT NULL,
    [TokenCreated]     VARCHAR (50)   NOT NULL,
    [DateCreated]      DATETIME       NOT NULL,
    [TokenUpdated]     VARCHAR (50)   NULL,
    [DateUpdated]      DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdLinehaul] ASC),
    CONSTRAINT [FK_CatLinehaulRoute] FOREIGN KEY ([IdRoute]) REFERENCES [dbo].[CatRoute] ([IdRoute]),
    CONSTRAINT [FK_IdHubDestination_IdHubLogistic] FOREIGN KEY ([IdHubDestination]) REFERENCES [dbo].[HubLogistics] ([IdHubLogistic]),
    CONSTRAINT [FK_IdHubOrigin_IdHubLogistic] FOREIGN KEY ([IdHubOrigin]) REFERENCES [dbo].[HubLogistics] ([IdHubLogistic])
);






GO
CREATE NONCLUSTERED INDEX [idx_IdRoute_IdHubDestination]
    ON [dbo].[CatLinehaul]([IdRoute] ASC, [IdHubDestination] ASC)
    INCLUDE([Emails]);


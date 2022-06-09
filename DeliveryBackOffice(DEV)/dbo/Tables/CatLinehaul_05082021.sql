CREATE TABLE [dbo].[CatLinehaul_05082021] (
    [IdLinehaul]       INT            IDENTITY (1, 1) NOT NULL,
    [IdRoute]          INT            NOT NULL,
    [IdHubOrigin]      INT            NOT NULL,
    [IdHubDestination] INT            NOT NULL,
    [Emails]           NVARCHAR (MAX) NOT NULL,
    [RowStatus]        BIT            NOT NULL,
    [TokenCreated]     VARCHAR (50)   NOT NULL,
    [DateCreated]      DATETIME       NOT NULL,
    [TokenUpdated]     VARCHAR (50)   NULL,
    [DateUpdated]      DATETIME       NULL,
    CONSTRAINT [PK__CatLineh__DCEC9BDA7249D872_05082021_05082021] PRIMARY KEY CLUSTERED ([IdLinehaul] ASC),
    CONSTRAINT [FK_CatLinehaulRoute_05082021] FOREIGN KEY ([IdRoute]) REFERENCES [dbo].[CatRoute] ([IdRoute]),
    CONSTRAINT [FK_IdHubDestination_IdHubLogistic_05082021] FOREIGN KEY ([IdHubDestination]) REFERENCES [dbo].[HubLogistics] ([IdHubLogistic]),
    CONSTRAINT [FK_IdHubOrigin_IdHubLogistic_05082021] FOREIGN KEY ([IdHubOrigin]) REFERENCES [dbo].[HubLogistics] ([IdHubLogistic])
);


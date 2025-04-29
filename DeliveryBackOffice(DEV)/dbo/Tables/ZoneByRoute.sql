CREATE TABLE [dbo].[ZoneByRoute] (
    [IdZoneByRoute] INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [RouteId]       INT            NOT NULL,
    [TownshipId]    INT            NOT NULL,
    [Zone]          NVARCHAR (50)  NULL,
    [RowStauts]     BIT            NOT NULL,
    [TokenCreated]  NVARCHAR (200) NOT NULL,
    [DateCreated]   DATETIME       NOT NULL,
    [TokenUpdated]  NVARCHAR (200) NULL,
    [DateUpdated]   DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdZoneByRoute] ASC),
    CONSTRAINT [FKRoute] FOREIGN KEY ([RouteId]) REFERENCES [dbo].[CatRoute] ([IdRoute]),
    CONSTRAINT [FKTownship] FOREIGN KEY ([TownshipId]) REFERENCES [dbo].[Township] ([IdTownship])
);


CREATE TABLE [dbo].[TownshipByHubLogistic] (
    [IdTownshipHub]      INT          IDENTITY (1, 1) NOT NULL,
    [IdTownship]         INT          NULL,
    [IdHublogistic]      INT          NULL,
    [StatusTownshipHub]  BIT          NULL,
    [TownshipHubDefault] BIT          NULL,
    [TokenCreated]       VARCHAR (50) NULL,
    [DateCreated]        DATETIME     NULL,
    [TokenUpdate]        VARCHAR (50) NULL,
    [DateUpdated]        DATETIME     NULL,
    [IdRateSegment]      INT          NULL,
    CONSTRAINT [PK_TownshipByHubLogistic] PRIMARY KEY CLUSTERED ([IdTownshipHub] ASC),
    CONSTRAINT [FK_TownshipByHubLogistic_HubLogistics] FOREIGN KEY ([IdHublogistic]) REFERENCES [dbo].[HubLogistics] ([IdHubLogistic]),
    CONSTRAINT [FK_TownshipByHubLogistic_Township] FOREIGN KEY ([IdTownship]) REFERENCES [dbo].[Township] ([IdTownship]),
    CONSTRAINT [FKHubRateSegment] FOREIGN KEY ([IdRateSegment]) REFERENCES [dbo].[CatRateSegment] ([CrsId])
);


GO
CREATE NONCLUSTERED INDEX [IX_TownshipByHubLogistic_IdTownship]
    ON [dbo].[TownshipByHubLogistic]([IdTownship] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_TownshipByHubLogistic_IdHublogistic]
    ON [dbo].[TownshipByHubLogistic]([IdHublogistic] ASC);


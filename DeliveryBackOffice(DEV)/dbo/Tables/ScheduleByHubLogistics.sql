CREATE TABLE [dbo].[ScheduleByHubLogistics] (
    [SbhId]                  BIGINT       IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [SbhIdCatService]        INT          NOT NULL,
    [SbhIdRateSegment]       INT          NOT NULL,
    [SbhIdIdHubLogistics]    INT          NOT NULL,
    [SbhCollectionTimeLimit] TIME (7)     NULL,
    [SbhDeliveryTimeLimit]   TIME (7)     NULL,
    [SbhRowStatus]           BIT          NOT NULL,
    [SbhTokenCreated]        VARCHAR (50) NOT NULL,
    [SbhDateCreated]         DATETIME     NOT NULL,
    [SbhTokenUpdated]        VARCHAR (50) NULL,
    [SbhDateUpdated]         DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([SbhId] ASC),
    CONSTRAINT [FKSbhHubLogistic] FOREIGN KEY ([SbhIdIdHubLogistics]) REFERENCES [dbo].[HubLogistics] ([IdHubLogistic]),
    CONSTRAINT [FKSbhIdCatServiceCatSerivice] FOREIGN KEY ([SbhIdCatService]) REFERENCES [dbo].[CatTypeService] ([CtsId]),
    CONSTRAINT [FKSbhRateSegemnt] FOREIGN KEY ([SbhIdRateSegment]) REFERENCES [dbo].[CatRateSegment] ([CrsId])
);


CREATE TABLE [dbo].[VisitPointCoverage] (
    [IdVpbySegment] INT          IDENTITY (1, 1) NOT NULL,
    [VisitPointId]  INT          NOT NULL,
    [HubLogisticId] INT          NOT NULL,
    [SegmentId]     INT          NOT NULL,
    [RowStatus]     BIT          NOT NULL,
    [TokenCreated]  VARCHAR (50) NOT NULL,
    [DateCreated]   DATETIME     NOT NULL,
    [TokenUpdated]  VARCHAR (50) NULL,
    [DateUpdated]   DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([IdVpbySegment] ASC),
    CONSTRAINT [FKHubVP] FOREIGN KEY ([HubLogisticId]) REFERENCES [dbo].[HubLogistics] ([IdHubLogistic]),
    CONSTRAINT [FKSegmentVP] FOREIGN KEY ([SegmentId]) REFERENCES [dbo].[CatRateSegment] ([CrsId]),
    CONSTRAINT [FKVpSegment] FOREIGN KEY ([VisitPointId]) REFERENCES [dbo].[VisitPointClient] ([CodeOfReference])
);


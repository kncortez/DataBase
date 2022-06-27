CREATE TABLE [dbo].[ScheduledVisitSettlement] (
    [IdSettScheduleVisit]     BIGINT        IDENTITY (1, 1) NOT NULL,
    [IdSettlement]            BIGINT        NULL,
    [IdSegmentArea]           INT           NULL,
    [Comment]                 NVARCHAR (50) NULL,
    [OrderSequence]           INT           NULL,
    [ScheduledVisitSunday]    BIT           NULL,
    [ScheduledVisitMonday]    BIT           NULL,
    [ScheduledVisitTuesday]   BIT           NULL,
    [ScheduledVisitWednesday] BIT           NULL,
    [ScheduledVisitThursday]  BIT           NULL,
    [ScheduledVisitFriday]    BIT           NULL,
    [ScheduledVisitSaturday]  BIT           NULL,
    [SettScheduleVisitStatus] BIT           NULL,
    [TokenCreated]            NVARCHAR (50) NULL,
    [DateCreated]             DATETIME      NULL,
    [TokenUpdated]            NVARCHAR (50) NULL,
    [DateUpdated]             DATETIME      NULL,
    [IdVisitPointClient]      INT           NULL,
    CONSTRAINT [PK_ScheduledVisitSettlement] PRIMARY KEY CLUSTERED ([IdSettScheduleVisit] ASC),
    CONSTRAINT [FK_ScheduledVisitSettlement_SegmentArea] FOREIGN KEY ([IdSegmentArea]) REFERENCES [dbo].[SegmentArea] ([IdSegmentArea]),
    CONSTRAINT [FK_ScheduledVisitSettlement_Settlement] FOREIGN KEY ([IdSettlement]) REFERENCES [dbo].[Settlement] ([IdSettlement]),
    CONSTRAINT [FK_ScheduledVisitSettlement_VisitPointClient] FOREIGN KEY ([IdVisitPointClient]) REFERENCES [dbo].[VisitPointClient] ([CodeOfReference])
);




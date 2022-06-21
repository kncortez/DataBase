CREATE TABLE [dbo].[VisitPointItinerary_Copy] (
    [IdVPItinerary]             BIGINT        IDENTITY (1, 1) NOT NULL,
    [VPFrequencyID]             BIGINT        NULL,
    [DayOfVisit]                INT           NULL,
    [InitializationTimeOfVisit] NVARCHAR (5)  NULL,
    [FinalizationTimeOfVisit]   NVARCHAR (5)  NULL,
    [OrderSequence]             INT           NULL,
    [RouteCodeID]               INT           NULL,
    [HubLogisticID]             INT           NULL,
    [RowStatus]                 BIT           NULL,
    [TokenCreated]              NVARCHAR (50) NULL,
    [DateCreated]               DATETIME      NULL,
    [TokenUpdated]              NVARCHAR (50) NULL,
    [DateUpdated]               DATETIME      NULL
);


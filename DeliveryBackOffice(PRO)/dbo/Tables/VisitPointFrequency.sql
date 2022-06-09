CREATE TABLE [dbo].[VisitPointFrequency] (
    [IdVPFrequency]     BIGINT        IDENTITY (1, 1) NOT NULL,
    [VPConfigurationID] BIGINT        NOT NULL,
    [SeasonID]          INT           NULL,
    [VisitsOnSunday]    TINYINT       NULL,
    [VisitsOnMonday]    TINYINT       NULL,
    [VisitsOnTuesday]   TINYINT       NULL,
    [VisitsOnWednesday] TINYINT       NULL,
    [VisitsOnThursday]  TINYINT       NULL,
    [VisitsOnFriday]    TINYINT       NULL,
    [VisitsOnSaturday]  TINYINT       NULL,
    [HubLogisticID]     INT           NULL,
    [RowStatus]         BIT           NULL,
    [TokenCreated]      NVARCHAR (50) NULL,
    [DateCreated]       DATETIME      NULL,
    [TokenUpdated]      NVARCHAR (50) NULL,
    [DateUpdated]       DATETIME      NULL,
    CONSTRAINT [PK_VisitPointFrequency] PRIMARY KEY CLUSTERED ([IdVPFrequency] ASC),
    CONSTRAINT [FK_VisitPointFrequency_CatSeason] FOREIGN KEY ([SeasonID]) REFERENCES [dbo].[CatSeason] ([IdSeason]),
    CONSTRAINT [FK_VisitPointFrequency_HubLogistics] FOREIGN KEY ([HubLogisticID]) REFERENCES [dbo].[HubLogistics] ([IdHubLogistic]),
    CONSTRAINT [FK_VisitPointFrequency_VisitPointConfiguration] FOREIGN KEY ([VPConfigurationID]) REFERENCES [dbo].[VisitPointConfiguration] ([IdVPConfiguration])
);


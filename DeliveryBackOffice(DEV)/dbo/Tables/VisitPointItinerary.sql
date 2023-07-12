CREATE TABLE [dbo].[VisitPointItinerary] (
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
    [DateUpdated]               DATETIME      NULL,
    CONSTRAINT [PK_VisitPointItinerary] PRIMARY KEY CLUSTERED ([IdVPItinerary] ASC),
    CONSTRAINT [FK_VisitPointItinerary_CatRoute] FOREIGN KEY ([RouteCodeID]) REFERENCES [dbo].[CatRoute] ([IdRoute]),
    CONSTRAINT [FK_VisitPointItinerary_HubLogistics] FOREIGN KEY ([HubLogisticID]) REFERENCES [dbo].[HubLogistics] ([IdHubLogistic]),
    CONSTRAINT [FK_VisitPointItinerary_VisitPointFrequency] FOREIGN KEY ([VPFrequencyID]) REFERENCES [dbo].[VisitPointFrequency] ([IdVPFrequency])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para registro de itinerarios de recolección por punto de visita.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointItinerary';


CREATE TABLE [dbo].[UnifiedRouteSettlement] (
    [IdUnifiedRouteSettlement] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [RouteAssignmentId]        INT           NOT NULL,
    [TotalGuidesSettled]       INT           CONSTRAINT [DF_UnifiedRouteSettlement_TotalGuidesSettled] DEFAULT ((0)) NOT NULL,
    [TotalPiecesSettled]       INT           DEFAULT ((0)) NOT NULL,
    [TotalPiecesMissing]       INT           DEFAULT ((0)) NOT NULL,
    [UserSettlement]           NVARCHAR (50) NULL,
    [DateSettlement]           DATETIME      NULL,
    [SettlementStation]        INT           NULL,
    [TotalCODGuidesSettled]    INT           DEFAULT ((0)) NOT NULL,
    [UserCODSettlement]        NVARCHAR (50) NULL,
    [DateCODSettlement]        DATETIME      NULL,
    [CODSettlementStation]     INT           NULL,
    [RowStatus]                BIT           DEFAULT ((1)) NOT NULL,
    [TokenCreated]             NVARCHAR (50) NOT NULL,
    [DateCreated]              DATETIME      NOT NULL,
    [TokenUpdated]             NVARCHAR (50) NULL,
    [DateUpdated]              DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdUnifiedRouteSettlement] ASC)
);


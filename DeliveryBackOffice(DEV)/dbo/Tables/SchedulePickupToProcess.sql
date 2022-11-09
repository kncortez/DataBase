CREATE TABLE [dbo].[SchedulePickupToProcess] (
    [IdSchedulePickupToProcess] INT            IDENTITY (1, 1) NOT NULL,
    [StartDate]                 DATETIME       NOT NULL,
    [EndDate]                   DATETIME       NOT NULL,
    [SenderID]                  INT            NOT NULL,
    [SenderName]                NVARCHAR (200) NOT NULL,
    [SenderAddress]             NVARCHAR (600) NOT NULL,
    [SpecialInstructions]       NVARCHAR (600) NULL,
    [EstimatedPackages]         INT            CONSTRAINT [DF_SchedulePickupToProcess_EstimatedPackages] DEFAULT ((1)) NOT NULL,
    [TypeVehicleId]             INT            NULL,
    [HubLogisticsId]            INT            NULL,
    [TokenAuthorized]           NVARCHAR (50)  NULL,
    [DateAuthorized]            DATETIME       NULL,
    [RowStatus]                 INT            CONSTRAINT [DF_SchedulePickupToProcess_RowStatus] DEFAULT ((1)) NOT NULL,
    [DateCreated]               DATETIME       NOT NULL,
    [TokenCreated]              NVARCHAR (50)  NOT NULL,
    [DateUpdated]               DATETIME       NULL,
    [TokenUpdated]              NVARCHAR (50)  NULL,
    CONSTRAINT [PK_SchedulePickupToProcess] PRIMARY KEY CLUSTERED ([IdSchedulePickupToProcess] ASC)
);


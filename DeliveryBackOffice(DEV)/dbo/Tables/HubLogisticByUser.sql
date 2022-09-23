CREATE TABLE [dbo].[HubLogisticByUser] (
    [IdHubLogisticByUser] INT           IDENTITY (1, 1) NOT NULL,
    [HubLogisticId]       INT           NOT NULL,
    [UserId]              BIGINT        NOT NULL,
    [RowStatus]           BIT           CONSTRAINT [DF_HubLogisticByUser_RowStatus] DEFAULT ((1)) NOT NULL,
    [TokenCreated]        NVARCHAR (50) NOT NULL,
    [DateCreated]         DATETIME      NOT NULL,
    [TokenUpdated]        NVARCHAR (50) NULL,
    [DateUpdated]         DATETIME      NULL,
    CONSTRAINT [PK_HubLogisticByUser] PRIMARY KEY CLUSTERED ([IdHubLogisticByUser] ASC),
    CONSTRAINT [FK_HubLogisticByUser_HubLogistic] FOREIGN KEY ([HubLogisticId]) REFERENCES [dbo].[HubLogistics] ([IdHubLogistic]),
    CONSTRAINT [FK_HubLogisticByUser_RegisterUser] FOREIGN KEY ([UserId]) REFERENCES [dbo].[RegisterUser] ([UsrIdUser])
);


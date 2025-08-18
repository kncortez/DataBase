CREATE TABLE [dbo].[CatWayToPay] (
    [WayPayId]          INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [WayPayName]        VARCHAR (55)  NULL,
    [WayPayDescription] VARCHAR (100) NULL,
    [WayPayAbrev]       VARCHAR (10)  NULL,
    [WayPayStatus]      INT           NULL,
    [TokenCreated]      VARCHAR (50)  NOT NULL,
    [DateCreated]       DATETIME      NOT NULL,
    [TokenUpdated]      VARCHAR (50)  NULL,
    [DateUpdated]       DATETIME      NULL,
    CONSTRAINT [WayPayId] PRIMARY KEY CLUSTERED ([WayPayId] ASC)
);


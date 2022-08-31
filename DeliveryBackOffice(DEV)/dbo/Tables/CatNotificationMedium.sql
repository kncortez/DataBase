CREATE TABLE [dbo].[CatNotificationMedium] (
    [IdCatNotificationMedium] INT          IDENTITY (1, 1) NOT NULL,
    [NotificationMediumName]  VARCHAR (50) NOT NULL,
    [RowStatus]               BIT          NOT NULL,
    [TokenCreated]            VARCHAR (50) NOT NULL,
    [DateCreated]             DATETIME     NOT NULL,
    [TokenUpdated]            VARCHAR (50) NULL,
    [DateUpdated]             DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([IdCatNotificationMedium] ASC)
);


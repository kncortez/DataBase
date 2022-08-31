CREATE TABLE [dbo].[NotificationMediumByTypeIncidence] (
    [IdNotificationMediumByTypeIncidence] INT          IDENTITY (1, 1) NOT NULL,
    [IncidenceNotificationId]             INT          NOT NULL,
    [IncidenceActionId]                   INT          NOT NULL,
    [RowStatus]                           BIT          NOT NULL,
    [TokenCreated]                        VARCHAR (50) NOT NULL,
    [DateCreated]                         DATETIME     NOT NULL,
    [TokenUpdated]                        VARCHAR (50) NULL,
    [DateUpdated]                         DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([IdNotificationMediumByTypeIncidence] ASC),
    CONSTRAINT [NotificationMediumByTypeIncidence_FK] FOREIGN KEY ([IdNotificationMediumByTypeIncidence]) REFERENCES [dbo].[CatIncidenceAction] ([IdCatIncidenceAction])
);


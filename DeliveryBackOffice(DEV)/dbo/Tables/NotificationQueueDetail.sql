CREATE TABLE [dbo].[NotificationQueueDetail] (
    [IdNotificationQueueDetail] BIGINT        IDENTITY (1, 1) NOT NULL,
    [NotificationQueueId]       BIGINT        NOT NULL,
    [GuideSerie]                NVARCHAR (10) NULL,
    [GuideNumber]               INT           NULL,
    [MembershipId]              INT           NULL,
    [SubscriptionId]            INT           NULL,
    [RowStatus]                 BIT           DEFAULT ((1)) NOT NULL,
    [TokenCreated]              NVARCHAR (50) NOT NULL,
    [DateCreated]               DATETIME      NOT NULL,
    [TokenUpdated]              NVARCHAR (50) NULL,
    [DateUpdated]               DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdNotificationQueueDetail] ASC),
    CONSTRAINT [FK_NotificationQueueDetail_Membership] FOREIGN KEY ([MembershipId]) REFERENCES [dbo].[Membership] ([IdMembership]),
    CONSTRAINT [FK_NotificationQueueDetail_NotificationQueue] FOREIGN KEY ([NotificationQueueId]) REFERENCES [dbo].[NotificationQueue] ([IdNotificationQueue]),
    CONSTRAINT [FK_NotificationQueueDetail_Subscription] FOREIGN KEY ([SubscriptionId]) REFERENCES [dbo].[Subscription] ([IdSubscription])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotificationQueueDetail', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que actualizó el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotificationQueueDetail', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotificationQueueDetail', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que generó el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotificationQueueDetail', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotificationQueueDetail', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la suscripción referenciada | Tabla Subscription', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotificationQueueDetail', @level2type = N'COLUMN', @level2name = N'SubscriptionId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la membresía referenciada | Tabla Membership', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotificationQueueDetail', @level2type = N'COLUMN', @level2name = N'MembershipId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de la guía referenciada | Tabla DeliveryOrder | No es llave foránea', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotificationQueueDetail', @level2type = N'COLUMN', @level2name = N'GuideNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de la guía referenciada | Tabla DeliveryOrder | No es llave foránea', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotificationQueueDetail', @level2type = N'COLUMN', @level2name = N'GuideSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Encabezado de cola de notificaciones asociado | Tabla NotificationQueue', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotificationQueueDetail', @level2type = N'COLUMN', @level2name = N'NotificationQueueId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotificationQueueDetail', @level2type = N'COLUMN', @level2name = N'IdNotificationQueueDetail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para guardar detalle de cola de notificaciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotificationQueueDetail';


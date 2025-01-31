CREATE TABLE [dbo].[NotificationTrackingLog] (
    [IdNotificationTrackingLog]     INT IDENTITY (1, 1) NOT NULL,
    [Title]                         NVARCHAR (50) NOT NULL,
    [Message]                       NVARCHAR (150) NOT NULL,
    [StatusOrderId]                 TINYINT NOT NULL,
    [IdNotificationTracking]        INT NOT NULL,
    [IdActionNotification]          INT NOT NULL,
    [IsRead]                        BIT NOT NULL DEFAULT 0,
    [RowStatus]                     BIT NOT NULL DEFAULT 1,
    [UserCreated]                   NVARCHAR(50) NOT NULL,
	[DateCreated]                   DATETIME NOT NULL,
	[TokenCreated]                  NVARCHAR(50) NOT NULL,
    [UserUpdated]                   NVARCHAR(50) NULL,
	[DateUpdated]                   DATETIME NULL,
	[TokenUpdated]                  NVARCHAR(50) NULL,
    CONSTRAINT [PK_NotificationTrackingLog] PRIMARY KEY CLUSTERED ([IdNotificationTrackingLog] ASC),
    CONSTRAINT [FK_NotificationTrackingLog_StatusOrder] FOREIGN KEY (StatusOrderId) REFERENCES [dbo].[StatusOrder] (StatusOrderId),
    CONSTRAINT [FK_NotificationTrackingLog_NotificationTracking] FOREIGN KEY ([IdNotificationTracking]) REFERENCES [dbo].[NotificationTracking] ([IdNotificationTracking]),
    CONSTRAINT [FK_NotificationTrackingLog_CatActionNotification] FOREIGN KEY ([IdActionNotification]) REFERENCES [dbo].[CatActionNotification] ([IdActionNotification])
);

CREATE NONCLUSTERED INDEX [IDX_NotificationTrackingLog_DateCreated]
    ON [dbo].[NotificationTrackingLog]([DateCreated] ASC);
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Identificador de la notificación', N'SCHEMA', N'dbo', N'TABLE', N'NotificationTrackingLog', N'COLUMN', N'IdNotificationTrackingLog'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Título de la notificación', N'SCHEMA', N'dbo', N'TABLE', N'NotificationTrackingLog', N'COLUMN', N'Title'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Mensaje de la notificación', N'SCHEMA', N'dbo', N'TABLE', N'NotificationTrackingLog', N'COLUMN', N'Message'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Estado de la guía, de la tabla StatusOrder', N'SCHEMA', N'dbo', N'TABLE', N'NotificationTrackingLog', N'COLUMN', N'StatusOrderId'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Identificador de la suscripción de la tabla NotificationTracking', N'SCHEMA', N'dbo', N'TABLE', N'NotificationTrackingLog', N'COLUMN', N'IdNotificationTracking'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Identificador del tipo de acción de la tabla CatActionNotification', N'SCHEMA', N'dbo', N'TABLE', N'NotificationTrackingLog', N'COLUMN', N'IdActionNotification'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Valida si la notificacion ya fue leída', N'SCHEMA', N'dbo', N'TABLE', N'NotificationTrackingLog', N'COLUMN', N'IsRead'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Estado lógico del registro', N'SCHEMA', N'dbo', N'TABLE', N'NotificationTrackingLog', N'COLUMN', N'RowStatus'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Usuario que realizó la creación del registro', N'SCHEMA', N'dbo', N'TABLE', N'NotificationTrackingLog', N'COLUMN', N'UserCreated'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Fecha de creación del registro', N'SCHEMA', N'dbo', N'TABLE', N'NotificationTrackingLog', N'COLUMN', N'DateCreated'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Token de creación del registro', N'SCHEMA', N'dbo', N'TABLE', N'NotificationTrackingLog', N'COLUMN', N'TokenCreated'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Usuario que realizó la actualización del registro', N'SCHEMA', N'dbo', N'TABLE', N'NotificationTrackingLog', N'COLUMN', N'UserUpdated'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Última fecha de actualización del registro', N'SCHEMA', N'dbo', N'TABLE', N'NotificationTrackingLog', N'COLUMN', N'DateUpdated'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Último token de actualización del registro', N'SCHEMA', N'dbo', N'TABLE', N'NotificationTrackingLog', N'COLUMN', N'TokenUpdated'
GO

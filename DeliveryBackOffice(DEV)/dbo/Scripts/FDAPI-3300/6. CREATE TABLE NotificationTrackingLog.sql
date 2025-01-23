CREATE TABLE [dbo].[NotificationTrackingLog] (
    [IdNotificationTrackingLog]     INT IDENTITY (1, 1) NOT NULL,
    [Title]                         NVARCHAR (50) NOT NULL,
    [Message]                       NVARCHAR (150) NOT NULL,
    [StatusOrderId]                 TINYINT NOT NULL,
    [IdGuideSuscription]            INT NOT NULL,
    [RowStatus]                     BIT NOT NULL DEFAULT 1,
    [UserCreated]                   NVARCHAR(50) NOT NULL,
	[DateCreated]                   DATETIME NOT NULL,
	[TokenCreated]                  NVARCHAR(50) NOT NULL,
    [UserUpdated]                   NVARCHAR(50) NULL,
	[DateUpdated]                   DATETIME NULL,
	[TokenUpdated]                  NVARCHAR(50) NULL,
    CONSTRAINT [PK_NotificationTrackingLog] PRIMARY KEY CLUSTERED ([IdNotificationTrackingLog] ASC),
    CONSTRAINT [FK_NotificationTrackingLog_StatusOrder] FOREIGN KEY (StatusOrderId) REFERENCES [dbo].[StatusOrder] (StatusOrderId),
    CONSTRAINT [FK_NotificationTrackingLog_GuideSuscription] FOREIGN KEY ([IdGuideSuscription]) REFERENCES [dbo].[GuideSuscription] ([IdGuideSuscription])
);
EXECUTE sp_addextendedproperty N'MS_Description', N'Identificador de la notificación', N'SCHEMA', N'dbo', N'TABLE', N'NotificationTrackingLog', N'COLUMN', N'IdNotificationTrackingLog'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Título de la notificación', N'SCHEMA', N'dbo', N'TABLE', N'NotificationTrackingLog', N'COLUMN', N'Title'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Mensaje de la notificación', N'SCHEMA', N'dbo', N'TABLE', N'NotificationTrackingLog', N'COLUMN', N'Message'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Estado de la guía, de la tabla StatusOrder', N'SCHEMA', N'dbo', N'TABLE', N'NotificationTrackingLog', N'COLUMN', N'StatusOrderId'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Identificador de la suscripción de la guía de la tabla GuideSuscription', N'SCHEMA', N'dbo', N'TABLE', N'NotificationTrackingLog', N'COLUMN', N'IdGuideSuscription'
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

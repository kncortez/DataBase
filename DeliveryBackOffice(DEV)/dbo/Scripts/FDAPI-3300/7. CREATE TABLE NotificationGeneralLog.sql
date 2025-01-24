CREATE TABLE [dbo].[NotificationGeneralLog] (
    [IdNotificationGeneralLog]      INT IDENTITY (1, 1) NOT NULL,
    [Title]                         NVARCHAR (50) NOT NULL,
    [Message]                       NVARCHAR (150) NOT NULL,
    [IdNotificationGeneral]         INT NOT NULL,
    [RowStatus]                     BIT NOT NULL DEFAULT 1,
    [UserCreated]                   NVARCHAR(50) NOT NULL,
	[DateCreated]                   DATETIME NOT NULL,
	[TokenCreated]                  NVARCHAR(50) NOT NULL,
    [UserUpdated]                   NVARCHAR(50) NULL,
	[DateUpdated]                   DATETIME NULL,
	[TokenUpdated]                  NVARCHAR(50) NULL,
    CONSTRAINT [PK_NotificationGeneralLog] PRIMARY KEY CLUSTERED ([IdNotificationGeneralLog] ASC),
    CONSTRAINT [FK_NotificationGeneralLog_NotificationGeneral] FOREIGN KEY ([IdNotificationGeneral]) REFERENCES [dbo].[NotificationGeneral] ([IdNotificationGeneral])
);
EXECUTE sp_addextendedproperty N'MS_Description', N'Identificador de la notificación', N'SCHEMA', N'dbo', N'TABLE', N'NotificationGeneralLog', N'COLUMN', N'IdNotificationGeneralLog'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Título de la notificación', N'SCHEMA', N'dbo', N'TABLE', N'NotificationGeneralLog', N'COLUMN', N'Title'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Mensaje de la notificación', N'SCHEMA', N'dbo', N'TABLE', N'NotificationGeneralLog', N'COLUMN', N'Message'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Identificador de la suscripción de la tabla NotificationGeneral', N'SCHEMA', N'dbo', N'TABLE', N'NotificationGeneralLog', N'COLUMN', N'IdNotificationGeneral'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Estado lógico del registro', N'SCHEMA', N'dbo', N'TABLE', N'NotificationGeneralLog', N'COLUMN', N'RowStatus'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Usuario que realizó la creación del registro', N'SCHEMA', N'dbo', N'TABLE', N'NotificationGeneralLog', N'COLUMN', N'UserCreated'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Fecha de creación del registro', N'SCHEMA', N'dbo', N'TABLE', N'NotificationGeneralLog', N'COLUMN', N'DateCreated'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Token de creación del registro', N'SCHEMA', N'dbo', N'TABLE', N'NotificationGeneralLog', N'COLUMN', N'TokenCreated'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Usuario que realizó la actualización del registro', N'SCHEMA', N'dbo', N'TABLE', N'NotificationGeneralLog', N'COLUMN', N'UserUpdated'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Última fecha de actualización del registro', N'SCHEMA', N'dbo', N'TABLE', N'NotificationGeneralLog', N'COLUMN', N'DateUpdated'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Último token de actualización del registro', N'SCHEMA', N'dbo', N'TABLE', N'NotificationGeneralLog', N'COLUMN', N'TokenUpdated'
GO

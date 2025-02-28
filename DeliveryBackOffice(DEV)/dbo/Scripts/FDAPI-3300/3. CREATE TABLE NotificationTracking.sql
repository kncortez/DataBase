CREATE TABLE [dbo].[NotificationTracking] (
    [IdNotificationTracking]     INT IDENTITY (1, 1) NOT NULL,
    [IdOneSignal]                   NVARCHAR (100) NOT NULL,
    [IdAccount]                     BIGINT NULL,
    [IdTypeSuscription]             INT NOT NULL,
    [RowStatus]                     BIT NOT NULL DEFAULT 1,
    [UserCreated]                   NVARCHAR(50) NOT NULL,
	[DateCreated]                   DATETIME NOT NULL,
	[TokenCreated]                  NVARCHAR(50) NOT NULL,
    [UserUpdated]                   NVARCHAR(50) NULL,
	[DateUpdated]                   DATETIME NULL,
	[TokenUpdated]                  NVARCHAR(50) NULL,
    CONSTRAINT [PK_NotificationTracking] PRIMARY KEY CLUSTERED ([IdNotificationTracking] ASC),
    CONSTRAINT [FK_NotificationTracking_Account] FOREIGN KEY (IdAccount) REFERENCES [dbo].[Account] (AccIdAccount),
    CONSTRAINT [FK_NotificationTracking_CatTypeSuscription] FOREIGN KEY ([IdTypeSuscription]) REFERENCES [dbo].[CatTypeSuscription] ([IdTypeSuscription])
);
EXECUTE sp_addextendedproperty N'MS_Description', N'Identificador del usuario suscrito a las notificaciones', N'SCHEMA', N'dbo', N'TABLE', N'NotificationTracking', N'COLUMN', N'IdNotificationTracking'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Identificador generado por One Signal', N'SCHEMA', N'dbo', N'TABLE', N'NotificationTracking', N'COLUMN', N'IdOneSignal'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Identificador de la cuenta de la tabla Account', N'SCHEMA', N'dbo', N'TABLE', N'NotificationTracking', N'COLUMN', N'IdAccount'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Identificador del tipo de suscripcion', N'SCHEMA', N'dbo', N'TABLE', N'NotificationTracking', N'COLUMN', N'IdTypeSuscription'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Estado lógico del registro', N'SCHEMA', N'dbo', N'TABLE', N'NotificationTracking', N'COLUMN', N'RowStatus'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Usuario que realizó la creación del registro', N'SCHEMA', N'dbo', N'TABLE', N'NotificationTracking', N'COLUMN', N'UserCreated'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Fecha de creación del registro', N'SCHEMA', N'dbo', N'TABLE', N'NotificationTracking', N'COLUMN', N'DateCreated'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Token de creación del registro', N'SCHEMA', N'dbo', N'TABLE', N'NotificationTracking', N'COLUMN', N'TokenCreated'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Usuario que realizó la actualización del registro', N'SCHEMA', N'dbo', N'TABLE', N'NotificationTracking', N'COLUMN', N'UserUpdated'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Última fecha de actualización del registro', N'SCHEMA', N'dbo', N'TABLE', N'NotificationTracking', N'COLUMN', N'DateUpdated'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Último token de actualización del registro', N'SCHEMA', N'dbo', N'TABLE', N'NotificationTracking', N'COLUMN', N'TokenUpdated'
GO

CREATE TABLE [dbo].[UserSuscription] (
    [IdUserSuscription]             INT IDENTITY (1, 1) NOT NULL,
    [IdNotificationSuscription]     INT NOT NULL,
    [IdSuscription]                 NVARCHAR(100) NOT NULL,
    [IdTypeSuscription]             INT NOT NULL,
    [RowStatus]                     BIT NOT NULL DEFAULT 1,
    [UserCreated]                   NVARCHAR(50) NOT NULL,
	[DateCreated]                   DATETIME NOT NULL,
	[TokenCreated]                  NVARCHAR(50) NOT NULL,
    [UserUpdated]                   NVARCHAR(50) NULL,
	[DateUpdated]                   DATETIME NULL,
	[TokenUpdated]                  NVARCHAR(50) NULL,
    CONSTRAINT [PK_UserSuscription] PRIMARY KEY CLUSTERED ([IdUserSuscription] ASC),
	CONSTRAINT [FK_UserSuscription_Notification] FOREIGN KEY (IdNotificationSuscription) REFERENCES [dbo].[NotificationSuscription] (IdNotificationSuscription),
	CONSTRAINT [FK_UserSuscription_CatTypeSuscription] FOREIGN KEY ([IdTypeSuscription]) REFERENCES [dbo].[CatTypeSuscription] ([IdTypeSuscription])
);
EXECUTE sp_addextendedproperty N'MS_Description', N'Identificador de la suscripción', N'SCHEMA', N'dbo', N'TABLE', N'UserSuscription', N'COLUMN', N'IdUserSuscription'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Identificador del usuario suscrito a las notificaciones', N'SCHEMA', N'dbo', N'TABLE', N'UserSuscription', N'COLUMN', N'IdNotificationSuscription'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Identificador de la suscripción de One Signal', N'SCHEMA', N'dbo', N'TABLE', N'UserSuscription', N'COLUMN', N'IdSuscription'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Identificador del tipo de suscripcion', N'SCHEMA', N'dbo', N'TABLE', N'UserSuscription', N'COLUMN', N'IdTypeSuscription'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Estado lógico del registro', N'SCHEMA', N'dbo', N'TABLE', N'UserSuscription', N'COLUMN', N'RowStatus'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Usuario que realizó la creación del registro', N'SCHEMA', N'dbo', N'TABLE', N'UserSuscription', N'COLUMN', N'UserCreated'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Fecha de creación del registro', N'SCHEMA', N'dbo', N'TABLE', N'UserSuscription', N'COLUMN', N'DateCreated'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Token de creación del registro', N'SCHEMA', N'dbo', N'TABLE', N'UserSuscription', N'COLUMN', N'TokenCreated'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Usuario que realizó la actualización del registro', N'SCHEMA', N'dbo', N'TABLE', N'UserSuscription', N'COLUMN', N'UserUpdated'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Última fecha de actualización del registro', N'SCHEMA', N'dbo', N'TABLE', N'UserSuscription', N'COLUMN', N'DateUpdated'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Último token de actualización del registro', N'SCHEMA', N'dbo', N'TABLE', N'UserSuscription', N'COLUMN', N'TokenUpdated'
GO

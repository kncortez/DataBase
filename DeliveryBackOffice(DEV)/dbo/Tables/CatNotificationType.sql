CREATE TABLE [dbo].[CatNotificationType] (
    [IdCatNotificationType]       BIGINT         IDENTITY (1, 1),
    [ConfigExternalPlatformId]    INT            NOT NULL,
    [EmailTemplateName]           NVARCHAR (50)  NULL,
    [NotificationTypeName]        NVARCHAR (100) NULL,
    [NotificationTypeDescription] NVARCHAR (600) NULL,
    [NotificationStartTime]       TIME (7)       NOT NULL,
    [NotificationEndTime]         TIME (7)       NOT NULL,
    [RowStatus]                   BIT            DEFAULT ((1)) NOT NULL,
    [TokenCreated]                NVARCHAR (50)  NOT NULL,
    [DateCreated]                 DATETIME       NOT NULL,
    [TokenUpdated]                NVARCHAR (50)  NULL,
    [DateUpdated]                 DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdCatNotificationType] ASC),
    CONSTRAINT [FK_CatNotificationType_ConfigExternalPlatform] FOREIGN KEY ([ConfigExternalPlatformId]) REFERENCES [dbo].[ConfigExternalPlatform] ([IdConfigExternalPlatform])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatNotificationType', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que actualizó el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatNotificationType', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatNotificationType', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que generó el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatNotificationType', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatNotificationType', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Hora de finalización del servicio de notificación referenciado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatNotificationType', @level2type = N'COLUMN', @level2name = N'NotificationEndTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Hora de inicio del servicio de notificación referenciado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatNotificationType', @level2type = N'COLUMN', @level2name = N'NotificationStartTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del tipo de notificación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatNotificationType', @level2type = N'COLUMN', @level2name = N'NotificationTypeDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del tipo de notificación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatNotificationType', @level2type = N'COLUMN', @level2name = N'NotificationTypeName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre de la plantilla para correos electrónicos | Opcional', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatNotificationType', @level2type = N'COLUMN', @level2name = N'EmailTemplateName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la configuración de plantilla | Tabla ConfigExternalPlatform', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatNotificationType', @level2type = N'COLUMN', @level2name = N'ConfigExternalPlatformId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatNotificationType', @level2type = N'COLUMN', @level2name = N'IdCatNotificationType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para catalogo de tipos de notificaciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatNotificationType';


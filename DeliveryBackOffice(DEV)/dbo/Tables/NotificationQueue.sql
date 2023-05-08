CREATE TABLE [dbo].[NotificationQueue] (
    [IdNotificationQueue]     BIGINT         IDENTITY (1, 1) NOT NULL,
    [CatNotificationMediumId] INT            NOT NULL,
    [CatNotificationTypeId]   BIGINT         NOT NULL,
    [CustomerId]              INT            NULL,
    [AccountId]               BIGINT         NULL,
    [DestinationPhone]        NVARCHAR (200) NULL,
    [DestinationEmail]        NVARCHAR (200) NULL,
    [NotificationDate]        DATE           NOT NULL,
    [DateToSend]              DATE           NOT NULL,
    [IsSent]                  BIT            DEFAULT ((0)) NOT NULL,
    [RowStatus]               BIT            DEFAULT ((1)) NOT NULL,
    [TokenCreated]            NVARCHAR (50)  NOT NULL,
    [DateCreated]             DATETIME       NOT NULL,
    [TokenUpdated]            NVARCHAR (50)  NULL,
    [DateUpdated]             DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdNotificationQueue] ASC),
    CONSTRAINT [FK_NotificationQueue_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([AccIdAccount]),
    CONSTRAINT [FK_NotificationQueue_CatNotificationMedium] FOREIGN KEY ([CatNotificationMediumId]) REFERENCES [dbo].[CatNotificationMedium] ([IdCatNotificationMedium]),
    CONSTRAINT [FK_NotificationQueue_CatNotificationType] FOREIGN KEY ([CatNotificationTypeId]) REFERENCES [dbo].[CatNotificationType] ([IdCatNotificationType]),
    CONSTRAINT [FK_NotificationQueue_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([IdCustomer])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotificationQueue', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que actualizó el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotificationQueue', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotificationQueue', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que generó el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotificationQueue', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotificationQueue', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicador del envío de la notificación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotificationQueue', @level2type = N'COLUMN', @level2name = N'IsSent';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha en que se debe enviar la notificación, si es NULL se procesa inmediatamente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotificationQueue', @level2type = N'COLUMN', @level2name = N'DateToSend';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha en que se genera la notificación para procesos de agrupación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotificationQueue', @level2type = N'COLUMN', @level2name = N'NotificationDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dirección de correo electrónico del destino', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotificationQueue', @level2type = N'COLUMN', @level2name = N'DestinationEmail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de telefono del destino', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotificationQueue', @level2type = N'COLUMN', @level2name = N'DestinationPhone';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la cuenta asociada | Tabla Account', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotificationQueue', @level2type = N'COLUMN', @level2name = N'AccountId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del cliente | Tabla Customer', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotificationQueue', @level2type = N'COLUMN', @level2name = N'CustomerId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del tipo de notificación asociado al registro | Tabla CatNotificationType', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotificationQueue', @level2type = N'COLUMN', @level2name = N'CatNotificationTypeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del medio de notificación asociado al registro | Tabla CatNotificationMedium', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotificationQueue', @level2type = N'COLUMN', @level2name = N'CatNotificationMediumId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotificationQueue', @level2type = N'COLUMN', @level2name = N'IdNotificationQueue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para registro de cola de notificaciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NotificationQueue';


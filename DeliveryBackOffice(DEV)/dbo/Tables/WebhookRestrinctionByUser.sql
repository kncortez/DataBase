CREATE TABLE [dbo].[WebhookRestrinctionByUser] (
    [IdWebhookRestrinctionByUser] BIGINT         IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CustomerId]                  INT            NOT NULL,
    [WebhookTypeId]               INT            NOT NULL,
    [StatusOrderId]               TINYINT        NOT NULL,
    [StatusExternalName]          NVARCHAR (200) NULL,
    [RowStatus]                   INT            DEFAULT ((1)) NOT NULL,
    [TokenCreated]                NVARCHAR (50)  NOT NULL,
    [DateCreated]                 DATETIME       NOT NULL,
    [TokenUpdated]                NVARCHAR (50)  NULL,
    [DateUpdated]                 DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdWebhookRestrinctionByUser] ASC),
    CONSTRAINT [FK_WebhookRestrinctionByUser_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [FK_WebhookRestrinctionByUser_StatusOrder] FOREIGN KEY ([StatusOrderId]) REFERENCES [dbo].[StatusOrder] ([StatusOrderId]),
    CONSTRAINT [FK_WebhookRestrinctionByUser_WebhookType] FOREIGN KEY ([WebhookTypeId]) REFERENCES [dbo].[WebhookType] ([IdWebhookType])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookRestrinctionByUser', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookRestrinctionByUser', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación de registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookRestrinctionByUser', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookRestrinctionByUser', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookRestrinctionByUser', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del estado para desplegar en webhook.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookRestrinctionByUser', @level2type = N'COLUMN', @level2name = N'StatusExternalName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de estado de la tabla StatusOrder.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookRestrinctionByUser', @level2type = N'COLUMN', @level2name = N'StatusOrderId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del tipo de webhook de la tabla WebhookType.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookRestrinctionByUser', @level2type = N'COLUMN', @level2name = N'WebhookTypeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del cliente de la tabla Customer.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookRestrinctionByUser', @level2type = N'COLUMN', @level2name = N'CustomerId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookRestrinctionByUser', @level2type = N'COLUMN', @level2name = N'IdWebhookRestrinctionByUser';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de restricción de estados permitidos por webhook de cliente.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookRestrinctionByUser';


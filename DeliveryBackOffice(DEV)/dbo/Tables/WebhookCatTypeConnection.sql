CREATE TABLE [dbo].[WebhookCatTypeConnection] (
    [IdCatTypeConnection]   INT           NOT NULL,
    [CatTypeConnectionName] NVARCHAR (50) NOT NULL,
    [RowStatus]             BIT           NOT NULL,
    [DateCreated]           DATETIME      NOT NULL,
    [TokenCreated]          NVARCHAR (50) NOT NULL,
    [DateUpdated]           DATETIME      NULL,
    [TokenUpdated]          NVARCHAR (50) NULL,
    CONSTRAINT [PK_IdCatTypeConnection] PRIMARY KEY CLUSTERED ([IdCatTypeConnection] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que actualiza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookCatTypeConnection', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha que actualiza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookCatTypeConnection', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookCatTypeConnection', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookCatTypeConnection', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookCatTypeConnection', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del tipo de conexión', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookCatTypeConnection', @level2type = N'COLUMN', @level2name = N'CatTypeConnectionName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla WebhookCatTypeConnection', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookCatTypeConnection', @level2type = N'COLUMN', @level2name = N'IdCatTypeConnection';


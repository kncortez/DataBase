CREATE TABLE [dbo].[IntegrationForzaUELog] (
    [IdIntegrationForzaUELog]       INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [GuideSerie]                    NVARCHAR (2)  NOT NULL,
    [GuideNumber]                   INT           NOT NULL,
    [Description]                   NVARCHAR(MAX) NOT NULL,
    [System]                        NVARCHAR(250) NOT NULL,
    [RowStatus]                     BIT           NOT NULL,
    [TokenCreated]                  NVARCHAR (50) NOT NULL,
    [DateCreated]                   DATETIME      NOT NULL,
    [TokenUpdated]                  NVARCHAR (50) NULL,
    [DateUpdated]                   DATETIME      NULL,
    CONSTRAINT [PK_IntegrationForzaUELog] PRIMARY KEY CLUSTERED ([IdIntegrationLogForzaUE] ASC),
    CONSTRAINT [FK_IntegrationForzaUELog_DeliveryOrder] FOREIGN KEY ([GuideSerie], [GuideNumber]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number])
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del log', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IntegrationForzaUELog', @level2type = N'COLUMN', @level2name = N'IdIntegrationForzaUELog';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IntegrationForzaUELog', @level2type = N'COLUMN', @level2name = N'GuideSerie';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IntegrationForzaUELog', @level2type = N'COLUMN', @level2name = N'GuideNumber';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del Error', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IntegrationForzaUELog', @level2type = N'COLUMN', @level2name = N'Description';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Sistema en donde se presente el error', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IntegrationForzaUELog', @level2type = N'COLUMN', @level2name = N'System';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Si el registro está vigente.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IntegrationForzaUELog', @level2type = N'COLUMN', @level2name = N'RowStatus';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IntegrationForzaUELog', @level2type = N'COLUMN', @level2name = N'TokenCreated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IntegrationForzaUELog', @level2type = N'COLUMN', @level2name = N'DateCreated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IntegrationForzaUELog', @level2type = N'COLUMN', @level2name = N'TokenUpdated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IntegrationForzaUELog', @level2type = N'COLUMN', @level2name = N'DateUpdated';

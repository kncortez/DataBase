CREATE TABLE [dbo].[ExternalPlatformServiceLog] (
    [IdExternalPlatformServiceLog] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [ExternalPlatformId]           INT           NOT NULL,
    [GuideSerie]                   NVARCHAR (2)  NOT NULL,
    [GuideNumber]                  INT           NOT NULL,
    [RowStatus]                    BIT           NOT NULL,
    [TokenCreated]                 NVARCHAR (50) NOT NULL,
    [DateCreated]                  DATETIME      NOT NULL,
    [TokenUpdated]                 NVARCHAR (50) NULL,
    [DateUpdated]                  DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdExternalPlatformServiceLog] ASC),
    CONSTRAINT [FK_ExternalPlatformServiceLog_CatExternalPlatform] FOREIGN KEY ([ExternalPlatformId]) REFERENCES [dbo].[CatExternalPlatform] ([IdExternalPlatform]),
    CONSTRAINT [FK_ExtPlatServiceLog_DeliveryOrder] FOREIGN KEY ([GuideSerie], [GuideNumber]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Bitácora de guías que han sido procesadas para traslado a plataformas externas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExternalPlatformServiceLog';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExternalPlatformServiceLog', @level2type = N'COLUMN', @level2name = N'IdExternalPlatformServiceLog';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID que hace referencia a la tabla CatExternalPlatform', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExternalPlatformServiceLog', @level2type = N'COLUMN', @level2name = N'ExternalPlatformId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de la guía referenciando a la tabla DeliveryOrder', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExternalPlatformServiceLog', @level2type = N'COLUMN', @level2name = N'GuideSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de la guía referenciando a la tabla DeliveryOrder', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExternalPlatformServiceLog', @level2type = N'COLUMN', @level2name = N'GuideNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExternalPlatformServiceLog', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExternalPlatformServiceLog', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExternalPlatformServiceLog', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExternalPlatformServiceLog', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExternalPlatformServiceLog', @level2type = N'COLUMN', @level2name = N'DateUpdated';


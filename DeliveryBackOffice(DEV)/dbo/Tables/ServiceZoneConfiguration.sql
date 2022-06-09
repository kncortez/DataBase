CREATE TABLE [dbo].[ServiceZoneConfiguration] (
    [IdServiceZoneConfiguration] INT           IDENTITY (1, 1) NOT NULL,
    [CatConfigurableServiceId]   INT           NOT NULL,
    [TownshipId]                 INT           NOT NULL,
    [Zone]                       NVARCHAR (2)  NOT NULL,
    [RowStatus]                  BIT           NOT NULL,
    [TokenCreated]               NVARCHAR (50) NOT NULL,
    [DateCreated]                DATETIME      NOT NULL,
    [TokenUpdated]               NVARCHAR (50) NULL,
    [DateUpdated]                DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdServiceZoneConfiguration] ASC),
    CONSTRAINT [FK_ServiceZoneConfiguration_CatConfigurableService] FOREIGN KEY ([CatConfigurableServiceId]) REFERENCES [dbo].[CatConfigurableService] ([IdCatConfigurableService]),
    CONSTRAINT [FK_ServiceZoneConfiguration_Township] FOREIGN KEY ([TownshipId]) REFERENCES [dbo].[Township] ([IdTownship])
);


GO
CREATE NONCLUSTERED INDEX [IX_ServiceZoneConfiguration_ServiceRowStatus]
    ON [dbo].[ServiceZoneConfiguration]([CatConfigurableServiceId] ASC, [RowStatus] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ServiceZoneConfiguration_Township]
    ON [dbo].[ServiceZoneConfiguration]([TownshipId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ServiceZoneConfiguration_Zone]
    ON [dbo].[ServiceZoneConfiguration]([Zone] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ServiceZoneConfiguration_TownshipZone]
    ON [dbo].[ServiceZoneConfiguration]([TownshipId] ASC, [Zone] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de zonas por municipio a considerar durante la ejecución de un servicio configurable', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceZoneConfiguration';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceZoneConfiguration', @level2type = N'COLUMN', @level2name = N'IdServiceZoneConfiguration';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del servicio en la tabla CatConfigurableService', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceZoneConfiguration', @level2type = N'COLUMN', @level2name = N'CatConfigurableServiceId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del municipio en la tabla Township', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceZoneConfiguration', @level2type = N'COLUMN', @level2name = N'TownshipId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Zona del municipio configurado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceZoneConfiguration', @level2type = N'COLUMN', @level2name = N'Zone';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceZoneConfiguration', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceZoneConfiguration', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceZoneConfiguration', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceZoneConfiguration', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceZoneConfiguration', @level2type = N'COLUMN', @level2name = N'DateUpdated';


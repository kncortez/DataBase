CREATE TABLE [dbo].[ServiceProvinceConfiguration] (
    [IdServiceProvinceConfiguration] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CatConfigurableServiceId]       INT           NOT NULL,
    [ProvinceId]                     INT           NOT NULL,
    [RowStatus]                      BIT           NOT NULL,
    [TokenCreated]                   NVARCHAR (50) NOT NULL,
    [DateCreated]                    DATETIME      NOT NULL,
    [TokenUpdated]                   NVARCHAR (50) NULL,
    [DateUpdated]                    DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdServiceProvinceConfiguration] ASC),
    CONSTRAINT [FK_ServiceProvinceConfiguration_CatConfigurableService] FOREIGN KEY ([CatConfigurableServiceId]) REFERENCES [dbo].[CatConfigurableService] ([IdCatConfigurableService]),
    CONSTRAINT [FK_ServiceProvinceConfiguration_Province] FOREIGN KEY ([ProvinceId]) REFERENCES [dbo].[Province] ([IdProvince])
);




GO
CREATE NONCLUSTERED INDEX [IX_ServiceProvinceConfiguration_ServiceRowStatus]
    ON [dbo].[ServiceProvinceConfiguration]([CatConfigurableServiceId] ASC, [RowStatus] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ServiceProvinceConfiguration_Province]
    ON [dbo].[ServiceProvinceConfiguration]([ProvinceId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de departamentos a considerar durante la ejecución de un servicio configurable', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceProvinceConfiguration';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceProvinceConfiguration', @level2type = N'COLUMN', @level2name = N'IdServiceProvinceConfiguration';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del servicio en la tabla CatConfigurableService', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceProvinceConfiguration', @level2type = N'COLUMN', @level2name = N'CatConfigurableServiceId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del departamento en la tabla Province', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceProvinceConfiguration', @level2type = N'COLUMN', @level2name = N'ProvinceId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceProvinceConfiguration', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceProvinceConfiguration', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceProvinceConfiguration', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceProvinceConfiguration', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceProvinceConfiguration', @level2type = N'COLUMN', @level2name = N'DateUpdated';


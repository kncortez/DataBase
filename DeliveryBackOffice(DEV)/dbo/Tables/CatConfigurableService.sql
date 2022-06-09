CREATE TABLE [dbo].[CatConfigurableService] (
    [IdCatConfigurableService]          INT            IDENTITY (1, 1) NOT NULL,
    [CatConfigurableServiceName]        NVARCHAR (50)  NOT NULL,
    [CatConfigurableServiceDescription] NVARCHAR (200) NULL,
    [RowStatus]                         BIT            NOT NULL,
    [TokenCreated]                      NVARCHAR (50)  NOT NULL,
    [DateCreated]                       DATETIME       NOT NULL,
    [TokenUpdated]                      NVARCHAR (50)  NULL,
    [DateUpdated]                       DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdCatConfigurableService] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catálogo de servicios configurables desde base de datos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatConfigurableService';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatConfigurableService', @level2type = N'COLUMN', @level2name = N'IdCatConfigurableService';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del servicio configurable desde base de datos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatConfigurableService', @level2type = N'COLUMN', @level2name = N'CatConfigurableServiceName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del servicio configurable', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatConfigurableService', @level2type = N'COLUMN', @level2name = N'CatConfigurableServiceDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatConfigurableService', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatConfigurableService', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatConfigurableService', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatConfigurableService', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatConfigurableService', @level2type = N'COLUMN', @level2name = N'DateUpdated';


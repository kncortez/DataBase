CREATE TABLE [dbo].[CatRouteCluster] (
    [IdCatRouteCluster]   BIGINT         IDENTITY (1, 1) NOT NULL,
    [ClusterName]         NVARCHAR (50)  NOT NULL,
    [ClusterDescription]  NVARCHAR (200) NOT NULL,
    [ClusterAbbreviation] NVARCHAR (10)  NOT NULL,
    [RowStatus]           BIT            DEFAULT ((1)) NOT NULL,
    [DateCreated]         DATETIME       NOT NULL,
    [TokenCreated]        NVARCHAR (50)  NOT NULL,
    [DateUpdated]         DATETIME       NULL,
    [TokenUpdated]        NVARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([IdCatRouteCluster] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatRouteCluster', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatRouteCluster', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatRouteCluster', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatRouteCluster', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatRouteCluster', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Abreviación del nombre del cluster', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatRouteCluster', @level2type = N'COLUMN', @level2name = N'ClusterAbbreviation';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del cluster', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatRouteCluster', @level2type = N'COLUMN', @level2name = N'ClusterDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre identificador del cluster', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatRouteCluster', @level2type = N'COLUMN', @level2name = N'ClusterName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatRouteCluster', @level2type = N'COLUMN', @level2name = N'IdCatRouteCluster';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de clusters de rutas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatRouteCluster';


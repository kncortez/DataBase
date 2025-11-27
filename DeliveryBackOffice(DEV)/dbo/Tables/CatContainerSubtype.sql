CREATE TABLE [dbo].[CatContainerSubtype] (
    [IdCatContainerSubtype]       BIGINT         IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [ContainerSubtypeName]        NVARCHAR (100) NOT NULL,
    [ContainerSubtypeDescription] NVARCHAR (600) NULL,
    [RowStatus]                   BIT            DEFAULT ((0)) NOT NULL,
    [DateCreated]                 DATETIME       NOT NULL,
    [TokenCreated]                NVARCHAR (50)  NOT NULL,
    [DateUpdated]                 DATETIME       NULL,
    [TokenUpdated]                NVARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([IdCatContainerSubtype] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatContainerSubtype', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatContainerSubtype', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatContainerSubtype', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatContainerSubtype', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatContainerSubtype', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción de la subcategoria de contenedor.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatContainerSubtype', @level2type = N'COLUMN', @level2name = N'ContainerSubtypeDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre de subcategoria de contenedor.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatContainerSubtype', @level2type = N'COLUMN', @level2name = N'ContainerSubtypeName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatContainerSubtype', @level2type = N'COLUMN', @level2name = N'IdCatContainerSubtype';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de subcategorias de tipos de contenedor.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatContainerSubtype';


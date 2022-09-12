CREATE TABLE [dbo].[CatTypeContainer] (
    [IdCatTypeContainer]       INT            IDENTITY (1, 1) NOT NULL,
    [TypeContainerName]        NVARCHAR (50)  NOT NULL,
    [TypeContainerSerie]       NVARCHAR (100) NOT NULL,
    [TypeContainerDescription] NVARCHAR (200) NULL,
    [RowStatus]                BIT            DEFAULT ((1)) NOT NULL,
    [TokenCreated]             NVARCHAR (50)  NOT NULL,
    [DateCreated]              DATETIME       NOT NULL,
    [TokenUpdated]             NVARCHAR (50)  NULL,
    [DateUpdated]              DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdCatTypeContainer] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeContainer', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeContainer', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeContainer', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeContainer', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeContainer', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del tipo de contenedor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeContainer', @level2type = N'COLUMN', @level2name = N'TypeContainerDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie del tipo de contenedor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeContainer', @level2type = N'COLUMN', @level2name = N'TypeContainerSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del tipo de contenedor.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeContainer', @level2type = N'COLUMN', @level2name = N'TypeContainerName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeContainer', @level2type = N'COLUMN', @level2name = N'IdCatTypeContainer';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de catalogo de tipos de contenedores.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeContainer';


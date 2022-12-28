CREATE TABLE [dbo].[CatTagContent] (
    [IdCatTagContent]          BIGINT         IDENTITY (1, 1) NOT NULL,
    [CatTagContentName]        NVARCHAR (50)  NOT NULL,
    [CatTagContentDescription] NVARCHAR (500) NULL,
    [RowStatus]                BIT            DEFAULT ((1)) NOT NULL,
    [DateCreated]              DATETIME       NOT NULL,
    [TokenCreated]             NVARCHAR (50)  NOT NULL,
    [DateUpdated]              DATETIME       NULL,
    [TokenUpdated]             NVARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([IdCatTagContent] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTagContent', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTagContent', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTagContent', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTagContent', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTagContent', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción de la etiqueta de contenido.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTagContent', @level2type = N'COLUMN', @level2name = N'CatTagContentDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre de la etiqueta de contenido.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTagContent', @level2type = N'COLUMN', @level2name = N'CatTagContentName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTagContent', @level2type = N'COLUMN', @level2name = N'IdCatTagContent';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de etiquetas para contenido.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTagContent';


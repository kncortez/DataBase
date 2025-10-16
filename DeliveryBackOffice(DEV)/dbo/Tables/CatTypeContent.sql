CREATE TABLE [dbo].[CatTypeContent] (
    [IdCatTypeContent]          BIGINT         IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CatTypeContentName]        NVARCHAR (50)  NOT NULL,
    [CatTypeContentDescription] NVARCHAR (500) NULL,
    [RowStatus]                 BIT            DEFAULT ((1)) NOT NULL,
    [DateCreated]               DATETIME       NOT NULL,
    [TokenCreated]              NVARCHAR (50)  NOT NULL,
    [DateUpdated]               DATETIME       NULL,
    [TokenUpdated]              NVARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([IdCatTypeContent] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeContent', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeContent', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeContent', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeContent', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeContent', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del tipo de contenido.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeContent', @level2type = N'COLUMN', @level2name = N'CatTypeContentDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del tipo de contenido.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeContent', @level2type = N'COLUMN', @level2name = N'CatTypeContentName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeContent', @level2type = N'COLUMN', @level2name = N'IdCatTypeContent';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de tipos de contenido.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeContent';


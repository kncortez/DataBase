CREATE TABLE [dbo].[CatGeneralLabel] (
    [IdLabel]          BIGINT         IDENTITY (1, 1) NOT NULL,
    [LabelCode]        NVARCHAR (100) NOT NULL,
    [LabelDescription] NVARCHAR (200) NOT NULL,
    [LanguageId]       INT            NOT NULL,
    [RowStatus]        BIT            NOT NULL,
    [TokenCreated]     NVARCHAR (50)  NOT NULL,
    [DateCreated]      DATETIME       NOT NULL,
    [TokenUpdated]     NVARCHAR (50)  NULL,
    [DateUpdated]      NVARCHAR (50)  NULL,
    CONSTRAINT [PK_CatGeneralLabel] PRIMARY KEY CLUSTERED ([IdLabel] ASC),
    CONSTRAINT [UC_CatGeneralLabel] UNIQUE NONCLUSTERED ([LabelCode] ASC, [LanguageId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatGeneralLabel', @level2type = N'COLUMN', @level2name = N'IdLabel';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identifica a la etiqueta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatGeneralLabel', @level2type = N'COLUMN', @level2name = N'LabelCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción por idioma', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatGeneralLabel', @level2type = N'COLUMN', @level2name = N'LabelDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Lenguaje de la etiqueta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatGeneralLabel', @level2type = N'COLUMN', @level2name = N'LanguageId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatGeneralLabel', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatGeneralLabel', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatGeneralLabel', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatGeneralLabel', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de modificación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatGeneralLabel', @level2type = N'COLUMN', @level2name = N'DateUpdated';


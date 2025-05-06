CREATE TABLE [dbo].[CatLanguage] (
    [IdLanguage]   INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Language]     NVARCHAR (50) NOT NULL,
    [Abbreviation] NVARCHAR (5)  NOT NULL,
    [RowStatus]    BIGINT        NOT NULL,
    [TokenCreated] NVARCHAR (50) NOT NULL,
    [DateCreated]  DATETIME      NOT NULL,
    [TokenUpdated] NVARCHAR (50) NULL,
    [DateUpdated]  DATETIME      NULL,
    CONSTRAINT [PK_CatLanguage] PRIMARY KEY CLUSTERED ([IdLanguage] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del idioma', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatLanguage', @level2type = N'COLUMN', @level2name = N'IdLanguage';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Lenguaje', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatLanguage', @level2type = N'COLUMN', @level2name = N'Language';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Abreviatura del lenguaje ISO 639-1', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatLanguage', @level2type = N'COLUMN', @level2name = N'Abbreviation';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatLanguage', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatLanguage', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatLanguage', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatLanguage', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatLanguage', @level2type = N'COLUMN', @level2name = N'DateUpdated';


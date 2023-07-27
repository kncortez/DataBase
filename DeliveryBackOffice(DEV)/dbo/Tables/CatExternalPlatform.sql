CREATE TABLE [dbo].[CatExternalPlatform] (
    [IdExternalPlatform]   INT           IDENTITY (1, 1) NOT NULL,
    [NameExternalPlatform] NVARCHAR (50) NOT NULL,
    [RowStatus]            BIT           NOT NULL,
    [TokenCreated]         VARCHAR (50)  NOT NULL,
    [DateCreated]          DATETIME      NOT NULL,
    [TokenUpdated]         VARCHAR (50)  NULL,
    [DateUpdated]          DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdExternalPlatform] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatExternalPlatform', @level2type = N'COLUMN', @level2name = N'IdExternalPlatform';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre de la plataforma externa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatExternalPlatform', @level2type = N'COLUMN', @level2name = N'NameExternalPlatform';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatExternalPlatform', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatExternalPlatform', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatExternalPlatform', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatExternalPlatform', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatExternalPlatform', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catálogo de plataformas externas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatExternalPlatform';


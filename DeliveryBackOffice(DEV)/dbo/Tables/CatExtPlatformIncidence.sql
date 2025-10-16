CREATE TABLE [dbo].[CatExtPlatformIncidence] (
    [IdCatExtPlatformIncidence]      INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [ExtPlatformId]                  INT            NOT NULL,
    [ExtPlatformInternalId]          NVARCHAR (50)  NOT NULL,
    [ExtPlatformInternalDescription] NVARCHAR (200) NULL,
    [RowStatus]                      BIT            NOT NULL,
    [TokenCreated]                   NVARCHAR (50)  NOT NULL,
    [DateCreated]                    DATETIME       NOT NULL,
    [TokenUpdated]                   NVARCHAR (50)  NULL,
    [DateUpdated]                    DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdCatExtPlatformIncidence] ASC),
    CONSTRAINT [CatExtPlatformIncidence_PlatformId_FK] FOREIGN KEY ([ExtPlatformId]) REFERENCES [dbo].[CatExternalPlatform] ([IdExternalPlatform])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatExtPlatformIncidence', @level2type = N'COLUMN', @level2name = N'IdCatExtPlatformIncidence';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la plataforma a la que pertenece el servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatExtPlatformIncidence', @level2type = N'COLUMN', @level2name = N'ExtPlatformId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la incidencia dentro de la plataforma externa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatExtPlatformIncidence', @level2type = N'COLUMN', @level2name = N'ExtPlatformInternalId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripcion de la incidencia dentro de la plataforma externa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatExtPlatformIncidence', @level2type = N'COLUMN', @level2name = N'ExtPlatformInternalDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatExtPlatformIncidence', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatExtPlatformIncidence', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatExtPlatformIncidence', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatExtPlatformIncidence', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatExtPlatformIncidence', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Catalog de incidencias en plataformas externas',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatExtPlatformIncidence',
    @level2type = NULL,
    @level2name = NULL
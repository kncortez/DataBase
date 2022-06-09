CREATE TABLE [dbo].[ExtPlatIncidence_TypeIncidence] (
    [IdExtPlatIncidence_TypeIncidence] INT           IDENTITY (1, 1) NOT NULL,
    [ExtPlatIncidenceId]               INT           NOT NULL,
    [TypeIncidenceId]                  INT           NOT NULL,
    [RowStatus]                        BIT           NOT NULL,
    [TokenCreated]                     NVARCHAR (50) NOT NULL,
    [DateCreated]                      DATETIME      NOT NULL,
    [TokenUpdated]                     NVARCHAR (50) NULL,
    [DateUpdated]                      DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdExtPlatIncidence_TypeIncidence] ASC),
    CONSTRAINT [ExtPlatIncidence_TypeIncidence_ExtPlat_FK] FOREIGN KEY ([ExtPlatIncidenceId]) REFERENCES [dbo].[CatExtPlatformIncidence] ([IdCatExtPlatformIncidence]),
    CONSTRAINT [ExtPlatIncidence_TypeIncidence_TypeInc_FK] FOREIGN KEY ([TypeIncidenceId]) REFERENCES [dbo].[CatTypeIncidence] ([IdIncidenceType])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatIncidence_TypeIncidence', @level2type = N'COLUMN', @level2name = N'IdExtPlatIncidence_TypeIncidence';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la incidencia de la plataforma externa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatIncidence_TypeIncidence', @level2type = N'COLUMN', @level2name = N'ExtPlatIncidenceId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la incidencia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatIncidence_TypeIncidence', @level2type = N'COLUMN', @level2name = N'TypeIncidenceId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatIncidence_TypeIncidence', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatIncidence_TypeIncidence', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatIncidence_TypeIncidence', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatIncidence_TypeIncidence', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExtPlatIncidence_TypeIncidence', @level2type = N'COLUMN', @level2name = N'DateUpdated';


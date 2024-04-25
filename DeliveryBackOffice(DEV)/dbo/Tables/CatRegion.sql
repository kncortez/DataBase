CREATE TABLE [dbo].[CatRegion] (
    [IdCatRegion]  INT           IDENTITY (1, 1) NOT NULL,
    [RegionName]   NVARCHAR (30) NOT NULL,
    [RowStatus]    BIT           NOT NULL,
    [TokenCreated] NVARCHAR (50) NOT NULL,
    [DateCreated]  DATETIME      NOT NULL,
    [TokenUpdated] NVARCHAR (50) NULL,
    [DateUpdated]  DATETIME      NULL,
    CONSTRAINT [PK_CatRegion] PRIMARY KEY CLUSTERED ([IdCatRegion] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catalogo de regiones.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatRegion';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatRegion', @level2type = N'COLUMN', @level2name = N'IdCatRegion';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre de la región', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatRegion', @level2type = N'COLUMN', @level2name = N'RegionName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatRegion', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatRegion', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatRegion', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatRegion', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatRegion', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
CREATE NONCLUSTERED INDEX [IX_IdCatRegion_RPT]
    ON [dbo].[CatRegion]([IdCatRegion] ASC)
    INCLUDE([RegionName]);


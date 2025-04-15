CREATE TABLE [dbo].[CatArticle] (
    [ArtId]            INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [ArtIdTypeArticle] INT             NOT NULL,
    [ArtName]          VARCHAR (50)    NOT NULL,
    [ArtShowDefault]   BIT             NOT NULL,
    [ArtRowStatus]     BIT             NOT NULL,
    [ArtTokenCreated]  VARCHAR (50)    NOT NULL,
    [ArtDateCreated]   DATETIME        NOT NULL,
    [ArtTokenUpdated]  VARCHAR (50)    NULL,
    [ArtDateUpdated]   DATETIME        NULL,
    [ArtHeight]        DECIMAL (18, 2) NULL,
    [ArtWidth]         DECIMAL (18, 2) NULL,
    [ArtLength]        DECIMAL (18, 2) NULL,
    [ArtMassWeight]    DECIMAL (18, 2) NULL,
    [IdCountry]        VARCHAR (2)     NULL,
    PRIMARY KEY CLUSTERED ([ArtId] ASC),
    FOREIGN KEY ([ArtIdTypeArticle]) REFERENCES [dbo].[CatTypeArticle] ([TarId]),
    CONSTRAINT [FK_CatArticle_CatCountry] FOREIGN KEY ([IdCountry]) REFERENCES [dbo].[CatCountry] ([IdCountry])
);




GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'id del articulo',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatArticle',
    @level2type = N'COLUMN',
    @level2name = N'ArtId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'id del tipo de articulo(Referencia a la tabla CatTypArticle)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatArticle',
    @level2type = N'COLUMN',
    @level2name = N'ArtIdTypeArticle'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nombre del articulo',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatArticle',
    @level2type = N'COLUMN',
    @level2name = N'ArtName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Indica si el articulo se muestra visualmente(1 SI, 0 NO)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatArticle',
    @level2type = N'COLUMN',
    @level2name = N'ArtShowDefault'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado de registro(1 Activo, 0 Inactivo)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatArticle',
    @level2type = N'COLUMN',
    @level2name = N'ArtRowStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Codigo de quien creo el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatArticle',
    @level2type = N'COLUMN',
    @level2name = N'ArtTokenCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creacion',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatArticle',
    @level2type = N'COLUMN',
    @level2name = N'ArtDateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Codigo de quien modifico el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatArticle',
    @level2type = N'COLUMN',
    @level2name = N'ArtTokenUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de modificacion',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatArticle',
    @level2type = N'COLUMN',
    @level2name = N'ArtDateUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'medida de altura de articulo',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatArticle',
    @level2type = N'COLUMN',
    @level2name = N'ArtHeight'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'medida de ancho de articulo',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatArticle',
    @level2type = N'COLUMN',
    @level2name = N'ArtWidth'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'medida de largo de articulo',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatArticle',
    @level2type = N'COLUMN',
    @level2name = N'ArtLength'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'medida de peso de articulo',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatArticle',
    @level2type = N'COLUMN',
    @level2name = N'ArtMassWeight'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'id de pais (Referencia a IdCountry de la tabla CatCountry)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatArticle',
    @level2type = N'COLUMN',
    @level2name = N'IdCountry'
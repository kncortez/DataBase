CREATE TABLE [dbo].[CatRateSegment] (
    [CrsId]           INT           IDENTITY (1, 1) NOT NULL,
    [CrsName]         VARCHAR (100) NOT NULL,
    [CrsShortName]    VARCHAR (3)   NOT NULL,
    [CrsDescription]  VARCHAR (200) NULL,
    [CrsRowStatus]    BIT           NOT NULL,
    [CrsTokenCreated] VARCHAR (50)  NOT NULL,
    [CrsDateCreated]  DATETIME      NOT NULL,
    [CrsTokenUpdated] VARCHAR (50)  NULL,
    [CrsDateUpdated]  DATETIME      NULL,
    [IdCountry]        VARCHAR(2)    NULL, 
    PRIMARY KEY CLUSTERED ([CrsId] ASC),
    CONSTRAINT [FK_CatRateSegment_CatCountry] FOREIGN KEY (IdCountry) REFERENCES [dbo].[CatCountry](IdCountry)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificacion de segmento de tarifario',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatRateSegment',
    @level2type = N'COLUMN',
    @level2name = N'CrsId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'nombre',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatRateSegment',
    @level2type = N'COLUMN',
    @level2name = N'CrsName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nombre corto',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatRateSegment',
    @level2type = N'COLUMN',
    @level2name = N'CrsShortName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Descripción',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatRateSegment',
    @level2type = N'COLUMN',
    @level2name = N'CrsDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estatos(1 Activo, 0 Inactivo)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatRateSegment',
    @level2type = N'COLUMN',
    @level2name = N'CrsRowStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien creó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatRateSegment',
    @level2type = N'COLUMN',
    @level2name = N'CrsTokenCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatRateSegment',
    @level2type = N'COLUMN',
    @level2name = N'CrsDateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien modificó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatRateSegment',
    @level2type = N'COLUMN',
    @level2name = N'CrsTokenUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de modificación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatRateSegment',
    @level2type = N'COLUMN',
    @level2name = N'CrsDateUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tipo de segmento de tarifario',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatRateSegment',
    @level2type = NULL,
    @level2name = NULL
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'id del pais(Referncia a IdCountry de la tabla CatCountry)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatRateSegment',
    @level2type = N'COLUMN',
    @level2name = N'IdCountry'
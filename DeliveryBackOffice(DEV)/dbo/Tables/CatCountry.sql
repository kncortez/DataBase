CREATE TABLE [dbo].[CatCountry] (
    [IdCountry]           VARCHAR (2)  NOT NULL,
    [CountryNameEN]       VARCHAR (55) NULL,
    [CountryNameES]       VARCHAR (55) NULL,
    [CountryAlpha3Code]   VARCHAR (3)  NULL,
    [CountryNationality]  VARCHAR (50) NULL,
    [CountryRowStatus]    BIT          CONSTRAINT [DF_CatCountry_CountryRowStatus] DEFAULT ('TRUE') NULL,
    [CountryTokenCreated] VARCHAR (50) NULL,
    [CountryDateCreated]  DATETIME     NOT NULL,
    [CountryTokenUpdated] VARCHAR (50) NULL,
    [CountryDateUpdated]  DATETIME     NULL,
    CONSTRAINT [PK_CatCountry] PRIMARY KEY CLUSTERED ([IdCountry] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ISO Code 3166 Alpha2Code', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatCountry', @level2type = N'COLUMN', @level2name = N'IdCountry';




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ISO Code 3166 Alpha3Code', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatCountry', @level2type = N'COLUMN', @level2name = N'CountryAlpha3Code';




GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nombre de país en ingles',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatCountry',
    @level2type = N'COLUMN',
    @level2name = N'CountryNameEN'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nombre de país en español',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatCountry',
    @level2type = N'COLUMN',
    @level2name = N'CountryNameES'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nombre de la nacionalidad',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatCountry',
    @level2type = N'COLUMN',
    @level2name = N'CountryNationality'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado del país(1 Activo, 0 Inactivo)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatCountry',
    @level2type = N'COLUMN',
    @level2name = N'CountryRowStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien crea el país',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatCountry',
    @level2type = N'COLUMN',
    @level2name = N'CountryTokenCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creación del país',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatCountry',
    @level2type = N'COLUMN',
    @level2name = N'CountryDateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien modifica el país',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatCountry',
    @level2type = N'COLUMN',
    @level2name = N'CountryTokenUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de modicificación del país',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatCountry',
    @level2type = N'COLUMN',
    @level2name = N'CountryDateUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tabla que representa el país',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatCountry',
    @level2type = NULL,
    @level2name = NULL
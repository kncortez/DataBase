CREATE TABLE [dbo].[APRegionGuides] (
    [IdAPRegionGuides]          INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [City]                      NVARCHAR(100)   NULL,
    [Region]                    NVARCHAR(100)   NULL,
    [CountryCode]               NVARCHAR(2)     NOT NULL,
    [IdTownship]                INT             NOT NULL,
    [HeaderCode]                VARCHAR(10)     NOT NULL,
    [RowStatus]                 BIT             DEFAULT ((1)) NOT NULL,
    [TokenCreated]              NVARCHAR (50)   NOT NULL,
    [DateCreated]               DATETIME        NOT NULL,
    [TokenUpdated]              NVARCHAR (50)   NULL,
    [DateUpdated]               DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([IdAPRegionGuides] ASC),
    CONSTRAINT [FK_APRegionGuides_Township] FOREIGN KEY ([IdTownship]) REFERENCES [dbo].[Township] ([IdTownship])
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para almacenar los municipios (city) o departamentos (region) de Aeropost que no coincidan con los de Forza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APRegionGuides';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APRegionGuides', @level2type = N'COLUMN', @level2name = N'IdAPRegionGuides';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código del país', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APRegionGuides', @level2type = N'COLUMN', @level2name = N'City';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código del país', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APRegionGuides', @level2type = N'COLUMN', @level2name = N'Region';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código del país', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APRegionGuides', @level2type = N'COLUMN', @level2name = N'CountryCode';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Horario de ejecución del servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APRegionGuides', @level2type = N'COLUMN', @level2name = N'IdTownship';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del horario de ejecución', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APRegionGuides', @level2type = N'COLUMN', @level2name = N'HeaderCode';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro (1=Activo, 0=Inactivo)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APRegionGuides', @level2type = N'COLUMN', @level2name = N'RowStatus';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token del usuario que creó el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APRegionGuides', @level2type = N'COLUMN', @level2name = N'TokenCreated';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro en el sistema', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APRegionGuides', @level2type = N'COLUMN', @level2name = N'DateCreated';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token del usuario que actualizó el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APRegionGuides', @level2type = N'COLUMN', @level2name = N'TokenUpdated';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de última actualización del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APRegionGuides', @level2type = N'COLUMN', @level2name = N'DateUpdated';

CREATE TABLE [dbo].[Person] (
    [PerIdPerson]       BIGINT        IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [PerFirstName]      VARCHAR (100) NOT NULL,
    [PerLastName]       VARCHAR (100) NOT NULL,
    [PerGender]         VARCHAR (2)   NULL,
    [PerBirthdate]      DATE          NULL,
    [PerIdentification] VARCHAR (50)  NOT NULL,
    [PerNationality]    VARCHAR (100) NOT NULL,
    [PerRowStatus]      BIT           NOT NULL,
    [PerTokenCreated]   VARCHAR (50)  NOT NULL,
    [PerDateCreated]    DATE          NOT NULL,
    [PerTokenUpdated]   VARCHAR (50)  NULL,
    [PerDateUpdated]    DATE          NULL,
    [PerCountryOrigin]  VARCHAR (2)   NULL,
    PRIMARY KEY CLUSTERED ([PerIdPerson] ASC),
    CONSTRAINT [FK_Person_CatCountry] FOREIGN KEY ([PerCountryOrigin]) REFERENCES [dbo].[CatCountry] ([IdCountry])
);




GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'identificación de registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Person',
    @level2type = N'COLUMN',
    @level2name = N'PerIdPerson'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nombre',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Person',
    @level2type = N'COLUMN',
    @level2name = N'PerFirstName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Apellido',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Person',
    @level2type = N'COLUMN',
    @level2name = N'PerLastName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Género',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Person',
    @level2type = N'COLUMN',
    @level2name = N'PerGender'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de nacimiento',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Person',
    @level2type = N'COLUMN',
    @level2name = N'PerBirthdate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificación(DPI)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Person',
    @level2type = N'COLUMN',
    @level2name = N'PerIdentification'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nacionalidad(Abreviatura país)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Person',
    @level2type = N'COLUMN',
    @level2name = N'PerNationality'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado(1 Activo, 0 Inactivo)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Person',
    @level2type = N'COLUMN',
    @level2name = N'PerRowStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien creó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Person',
    @level2type = N'COLUMN',
    @level2name = N'PerTokenCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creación de registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Person',
    @level2type = N'COLUMN',
    @level2name = N'PerDateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Codigo de quien modificó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Person',
    @level2type = N'COLUMN',
    @level2name = N'PerTokenUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de modificicación del registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Person',
    @level2type = N'COLUMN',
    @level2name = N'PerDateUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Representa información de  personas que tiene un usuario para ingresar la portal individual',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Person',
    @level2type = NULL,
    @level2name = NULL
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificador de pais de origen por persona',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Person',
    @level2type = N'COLUMN',
    @level2name = N'PerCountryOrigin'
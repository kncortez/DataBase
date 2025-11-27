CREATE TABLE [dbo].[CatTypeAccount] (
    [TacIdTypeAccount] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [TacShortName]     VARCHAR (3)   NOT NULL,
    [TacName]          VARCHAR (30)  NOT NULL,
    [TacDescription]   VARCHAR (100) NOT NULL,
    [TacRowStatus]     BIT           NOT NULL,
    [TacTokenCreated]  VARCHAR (50)  NOT NULL,
    [TacDateCreated]   DATE          NOT NULL,
    [TacTokenUpdated]  VARCHAR (50)  NULL,
    [TacDateUpdated]   DATE          NULL,
    PRIMARY KEY CLUSTERED ([TacIdTypeAccount] ASC)
);




GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificación de registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatTypeAccount',
    @level2type = N'COLUMN',
    @level2name = N'TacIdTypeAccount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nombre corto del tipo de cuenta',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatTypeAccount',
    @level2type = N'COLUMN',
    @level2name = N'TacShortName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nombre de tipo de cuenta',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatTypeAccount',
    @level2type = N'COLUMN',
    @level2name = N'TacName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Descripción',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatTypeAccount',
    @level2type = N'COLUMN',
    @level2name = N'TacDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado(1 Activo, 0 Inactivo)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatTypeAccount',
    @level2type = N'COLUMN',
    @level2name = N'TacRowStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien creó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatTypeAccount',
    @level2type = N'COLUMN',
    @level2name = N'TacTokenCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatTypeAccount',
    @level2type = N'COLUMN',
    @level2name = N'TacDateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien modificoó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatTypeAccount',
    @level2type = N'COLUMN',
    @level2name = N'TacTokenUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de modificación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatTypeAccount',
    @level2type = N'COLUMN',
    @level2name = N'TacDateUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Catálogo de tipo de cuentas',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatTypeAccount',
    @level2type = NULL,
    @level2name = NULL
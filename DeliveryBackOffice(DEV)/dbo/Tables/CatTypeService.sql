CREATE TABLE [dbo].[CatTypeService] (
    [CtsId]             INT           IDENTITY (1, 1) NOT NULL,
    [CtsName]           VARCHAR (100) NOT NULL,
    [CtsShortName]      VARCHAR (3)   NOT NULL,
    [CtsDescription]    VARCHAR (200) NULL,
    [CtsRowStatus]      BIT           NOT NULL,
    [CtsTokenCreated]   VARCHAR (50)  NOT NULL,
    [CtsDateCreated]    DATETIME      NOT NULL,
    [CtsTokenUpdated]   VARCHAR (50)  NULL,
    [CtsDateUpdated]    DATETIME      NULL,
    [RateGroup]         INT           NULL,
    [LimitHourDelivery] TIME (7)      NULL,
    [LimitHourPickup]   TIME (7)      NULL,
    PRIMARY KEY CLUSTERED ([CtsId] ASC)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificador de tipo de servicio',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatTypeService',
    @level2type = N'COLUMN',
    @level2name = N'CtsId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Representa el tipo de servicio que brinda Forza',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatTypeService',
    @level2type = NULL,
    @level2name = NULL
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'nombre',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatTypeService',
    @level2type = N'COLUMN',
    @level2name = N'CtsName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'nombre corto',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatTypeService',
    @level2type = N'COLUMN',
    @level2name = N'CtsShortName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'descripcion',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatTypeService',
    @level2type = N'COLUMN',
    @level2name = N'CtsDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado(1 Activo, 0 Inactivo)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatTypeService',
    @level2type = N'COLUMN',
    @level2name = N'CtsRowStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien creo el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatTypeService',
    @level2type = N'COLUMN',
    @level2name = N'CtsTokenCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatTypeService',
    @level2type = N'COLUMN',
    @level2name = N'CtsDateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien modificó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatTypeService',
    @level2type = N'COLUMN',
    @level2name = N'CtsTokenUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de modificación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatTypeService',
    @level2type = N'COLUMN',
    @level2name = N'CtsDateUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Hora limite de entrega',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatTypeService',
    @level2type = N'COLUMN',
    @level2name = N'LimitHourDelivery'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Hora limite de recogida',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatTypeService',
    @level2type = N'COLUMN',
    @level2name = N'LimitHourPickup'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'indica el grupo de tarifario',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatTypeService',
    @level2type = N'COLUMN',
    @level2name = N'RateGroup'
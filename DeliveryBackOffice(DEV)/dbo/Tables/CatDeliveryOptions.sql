CREATE TABLE [dbo].[CatDeliveryOptions] (
    [IdDeliveryOption] INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Name]             NVARCHAR (100) NOT NULL,
    [Description]      NVARCHAR (200) NOT NULL,
    [RowStatus]        BIT            NOT NULL,
    [TokenCreated]     NVARCHAR (50)  NOT NULL,
    [DateCreated]      DATETIME       NOT NULL,
    [TokenUpdated]     NVARCHAR (50)  NULL,
    [DateUpdated]      DATETIME       NULL,
    [IdCountry]        VARCHAR (2)    NULL,
    PRIMARY KEY CLUSTERED ([IdDeliveryOption] ASC),
    FOREIGN KEY ([IdCountry]) REFERENCES [dbo].[CatCountry] ([IdCountry])
);






GO



EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificador del registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatDeliveryOptions',
    @level2type = N'COLUMN',
    @level2name = N'IdDeliveryOption'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nombre ',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatDeliveryOptions',
    @level2type = N'COLUMN',
    @level2name = N'Name'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Descripción',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatDeliveryOptions',
    @level2type = N'COLUMN',
    @level2name = N'Description'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado(1 Activo, 0 Inactivo)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatDeliveryOptions',
    @level2type = N'COLUMN',
    @level2name = N'RowStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien creó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatDeliveryOptions',
    @level2type = N'COLUMN',
    @level2name = N'TokenCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatDeliveryOptions',
    @level2type = N'COLUMN',
    @level2name = N'DateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien modificiación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatDeliveryOptions',
    @level2type = N'COLUMN',
    @level2name = N'TokenUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de modificación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatDeliveryOptions',
    @level2type = N'COLUMN',
    @level2name = N'DateUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificador del país para opciones de entrega de paquetes',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatDeliveryOptions',
    @level2type = N'COLUMN',
    @level2name = N'IdCountry'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Catalogo de opciones disponibles para entrega de paquetes',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatDeliveryOptions'

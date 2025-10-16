CREATE TABLE [dbo].[TypeServiceManagment] (
    [IdTypeServiceManagment] BIGINT         IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Name]                   NVARCHAR (200) NOT NULL,
    [RowStatus]              BIT            NOT NULL,
    [TokenCreated]           VARCHAR (150)  NOT NULL,
    [DateCreated]            DATETIME       NOT NULL,
    [TokenUpdated]           VARCHAR (150)  NULL,
    [DateUpdated]            DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdTypeServiceManagment] ASC)
);




GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'identificador de registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TypeServiceManagment',
    @level2type = N'COLUMN',
    @level2name = N'IdTypeServiceManagment'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nombre de tipo de gestion de servicio',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TypeServiceManagment',
    @level2type = N'COLUMN',
    @level2name = N'Name'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado(1 Activo, 0 Inactivo)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TypeServiceManagment',
    @level2type = N'COLUMN',
    @level2name = N'RowStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien creó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TypeServiceManagment',
    @level2type = N'COLUMN',
    @level2name = N'TokenCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TypeServiceManagment',
    @level2type = N'COLUMN',
    @level2name = N'DateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien modificó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TypeServiceManagment',
    @level2type = N'COLUMN',
    @level2name = N'TokenUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de modificación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TypeServiceManagment',
    @level2type = N'COLUMN',
    @level2name = N'DateUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Catálogo de tipos de gestión de servicios(recolección, entrega)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TypeServiceManagment',
    @level2type = NULL,
    @level2name = NULL
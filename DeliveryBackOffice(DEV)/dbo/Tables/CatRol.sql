CREATE TABLE [dbo].[CatRol] (
    [RolIdRol]         INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [RolIdSystem]      INT           NOT NULL,
    [RolName]          VARCHAR (50)  NOT NULL,
    [RolDescription]   VARCHAR (100) NOT NULL,
    [RolAdminBrothers] BIT           NULL,
    [RolAdminClient]   BIT           NOT NULL,
    [RolRowStatus]     BIT           NOT NULL,
    [RolTokenCreated]  VARCHAR (50)  NOT NULL,
    [RolDateCreated]   DATETIME      NOT NULL,
    [RolokenUpdated]   VARCHAR (50)  NULL,
    [RolDateUpdated]   DATETIME      NULL,
    [RolAdminInternal] BIT           NULL,
    PRIMARY KEY CLUSTERED ([RolIdRol] ASC),
    FOREIGN KEY ([RolIdSystem]) REFERENCES [dbo].[CatSystem] ([SysIdSystem])
);




GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificación del rol',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatRol',
    @level2type = N'COLUMN',
    @level2name = N'RolIdRol'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificación del sistema',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatRol',
    @level2type = N'COLUMN',
    @level2name = N'RolIdSystem'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nombre del rol',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatRol',
    @level2type = N'COLUMN',
    @level2name = N'RolName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Descripción del sistema',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatRol',
    @level2type = N'COLUMN',
    @level2name = N'RolDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado(1 Activo, 0 Inactivo)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatRol',
    @level2type = N'COLUMN',
    @level2name = N'RolRowStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien creo el rol',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatRol',
    @level2type = N'COLUMN',
    @level2name = N'RolTokenCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creación del rol',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatRol',
    @level2type = N'COLUMN',
    @level2name = N'RolDateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien modifico el rol',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatRol',
    @level2type = N'COLUMN',
    @level2name = N'RolokenUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de moficicación del rol',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatRol',
    @level2type = N'COLUMN',
    @level2name = N'RolDateUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Representa los roles, y el sistema al cual dicho rol tiene acceso',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatRol',
    @level2type = NULL,
    @level2name = NULL
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Indica si el rol tiene roles del mismo nivel(EN DESUSO)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatRol',
    @level2type = N'COLUMN',
    @level2name = N'RolAdminBrothers'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Indica si el rol es de cliente(EN DESUSO)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatRol',
    @level2type = N'COLUMN',
    @level2name = N'RolAdminClient'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Indica si el rol es interno o no',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatRol',
    @level2type = N'COLUMN',
    @level2name = N'RolAdminInternal'
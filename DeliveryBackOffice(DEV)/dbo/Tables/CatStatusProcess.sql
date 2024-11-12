CREATE TABLE [dbo].[CatStatusProcess]
(
	[IdStatusProcess] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY,
    [NameStatusProcess] NVARCHAR(50) NOT NULL, 
    [DescriptionStatusProcess] NVARCHAR(200) NULL, 
    [RowStatus] NCHAR(10) NOT NULL, 
    [UserCreated] NVARCHAR(50) NOT NULL, 
    [DateCreated] DATETIME NOT NULL, 
    [UserUpdated] NVARCHAR(50) NULL, 
    [DateUpdated] DATETIME NULL, 
    [Icon] NVARCHAR(200) NULL
);
GO

EXECUTE sp_addextendedproperty 
@name = N'MS_Description', 
@value = N'Identificador �nico para los estados de proceso en tracking', 
@level0type = N'SCHEMA', @level0name = 'dbo', 
@level1type = N'TABLE',  @level1name = 'CatStatusProcess', 
@level2type = N'COLUMN', @level2name = 'IdStatusProcess';

GO
EXECUTE sp_addextendedproperty 
@name = N'MS_Description', 
@value = N'Nombre del estado del proceso en tracking', 
@level0type = N'SCHEMA', @level0name = 'dbo', 
@level1type = N'TABLE',  @level1name = 'CatStatusProcess', 
@level2type = N'COLUMN', @level2name = 'NameStatusProcess';

GO
EXECUTE sp_addextendedproperty 
@name = N'MS_Description', 
@value = N'Descripci�n del significado de cada uno de los estados en tracking', 
@level0type = N'SCHEMA', @level0name = 'dbo', 
@level1type = N'TABLE',  @level1name = 'CatStatusProcess', 
@level2type = N'COLUMN', @level2name = 'DescriptionStatusProcess';

GO
EXECUTE sp_addextendedproperty 
@name = N'MS_Description', 
@value = N'Estado l�gico (activo/inactivo)', 
@level0type = N'SCHEMA', @level0name = 'dbo', 
@level1type = N'TABLE',  @level1name = 'CatStatusProcess', 
@level2type = N'COLUMN', @level2name = 'RowStatus';

GO
EXECUTE sp_addextendedproperty 
@name = N'MS_Description', 
@value = N'Usuario que cre� el registro', 
@level0type = N'SCHEMA', @level0name = 'dbo', 
@level1type = N'TABLE',  @level1name = 'CatStatusProcess', 
@level2type = N'COLUMN', @level2name = 'UserCreated';

GO
EXECUTE sp_addextendedproperty 
@name = N'MS_Description', 
@value = N'Fecha de creaci�n del registro', 
@level0type = N'SCHEMA', @level0name = 'dbo', 
@level1type = N'TABLE',  @level1name = 'CatStatusProcess', 
@level2type = N'COLUMN', @level2name = 'DateCreated';

GO
EXECUTE sp_addextendedproperty 
@name = N'MS_Description', 
@value = N'Usuario que actualiz� el registro', 
@level0type = N'SCHEMA', @level0name = 'dbo', 
@level1type = N'TABLE',  @level1name = 'CatStatusProcess', 
@level2type = N'COLUMN', @level2name = 'UserUpdated';

GO
EXECUTE sp_addextendedproperty 
@name = N'MS_Description', 
@value = N'Fecha de actualizaci�n del registro', 
@level0type = N'SCHEMA', @level0name = 'dbo', 
@level1type = N'TABLE',  @level1name = 'CatStatusProcess', 
@level2type = N'COLUMN', @level2name = 'DateUpdated';

GO
EXECUTE sp_addextendedproperty 
@name = N'MS_Description', 
@value = N'Tabla que obtiene los nuevos estados de agrupaci�n para proceso de seguimiento.', 
@level0type = N'SCHEMA', @level0name = 'dbo', 
@level1type = N'TABLE',  @level1name = 'CatStatusProcess';

GO
EXEC sp_addextendedproperty 
@name = N'MS_Description', 
@value = N'Icono para visualizaci�n en tracking', 
@level0type = N'SCHEMA', @level0name = 'dbo', 
@level1type = N'TABLE',  @level1name = 'CatStatusProcess', 
@level2type = N'COLUMN', @level2name = 'Icon';

GO
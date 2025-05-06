CREATE TABLE [dbo].[CatStatusGuideByContainer]
(
	[IdStatus]			INT IDENTITY (1, 1) NOT NULL,
	[Name]				NVARCHAR (100) NOT NULL,
	[Description]		NVARCHAR (200) NULL,
	[RowStatus]			BIT NOT NULL DEFAULT 1,
	[UserCreated]		NVARCHAR(50) NOT NULL,
	[DateCreated]		DATETIME NOT NULL,
	[UserUpdated]		NVARCHAR(50) NULL,
	[DateUpdated]		DATETIME NULL,
	CONSTRAINT [PK_CatStatusGuideByContainer] PRIMARY KEY CLUSTERED ([IdStatus] ASC)

)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificador de registros',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatStatusGuideByContainer',
    @level2type = N'COLUMN',
    @level2name = N'IdStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nombre del estado',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatStatusGuideByContainer',
    @level2type = N'COLUMN',
    @level2name = N'Name'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Descripcion de estado',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatStatusGuideByContainer',
    @level2type = N'COLUMN',
    @level2name = N'Description'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado de registro(1 activo, 0 inactivo)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatStatusGuideByContainer',
    @level2type = N'COLUMN',
    @level2name = N'RowStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Usuario que crea registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatStatusGuideByContainer',
    @level2type = N'COLUMN',
    @level2name = N'UserCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creacion',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatStatusGuideByContainer',
    @level2type = N'COLUMN',
    @level2name = N'DateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Usuario que modifica registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatStatusGuideByContainer',
    @level2type = N'COLUMN',
    @level2name = N'UserUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de modificacion',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatStatusGuideByContainer',
    @level2type = N'COLUMN',
    @level2name = N'DateUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Catalogo de estado en el que la guia esta dentro del contenedor',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatStatusGuideByContainer',
    @level2type = NULL,
    @level2name = NULL
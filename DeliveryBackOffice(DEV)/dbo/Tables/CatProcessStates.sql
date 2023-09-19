CREATE TABLE [dbo].[CatProcessStates](
	[IdCatProcessStates] [int] IDENTITY(1,1) NOT NULL,
	[NameStatus] [nvarchar](50) NOT NULL,
	[DescriptionStatus] [nvarchar](250) NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdate] [nvarchar](50) NULL,
	[DateUpdate] [datetime] NULL,
 CONSTRAINT [PK_CatProcessStates] PRIMARY KEY CLUSTERED 
(
	[IdCatProcessStates] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Llave principal de la tabla de estado de un proceso' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProcessStates', @level2type=N'COLUMN',@level2name=N'IdCatProcessStates'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del estado del proceso, este puede ser Prepagado, finaliziado, esto para indicar que el proceso de cobro, asignación y facturación de carrito haya finalziado correctamente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProcessStates', @level2type=N'COLUMN',@level2name=N'NameStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripción breve  del estado' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProcessStates', @level2type=N'COLUMN',@level2name=N'DescriptionStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'indica si el esatdo esta activo o inactivo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProcessStates', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'token de persona que creo el estado' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProcessStates', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'fecha en que se creo el estado' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProcessStates', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de actualziación ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProcessStates', @level2type=N'COLUMN',@level2name=N'TokenUpdate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de actualización' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProcessStates', @level2type=N'COLUMN',@level2name=N'DateUpdate'
GO



CREATE TABLE [dbo].[CatMembership](
	[IdCatMembership] [int] IDENTITY(1,1) NOT NULL,
	[MembershipName] [nvarchar](50) NOT NULL,
	[MembershipDescription] [nvarchar](300) NOT NULL,
	[MembershipCost] [decimal](18, 2) NOT NULL,
	[MembershipFixedValue] [int] NOT NULL,
	[MembershipMaxServiceFixedValue] [int] NOT NULL,
	[MembershipValidity] [int] NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
	[Icon] [nvarchar](50) NULL,
	[NextSalesPackageBanner] [nvarchar](200) NULL,
	[CatProductCategoryId] [int] NULL,
	[Tag] [nvarchar](100) NULL,
	[Position] [int] NULL,
 CONSTRAINT [PK_CatMembership] PRIMARY KEY CLUSTERED 
(
	[IdCatMembership] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del registro.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMembership', @level2type=N'COLUMN',@level2name=N'IdCatMembership'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de la membresia.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMembership', @level2type=N'COLUMN',@level2name=N'MembershipName'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripción de la membresia.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMembership', @level2type=N'COLUMN',@level2name=N'MembershipDescription'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Costo monetario para comprar la membresia.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMembership', @level2type=N'COLUMN',@level2name=N'MembershipCost'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Monto fijo de servicios de guía, limitado a una cantidad.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMembership', @level2type=N'COLUMN',@level2name=N'MembershipFixedValue'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cantidad maxima de servicios los cuales tendran un monto fijo.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMembership', @level2type=N'COLUMN',@level2name=N'MembershipMaxServiceFixedValue'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tiempo, en días, que será valida la membresia.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMembership', @level2type=N'COLUMN',@level2name=N'MembershipValidity'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado lógico del registro.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMembership', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de creación del registro.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMembership', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación del registro.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMembership', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Último token de actualización del registro.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMembership', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Última fecha de actualización del registro.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMembership', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Campo de ícono configurable' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMembership', @level2type=N'COLUMN',@level2name=N'Icon'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de banner a desplegar cuando servicios de monto fijo esten proximos a acabarse' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMembership', @level2type=N'COLUMN',@level2name=N'NextSalesPackageBanner'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'etiqueta de identificación ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMembership', @level2type=N'COLUMN',@level2name=N'Tag'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Ordenar membresia por posición' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMembership', @level2type=N'COLUMN',@level2name=N'Position'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla de catalogo de membresias.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMembership'
GO



USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[CatContainerSubtype]    Script Date: 4/20/2023 15:06:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CatContainerSubtype](
	[IdCatContainerSubtype] [BIGINT] IDENTITY(1,1) NOT NULL,
	[ContainerSubtypeName] [NVARCHAR](100) NOT NULL,
	[ContainerSubtypeDescription] [NVARCHAR](600) NULL,
	[RowStatus] [BIT] NOT NULL,
	[DateCreated] [DATETIME] NOT NULL,
	[TokenCreated] [NVARCHAR](50) NOT NULL,
	[DateUpdated] [DATETIME] NULL,
	[TokenUpdated] [NVARCHAR](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[IdCatContainerSubtype] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CatContainerSubtype] ADD  DEFAULT ((0)) FOR [RowStatus]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del registro.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatContainerSubtype', @level2type=N'COLUMN',@level2name=N'IdCatContainerSubtype'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de subcategoria de contenedor.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatContainerSubtype', @level2type=N'COLUMN',@level2name=N'ContainerSubtypeName'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripción de la subcategoria de contenedor.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatContainerSubtype', @level2type=N'COLUMN',@level2name=N'ContainerSubtypeDescription'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado lógico del registro.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatContainerSubtype', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación del registro.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatContainerSubtype', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de creación del registro.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatContainerSubtype', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Última fecha de actualización del registro.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatContainerSubtype', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Último token de actualización del registro.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatContainerSubtype', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla de subcategorias de tipos de contenedor.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatContainerSubtype'
GO



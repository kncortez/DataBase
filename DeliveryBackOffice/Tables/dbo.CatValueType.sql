USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[CatValueType]    Script Date: 5/28/2022 16:51:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CatValueType](
	[IdCatValueType] [int] IDENTITY(1,1) NOT NULL,
	[ValueTypeName] [nvarchar](50) NOT NULL,
	[ValueTypeDescription] [nvarchar](200) NULL,
	[RowStatus] [bit] NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateUpdated] [datetime] NULL,
	[TokenUpdated] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[IdCatValueType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CatValueType] ADD  DEFAULT ((1)) FOR [RowStatus]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del registro.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatValueType', @level2type=N'COLUMN',@level2name=N'IdCatValueType'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del tipo de valor.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatValueType', @level2type=N'COLUMN',@level2name=N'ValueTypeName'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripción del tipo de valor.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatValueType', @level2type=N'COLUMN',@level2name=N'ValueTypeDescription'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado lógico.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatValueType', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatValueType', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de creación.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatValueType', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Última fecha de actualización.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatValueType', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Último token de creación.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatValueType', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Catálogo de tipos de valor.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatValueType'
GO



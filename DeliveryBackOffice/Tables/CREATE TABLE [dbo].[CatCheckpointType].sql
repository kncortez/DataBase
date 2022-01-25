USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[CatCheckPoints]    Script Date: 1/24/2022 11:33:44 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CatCheckpointType](
	[IdCatCheckpointType] [tinyint] NOT NULL,
	[CheckpointTypeDescription] [nvarchar](200) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[IdCatCheckpointType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatCheckpointType', @level2type=N'COLUMN',@level2name=N'IdCatCheckpointType'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripción del tipo de checkpoint' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatCheckpointType', @level2type=N'COLUMN',@level2name=N'CheckpointTypeDescription'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Catalogo de tipos de checkpoint' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatCheckpointType'
GO



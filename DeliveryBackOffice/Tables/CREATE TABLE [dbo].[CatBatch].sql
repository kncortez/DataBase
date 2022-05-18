USE [DeliveryBackOffice]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CatBatch](
	[IdCatBatch] [int] IDENTITY(1,1) NOT NULL,
	[CatName] [nvarchar](500) NOT NULL,
	[CatDescription] [varchar](500) NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [PK_CatBatch_IdCatBatchD] PRIMARY KEY CLUSTERED 
(
	[IdCatBatch] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CatBatch] ADD  CONSTRAINT [DF_CatBatch_RowStatus]  DEFAULT ('TRUE') FOR [RowStatus]
GO

ALTER TABLE [dbo].[CatBatch] ADD  CONSTRAINT [DF_CatBatch_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Id correlativo de la tabla IdCatBatch' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatBatch', @level2type=N'COLUMN',@level2name=N'IdCatBatch'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del tipo de lote (COD, Recolección, Collect, Comisiones)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatBatch', @level2type=N'COLUMN',@level2name=N'CatName'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Describe lo que involucra el lote' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatBatch', @level2type=N'COLUMN',@level2name=N'CatDescription'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatBatch', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token del usuario que crea el registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatBatch', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatBatch', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token del usuario que actualiza el registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatBatch', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de actualización' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatBatch', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO



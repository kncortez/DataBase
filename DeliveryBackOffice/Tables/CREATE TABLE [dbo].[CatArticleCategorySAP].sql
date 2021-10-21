USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[Customer]    Script Date: 6/10/2021 14:17:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CatArticleCategorySAP](
	[IdCatCategoryArticleSAP] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Description] [nvarchar](100) NULL,
	[RowSatus] [bit] NULL,
	[TokenCreated] [nvarchar](50) NULL,
	[DateCreated] [datetime] NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[IdCatCategoryArticleSAP] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CatArticleCategorySAP] ADD  CONSTRAINT [DF_CatArticleCategorySAP_RowStatus]  DEFAULT ('TRUE') FOR [RowSatus]
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Id CatArticleCategorySAP', N'SCHEMA', N'dbo', N'TABLE', N'CatArticleCategorySAP', N'COLUMN', N'IdCatCategoryArticleSAP'
EXECUTE sp_addextendedproperty N'MS_Description', N'Nombre categoría', N'SCHEMA', N'dbo', N'TABLE', N'CatArticleCategorySAP', N'COLUMN', N'Name'
EXECUTE sp_addextendedproperty N'MS_Description', N'Descripción categoría', N'SCHEMA', N'dbo', N'TABLE', N'CatArticleCategorySAP', N'COLUMN', N'Description'
EXECUTE sp_addextendedproperty N'MS_Description', N'RowSatus categoría', N'SCHEMA', N'dbo', N'TABLE', N'CatArticleCategorySAP', N'COLUMN', N'RowSatus'
EXECUTE sp_addextendedproperty N'MS_Description', N'TokenCreated categoría', N'SCHEMA', N'dbo', N'TABLE', N'CatArticleCategorySAP', N'COLUMN', N'TokenCreated'
EXECUTE sp_addextendedproperty N'MS_Description', N'DateCreated categoría', N'SCHEMA', N'dbo', N'TABLE', N'CatArticleCategorySAP', N'COLUMN', N'DateCreated'
EXECUTE sp_addextendedproperty N'MS_Description', N'TokenUpdated categoría', N'SCHEMA', N'dbo', N'TABLE', N'CatArticleCategorySAP', N'COLUMN', N'TokenUpdated'
EXECUTE sp_addextendedproperty N'MS_Description', N'DateUpdated categoría', N'SCHEMA', N'dbo', N'TABLE', N'CatArticleCategorySAP', N'COLUMN', N'DateUpdated'

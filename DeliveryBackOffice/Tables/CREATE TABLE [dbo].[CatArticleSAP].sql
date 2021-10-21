USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[Customer]    Script Date: 6/10/2021 14:17:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CatArticleSAP](
	[IdCatArticleSAP] [int] IDENTITY(1,1) NOT NULL,
	[CatCategoryArticleSAPId] [int] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Description] [nvarchar](100) NULL,
	[SAPCode] [nvarchar](50) NULL,
	[RowSatus] [bit] NULL,
	[TokenCreated] [nvarchar](50) NULL,
	[DateCreated] [datetime] NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[IdCatArticleSAP] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CatArticleSAP] ADD  CONSTRAINT [DF_CatArticleSAP_RowStatus]  DEFAULT ('TRUE') FOR [RowSatus]
GO

ALTER TABLE [dbo].[CatArticleSAP] ADD CONSTRAINT FK_CatArticleSAP_CatCategoryArticleSAP FOREIGN KEY ([CatCategoryArticleSAPId]) 
REFERENCES [dbo].[CatArticleCategorySAP] ([IdCatCategoryArticleSAP]) 
ON UPDATE  NO ACTION 
ON DELETE  CASCADE
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Id CatArticleSAP', N'SCHEMA', N'dbo', N'TABLE', N'CatArticleSAP', N'COLUMN', N'IdCatArticleSAP'
EXECUTE sp_addextendedproperty N'MS_Description', N'Id CatCategoryArticleSAP', N'SCHEMA', N'dbo', N'TABLE', N'CatArticleSAP', N'COLUMN', N'CatCategoryArticleSAPId'
EXECUTE sp_addextendedproperty N'MS_Description', N'Nombre artículo', N'SCHEMA', N'dbo', N'TABLE', N'CatArticleSAP', N'COLUMN', N'Name'
EXECUTE sp_addextendedproperty N'MS_Description', N'Descripción artículo', N'SCHEMA', N'dbo', N'TABLE', N'CatArticleSAP', N'COLUMN', N'Description'
EXECUTE sp_addextendedproperty N'MS_Description', N'Código SAP artículo', N'SCHEMA', N'dbo', N'TABLE', N'CatArticleSAP', N'COLUMN', N'SAPCode'
EXECUTE sp_addextendedproperty N'MS_Description', N'RowSatus categoría', N'SCHEMA', N'dbo', N'TABLE', N'CatArticleSAP', N'COLUMN', N'RowSatus'
EXECUTE sp_addextendedproperty N'MS_Description', N'TokenCreated categoría', N'SCHEMA', N'dbo', N'TABLE', N'CatArticleSAP', N'COLUMN', N'TokenCreated'
EXECUTE sp_addextendedproperty N'MS_Description', N'DateCreated categoría', N'SCHEMA', N'dbo', N'TABLE', N'CatArticleSAP', N'COLUMN', N'DateCreated'
EXECUTE sp_addextendedproperty N'MS_Description', N'TokenUpdated categoría', N'SCHEMA', N'dbo', N'TABLE', N'CatArticleSAP', N'COLUMN', N'TokenUpdated'
EXECUTE sp_addextendedproperty N'MS_Description', N'DateUpdated categoría', N'SCHEMA', N'dbo', N'TABLE', N'CatArticleSAP', N'COLUMN', N'DateUpdated'

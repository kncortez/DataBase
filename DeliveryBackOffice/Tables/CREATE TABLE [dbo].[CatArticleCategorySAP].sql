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
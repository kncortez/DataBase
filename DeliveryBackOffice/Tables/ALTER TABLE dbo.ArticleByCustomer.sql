USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[ArticleByCustomer]    Script Date: 26/03/2021 10:36:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DROP TABLE [dbo].[ArticleByCustomer]

CREATE TABLE [dbo].[ArticleByCustomer](
	AbcId int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[AbcIdArticle] [int] NOT NULL,
	[AbcIdCustomer] [int] NOT NULL,
	[AbcRowStatus] [bit] NOT NULL,
	[AbcTokenCreated] [varchar](50) NOT NULL,
	[AbcDateCreated] [datetime] NOT NULL,
	[AbcTokenUpdated] [varchar](50) NULL,
	[AbcDateUpdated] [datetime] NULL,
	[Code] [nvarchar](20) NULL,
	[PriceDefault] [decimal](12, 2) NULL,
 CONSTRAINT [AK_Password] UNIQUE NONCLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ArticleByCustomer]  WITH CHECK ADD  CONSTRAINT [FKArticleCustom] FOREIGN KEY([AbcIdArticle])
REFERENCES [dbo].[CatArticle] ([ArtId])
GO

ALTER TABLE [dbo].[ArticleByCustomer] CHECK CONSTRAINT [FKArticleCustom]
GO

ALTER TABLE [dbo].[ArticleByCustomer]  WITH CHECK ADD  CONSTRAINT [FKCustomArticle] FOREIGN KEY([AbcIdCustomer])
REFERENCES [dbo].[Customer] ([IdCustomer])
GO

ALTER TABLE [dbo].[ArticleByCustomer] CHECK CONSTRAINT [FKCustomArticle]
GO


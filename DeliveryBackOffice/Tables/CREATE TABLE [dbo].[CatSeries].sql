USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[CatSeries]    Script Date: 1/25/2021 9:01:05 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CatSeries](
	[IdSerie] [varchar](10) NOT NULL,
	[SerieStatus] [int] NULL,
	[SerieDateCreated] [datetime] NULL,
	[SerieTokenCreate] [varchar](50) NULL,
	[SerieDateUpdate] [datetime] NULL,
	[SerieTokenUpdate] [nchar](10) NULL
 CONSTRAINT [PK_CatCountry] PRIMARY KEY CLUSTERED 
(
	[IdSerie] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[[DeliveryOrderPaymentDetail]]    Script Date: 1/23/2021 5:01:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DeliveryOrderPaymentDetail](
	[GuideNumber] [int]  NOT NULL,
	[GuideSerie] [varchar](2) NULL,
	[PayTypeId] [int] NULL,
	[WayPayId] [int] NULL,
	[TimePlaId] [int] NULL,
	[amount] [decimal](18,2) NULL,
	[TokenCreated] [varchar](50) NULL,
	[DateCreated] [datetime]  NULL,
	[TokenUpdated] [varchar](50) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [GuideNumber] PRIMARY KEY CLUSTERED 
(
	[GuideNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

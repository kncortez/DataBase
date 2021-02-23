USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[CatWayToPay]    Script Date: 1/23/2021 5:01:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CatWayToPay](
	[WayPayId] [int] IDENTITY(1,1) NOT NULL,
	[WayPayName] [varchar](55) NULL,
	[WayPayDescription] [varchar](100) NULL,
	[WayPayAbrev] [varchar](10) NULL,
	[WayPayStatus] [int] NULL,
	[TokenCreated] [varchar](50) NULL,
	[DateCreated] [datetime]  NULL,
	[TokenUpdated] [varchar](50) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [WayPayId] PRIMARY KEY CLUSTERED 
(
	[WayPayId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


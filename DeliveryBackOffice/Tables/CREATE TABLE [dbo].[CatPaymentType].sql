USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[CatPaymentType]    Script Date: 1/23/2021 5:01:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CatPaymentType](
	[PayTypeId] [int] IDENTITY(1,1) NOT NULL,
	[PayTypeName] [varchar](55) NULL,
	[PayTypeDescriptions] [varchar](100) NULL,
	[PayTypeAbrev] [varchar](10) NULL,
	[PayTypeStatus] [int] NULL,
	[TokenCreated] [varchar](50) NULL,
	[DateCreated] [datetime]  NULL,
	[TokenUpdated] [varchar](50) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [PayTypeId] PRIMARY KEY CLUSTERED 
(
	[PayTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO












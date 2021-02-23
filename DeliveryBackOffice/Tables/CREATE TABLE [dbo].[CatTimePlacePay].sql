USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[CatPaymentTime]    Script Date: 1/23/2021 5:01:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CatPaymentTime](
	[TimePlaId] [int] IDENTITY(1,1) NOT NULL,
	[TimePlaName] [varchar](55) NULL,
	[TimePlaDescription] [varchar](100) NULL,
	[TimePlaAbrev] [varchar](10) NULL,
	[TimePlaStatus] [int] NULL,
	[TokenCreated] [varchar](50) NULL,
	[DateCreated] [datetime]  NULL,
	[TokenUpdated] [varchar](50) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [TimePlaId] PRIMARY KEY CLUSTERED 
(
	[TimePlaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

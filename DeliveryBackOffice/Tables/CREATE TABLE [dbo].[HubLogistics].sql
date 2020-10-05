USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[HubLogistics]    Script Date: 30/09/2020 18:08:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[HubLogistics](
	[IdHubLogistic] [int] IDENTITY(1,1) NOT NULL,
	[HubName] [varchar](50) NULL,
	[HubAbbreviation] [varchar](5) NULL,
	[HubStatus] [bit] NULL,
	[IdStation] [int] NULL,
	[IdCountry] [varchar](2) NULL,
	[TokenCreated] [varchar](50) NULL,
	[DateCreated] [datetime] NULL,
	[TokenUpdate] [varchar](50) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [PK_HubLogistics] PRIMARY KEY CLUSTERED 
(
	[IdHubLogistic] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO



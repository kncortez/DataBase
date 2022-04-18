USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[CatLinehaul]    Script Date: 11/04/2022 12:15:03 p. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ServicesConfig](
	[IdServicesConfig] [bigint] IDENTITY(1,1) NOT NULL,
	[ServiceName] VARCHAR(500) NOT NULL,
	[ServiceProcess] VARCHAR(500) NOT NULL,
	[TimeSchedule] [varchar](4000) NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[NotifyEmails] [nvarchar](2000) NOT NULL,
	[TokenCreated] [varchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [varchar](50) NULL,
	[DateUpdated] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[IdServicesConfig] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] 
GO

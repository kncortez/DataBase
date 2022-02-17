USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[CatRoute]    Script Date: 9/04/2021 17:33:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CatLinehaul](
	[IdLinehaul] [int] IDENTITY(1,1) NOT NULL,
	[IdRoute] [int] NOT NULL,
	[IdHubOrigin] [int] NOT NULL,
	[IdHubDestination] [int] NOT NULL,
	[Emails] NVARCHAR(MAX) NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [varchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [varchar](50) NULL,
	[DateUpdated] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[IdLinehaul] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CatLinehaul]  WITH CHECK ADD  CONSTRAINT [FK_CatLinehaulRoute] FOREIGN KEY([IdRoute])
REFERENCES [dbo].[CatRoute] ([IdRoute])
GO

ALTER TABLE [dbo].[CatLinehaul]  WITH CHECK ADD  CONSTRAINT [FK_IdHubOrigin_IdHubLogistic] FOREIGN KEY([IdHubOrigin])
REFERENCES [dbo].[HubLogistics] ([IdHubLogistic])
GO

ALTER TABLE [dbo].[CatLinehaul]  WITH CHECK ADD  CONSTRAINT [FK_IdHubDestination_IdHubLogistic] FOREIGN KEY([IdHubDestination])
REFERENCES [dbo].[HubLogistics] ([IdHubLogistic])
GO



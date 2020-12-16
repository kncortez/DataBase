USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[TownshipByHubLogistic]    Script Date: 15/12/2020 21:50:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[VisitPointClientByHubLogistics](
	[IdVpcHub] [int] IDENTITY(1,1) NOT NULL,
	[IdVisitPointClient] [int] NULL,
	[IdHublogistic] [int] NULL,
	[StatusTownshipHub] [bit] NULL,
	[TokenCreated] [varchar](50) NULL,
	[DateCreated] [datetime] NULL,
	[TokenUpdate] [varchar](50) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [PK_VpcByHubLogistic] PRIMARY KEY CLUSTERED 
(
	[IdVpcHub] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[VisitPointClientByHubLogistics]  WITH CHECK ADD  CONSTRAINT [FK_VpcByHubLogistics_HubLogistics] FOREIGN KEY([IdHublogistic])
REFERENCES [dbo].[HubLogistics] ([IdHubLogistic])
GO

ALTER TABLE [dbo].[VisitPointClientByHubLogistics] CHECK CONSTRAINT [FK_VpcByHubLogistics_HubLogistics]
GO

ALTER TABLE [dbo].[VisitPointClientByHubLogistics]  WITH CHECK ADD  CONSTRAINT [FK_VpcByHubLogistics_Vpc] FOREIGN KEY([IdVisitPointClient])
REFERENCES [dbo].[VisitPointClient] ([CodeOfReference])
GO

ALTER TABLE [dbo].[VisitPointClientByHubLogistics] CHECK CONSTRAINT [FK_VpcByHubLogistics_Vpc]
GO


USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[VisitPointFrequency]    Script Date: 5/17/2021 8:44:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[VisitPointFrequency](
	[IdVPFrequency] [bigint] IDENTITY(1,1) NOT NULL,
	[VPConfigurationID] [bigint] NOT NULL,
	[SeasonID] [int] NULL,
	[VisitsOnSunday] [tinyint] NULL,
	[VisitsOnMonday] [tinyint] NULL,
	[VisitsOnTuesday] [tinyint] NULL,
	[VisitsOnWednesday] [tinyint] NULL,
	[VisitsOnThursday] [tinyint] NULL,
	[VisitsOnFriday] [tinyint] NULL,
	[VisitsOnSaturday] [tinyint] NULL,
	[HubLogisticID] [int] NULL,
	[RowStatus] [bit] NULL,
	[TokenCreated] [nvarchar](50) NULL,
	[DateCreated] [datetime] NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [PK_VisitPointFrequency] PRIMARY KEY CLUSTERED 
(
	[IdVPFrequency] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[VisitPointFrequency]  WITH CHECK ADD  CONSTRAINT [FK_VisitPointFrequency_CatSeason] FOREIGN KEY([SeasonID])
REFERENCES [dbo].[CatSeason] ([IdSeason])
GO

ALTER TABLE [dbo].[VisitPointFrequency] CHECK CONSTRAINT [FK_VisitPointFrequency_CatSeason]
GO

ALTER TABLE [dbo].[VisitPointFrequency]  WITH CHECK ADD  CONSTRAINT [FK_VisitPointFrequency_HubLogistics] FOREIGN KEY([HubLogisticID])
REFERENCES [dbo].[HubLogistics] ([IdHubLogistic])
GO

ALTER TABLE [dbo].[VisitPointFrequency] CHECK CONSTRAINT [FK_VisitPointFrequency_HubLogistics]
GO

ALTER TABLE [dbo].[VisitPointFrequency]  WITH CHECK ADD  CONSTRAINT [FK_VisitPointFrequency_VisitPointConfiguration] FOREIGN KEY([VPConfigurationID])
REFERENCES [dbo].[VisitPointConfiguration] ([IdVPConfiguration])
GO

ALTER TABLE [dbo].[VisitPointFrequency] CHECK CONSTRAINT [FK_VisitPointFrequency_VisitPointConfiguration]
GO



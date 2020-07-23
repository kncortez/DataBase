USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[ScheduledVisitSettlement]    Script Date: 16/07/2020 03:02:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ScheduledVisitSettlement](
	[IdSettScheduleVisit] [bigint] IDENTITY(1,1) NOT NULL,
	[IdSettlement] [bigint] NULL,
	[IdSegmentArea] [int] NULL,
	[Comment] [nvarchar](50) NULL,
	[OrderSequence] [int] NULL,
	[ScheduledVisitSunday] [bit] NULL,
	[ScheduledVisitMonday] [bit] NULL,
	[ScheduledVisitTuesday] [bit] NULL,
	[ScheduledVisitWednesday] [bit] NULL,
	[ScheduledVisitThursday] [bit] NULL,
	[ScheduledVisitFriday] [bit] NULL,
	[ScheduledVisitSaturday] [bit] NULL,
	[SettScheduleVisitStatus] [bit] NULL,
	[TokenCreated] [nvarchar](50) NULL,
	[DateCreated] [datetime] NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [PK_ScheduledVisitSettlement] PRIMARY KEY CLUSTERED 
(
	[IdSettScheduleVisit] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ScheduledVisitSettlement]  WITH CHECK ADD  CONSTRAINT [FK_ScheduledVisitSettlement_SegmentArea] FOREIGN KEY([IdSegmentArea])
REFERENCES [dbo].[SegmentArea] ([IdSegmentArea])
GO

ALTER TABLE [dbo].[ScheduledVisitSettlement] CHECK CONSTRAINT [FK_ScheduledVisitSettlement_SegmentArea]
GO

ALTER TABLE [dbo].[ScheduledVisitSettlement]  WITH CHECK ADD  CONSTRAINT [FK_ScheduledVisitSettlement_Settlement] FOREIGN KEY([IdSettlement])
REFERENCES [dbo].[Settlement] ([IdSettlement])
GO

ALTER TABLE [dbo].[ScheduledVisitSettlement] CHECK CONSTRAINT [FK_ScheduledVisitSettlement_Settlement]
GO



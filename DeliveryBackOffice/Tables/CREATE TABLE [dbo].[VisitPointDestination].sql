USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[VisitPointDestination]    Script Date: 5/17/2021 9:09:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[VisitPointDestination](
	[IdVPSource] [int] NOT NULL,
	[IDVPDestiny] [int] NOT NULL,
	[IsGuard] [bit] NULL,
	[IsTransit] [bit] NULL,
	[IsDefault] [bit] NULL,
	[RowStatus] [bit] NULL,
	[TokenCreated] [nvarchar](50) NULL,
	[DateCreated] [datetime] NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [PK_VisitPointDestination] PRIMARY KEY CLUSTERED 
(
	[IdVPSource] ASC,
	[IDVPDestiny] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[VisitPointDestination]  WITH CHECK ADD  CONSTRAINT [FK_VisitPointDestination_VisitPointClientSource] FOREIGN KEY([IdVPSource])
REFERENCES [dbo].[VisitPointClient] ([CodeOfReference])
GO

ALTER TABLE [dbo].[VisitPointDestination] CHECK CONSTRAINT [FK_VisitPointDestination_VisitPointClientSource]
GO

ALTER TABLE [dbo].[VisitPointDestination]  WITH CHECK ADD  CONSTRAINT [FK_VisitPointDestination_VisitPointClientDestiny] FOREIGN KEY([IDVPDestiny])
REFERENCES [dbo].[VisitPointClient] ([CodeOfReference])
GO

ALTER TABLE [dbo].[VisitPointDestination] CHECK CONSTRAINT [FK_VisitPointDestination_VisitPointClientDestiny]
GO



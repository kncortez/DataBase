USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[GuideBatch]    Script Date: 9/7/2021 10:31:07 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[GuideBatch](
	[IdUser] [bigint] NOT NULL,
	[GuideNumber] [varchar](100) NOT NULL,
	[IdBatch] [bigint] NOT NULL,
  [IdVisitPointByClientPortfolio] [bigint] NOT NULL,
  [IdAddress] [bigint] NOT NULL,
	[Status] [int] NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [varchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [varchar](50) NULL,
	[DateUpdated] [datetime] NULL
) 
GO



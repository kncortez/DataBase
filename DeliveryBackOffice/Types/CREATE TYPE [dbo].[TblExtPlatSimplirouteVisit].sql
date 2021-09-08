USE [DeliveryBackOffice]
GO

/****** Object:  UserDefinedTableType [dbo].[TblExtPlatSimplirouteVisit]    Script Date: 25/08/2021 8:40:10 ******/
CREATE TYPE [dbo].[TblExtPlatSimplirouteVisit] AS TABLE(
	[IdService] [int] NOT NULL,
	[GuideSerie] [nvarchar](2) NULL,
	[GuideNumber] [int] NULL,
	[TrackingData] [nvarchar](150) NULL,
	[Plan] [nvarchar](50) NULL,
	[Route] [nvarchar](50) NULL,
	[Order] [int] NULL,
	[Address] [nvarchar](200) NOT NULL,
	[Latitude] [decimal](18, 15) NOT NULL,
	[Longitude] [decimal](18, 15) NOT NULL,
	[vehicle] [nvarchar](50) NULL,
	[observation] [nvarchar](200) NULL,
	[IsIncluded] [bit] NOT NULL,
	[IsDelivery] [bit] NOT NULL,
	[ServiceStatus] [nvarchar](30) NULL,
	[EstimatedTimeArrival] [datetime] NULL
)
GO



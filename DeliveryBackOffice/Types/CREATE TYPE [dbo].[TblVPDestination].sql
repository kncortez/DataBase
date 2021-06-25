USE [DeliveryBackOffice]
GO

/****** Object:  UserDefinedTableType [dbo].[TblVPFrequentDestination]    Script Date: 6/4/2021 6:41:31 PM ******/
CREATE TYPE [dbo].[TblVPDestination] AS TABLE(
	[IdVPSource] [INT] NOT NULL,
	[IDVPDestiny] [INT] NOT NULL,
	[IsGuard] [BIT] NULL,
	[IsTransit] [BIT] NULL,
	[IsDefault] [BIT] NULL,
	[RowStatus] [BIT] NULL
)
GO



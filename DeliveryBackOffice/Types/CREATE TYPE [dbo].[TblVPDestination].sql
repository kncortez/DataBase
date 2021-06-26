USE [DeliveryBackOffice]
GO

/****** Object:  UserDefinedTableType [dbo].[TblVPDestination]    Script Date: 6/25/2021 6:40:26 PM ******/
CREATE TYPE [dbo].[TblVPDestination] AS TABLE(
	[IdVPSource] [INT] NOT NULL,
	[IDVPDestiny] [INT] NOT NULL,
	[IsGuard] [BIT] NULL,
	[IsTransit] [BIT] NULL,
	[IsDefault] [BIT] NULL,
	[RowStatus] [BIT] NULL
)
GO



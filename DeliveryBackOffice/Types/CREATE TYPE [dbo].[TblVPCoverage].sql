USE [DeliveryBackOffice]
GO

/****** Object:  UserDefinedTableType [dbo].[TblVPCoverage]    Script Date: 6/25/2021 6:38:10 PM ******/
CREATE TYPE [dbo].[TblVPCoverage] AS TABLE(
	[IdVpbySegment] [INT] NULL,
	[VisitPointId] [INT] NOT NULL,
	[HubLogisticId] [INT] NOT NULL,
	[SegmentId] [INT] NOT NULL,
	[RowStatus] [BIT] NOT NULL
)
GO



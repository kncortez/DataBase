USE [DeliveryBackOffice]
GO

/****** Object:  UserDefinedTableType [dbo].[TblVPItinerary]    Script Date: 6/25/2021 6:41:50 PM ******/
CREATE TYPE [dbo].[TblVPItinerary] AS TABLE(
	[IdVPItinerary] [BIGINT] NULL,
	[VPFrequencyID] [BIGINT] NULL,
	[DayOfVisit] [INT] NULL,
	[InitializationTimeOfVisit] [NVARCHAR](5) NULL,
	[FinalizationTimeOfVisit] [NVARCHAR](5) NULL,
	[OrderSequence] [INT] NULL,
	[RouteCodeID] [INT] NULL,
	[HubLogisticID] [INT] NULL,
	[RowStatus] [BIT] NULL
)
GO



-- ================================
-- Create User-defined Table Type
-- ================================
USE DeliveryBackOffice
GO

-- Create the data type
CREATE TYPE TblVPItinerary AS TABLE 
(
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

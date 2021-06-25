-- ================================
-- Create User-defined Table Type
-- ================================
USE DeliveryBackOffice
GO

-- Create the data type
CREATE TYPE TblVPCoverage AS TABLE 
(
	[IdVpbySegment] [INT] NULL,
	[VisitPointId] [INT] NOT NULL,
	[HubLogisticId] [INT] NOT NULL,
	[SegmentId] [INT] NOT NULL,
	[RowStatus] [BIT] NOT NULL
)
GO

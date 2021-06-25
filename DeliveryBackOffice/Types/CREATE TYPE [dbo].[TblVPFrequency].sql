-- ================================
-- Create User-defined Table Type
-- ================================
USE DeliveryBackOffice
GO

-- Create the data type
CREATE TYPE [dbo].[TblVPFrequency] AS TABLE 
(
	[IdVPFrequency] [BIGINT]  NULL,
	[VPConfigurationID] [BIGINT] NULL,
	[SeasonID] [INT] NULL,
	[VisitsOnSunday] [TINYINT] NULL,
	[VisitsOnMonday] [TINYINT] NULL,
	[VisitsOnTuesday] [TINYINT] NULL,
	[VisitsOnWednesday] [TINYINT] NULL,
	[VisitsOnThursday] [TINYINT] NULL,
	[VisitsOnFriday] [TINYINT] NULL,
	[VisitsOnSaturday] [TINYINT] NULL,
	[HubLogisticID] [INT] NULL,
	[RowStatus] [BIT] NULL
)
GO


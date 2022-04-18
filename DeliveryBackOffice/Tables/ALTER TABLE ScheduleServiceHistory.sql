ALTER TABLE dbo.ScheduleServiceHistory
ADD TimeSchedule VARCHAR(250) NULL
GO

ALTER TABLE dbo.ScheduleServiceHistory
ADD ServicesConfigId BIGINT NULL
GO

ALTER TABLE dbo.ScheduleServiceHistory
ADD LogType INT NULL
GO
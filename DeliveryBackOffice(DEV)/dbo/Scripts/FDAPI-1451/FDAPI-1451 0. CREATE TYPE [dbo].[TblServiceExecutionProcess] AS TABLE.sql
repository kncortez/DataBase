USE [DeliveryBackOffice]
GO

/****** Object:  UserDefinedTableType [dbo].[TblServiceExecutionProcess]    Script Date: 3/29/2023 10:20:56 ******/
CREATE TYPE [dbo].[TblServiceExecutionProcess] AS TABLE(
	[ServiceExecutionProcessId] [INT] NULL,
	[ServiceExecutionProcessName] [NVARCHAR](100) NULL,
	[ServiceExecutionProcessTime] [TIME](7) NULL,
	[ServiceExecutionProcessIsPending] [BIT] NULL,
	[ServiceExecutionProcessHasStarted] [BIT] NULL,
	[ServiceExecutionProcessHasCompleted] [BIT] NULL
)
GO



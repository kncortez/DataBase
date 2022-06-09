USE [DeliveryBackOffice]
GO


CREATE TYPE [dbo].[TblCoDExecutionProcess] AS TABLE(
	[CoDExecutionProcessId] [int] NULL,
	[CoDExecutionProcessName] [nvarchar](100) NULL,
	[CoDExecutionProcessTime] [time](7) NULL,
	[CoDExecutionProcessBankId] [int] NULL
)
GO



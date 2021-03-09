CREATE  TYPE  [dbo].[Type_WebhookTrackingQueue] AS TABLE(
	[Guide_Serie] [varchar](5) NULL,
	[Guide_Number] [bigint] NULL,
	[IdCustomer] [int],
	[Status] [int] NULL,
	[HasNotified] [bit] NULL
	)
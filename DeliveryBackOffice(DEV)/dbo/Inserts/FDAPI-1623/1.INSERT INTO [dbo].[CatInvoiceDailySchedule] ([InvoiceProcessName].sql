USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[CatInvoiceDailySchedule] ([InvoiceProcessName]
, [ExecutionTime]
, [ProcessPriority]
, [RowStatus]
, [TokenCreated]
, [DateCreated]
, [TokenUpdated]
, [DateUpdated])
	VALUES ('UpdateInvoiceProcessed', '00:00', 1, 1, 'SYS-OMORALES', GETDATE(), NULL, NULL)
GO

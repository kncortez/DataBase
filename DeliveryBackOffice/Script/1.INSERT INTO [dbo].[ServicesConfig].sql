USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[ServicesConfig] ([ServiceName]
, [ServiceProcess]
, [TimeSchedule]
, [RowStatus]
, [NotifyEmails]
, [TokenCreated]
, [DateCreated]
, [TokenUpdated]
, [DateUpdated])
	VALUES ('HermesWireTransfer', 'RECOLECTION', '14:10:00,22:10:00', 1, 'marco.jimenez@forzalatam.com', 'MJIMENEZ', GETDATE(), NULL, NULL)
GO




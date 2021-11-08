USE [DeliveryBackOffice]
GO

UPDATE [dbo].[ConfigParams]
   SET [Value] = '0.9.2.8-20211108'
 WHERE Name = 'PortalVersion'
GO
/*
   2024/11/14
   User: arecinos
   Server: 192.168.3.45
   Database: DeliveryBackOffice
   Application: 
*/

BEGIN TRANSACTION
GO
ALTER TABLE [DeliveryBackOffice].[dbo].[DeliveryOrder] ADD
	Changed_Tracking NVARCHAR(3) NULL
GO
COMMIT
USE [DeliveryBackOffice]
GO

ALTER TABLE [dbo].[DeliveryOrderBySettlement] ADD [User_Received_COD] [nvarchar](50) NULL
ALTER TABLE [dbo].[DeliveryOrderBySettlement] ADD [Date_Received_COD] [datetime] NULL
ALTER TABLE [dbo].[DeliveryOrderBySettlement] ADD [Guides_Received_COD] [smallint] NULL
ALTER TABLE [dbo].[DeliveryOrderBySettlement] ADD [Route_Received_COD] [datetime] NULL
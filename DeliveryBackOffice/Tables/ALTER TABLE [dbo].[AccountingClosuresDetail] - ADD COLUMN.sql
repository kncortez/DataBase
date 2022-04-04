USE [DeliveryBackOffice]
GO

ALTER TABLE [AccountingClosuresDetail]
ADD DopId BIGINT  NULL 
CONSTRAINT [ACD_DopId] DEFAULT NULL
GO

ALTER TABLE [dbo].[AccountingClosuresDetail]  WITH CHECK ADD FOREIGN KEY([DopId])
REFERENCES [dbo].[DeliveryOrderPaymentTransaction] ([DopId])
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'ID de la transacción que registra el pago de una  guía', N'SCHEMA', N'dbo', N'TABLE', N'AccountingClosuresDetail', N'COLUMN', N'DopId'
GO
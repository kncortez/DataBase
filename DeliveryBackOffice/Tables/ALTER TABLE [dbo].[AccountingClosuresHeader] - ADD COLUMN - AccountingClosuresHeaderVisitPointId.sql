USE [DeliveryBackOffice]
GO

ALTER TABLE [AccountingClosuresHeader]
ADD AccountingClosuresHeaderVisitPointId INT NULL 
CONSTRAINT [ACH_AccountClosuresHeaderVisitPointId] DEFAULT NULL
GO

ALTER TABLE [dbo].[AccountingClosuresHeader]  WITH CHECK ADD  CONSTRAINT [FK_AccountingClosuresHeader_AccountingClosuresHeaderVisitPoint] FOREIGN KEY([AccountingClosuresHeaderVisitPointId])
REFERENCES [dbo].[AccountingClosuresHeaderVisitPoint] ([IdAccountingClosuresHeaderVisitPoint])
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'ID del cierre de VisitPoint en el que se registró este cierre', N'SCHEMA', N'dbo', N'TABLE', N'AccountingClosuresHeader', N'COLUMN', N'AccountingClosuresHeaderVisitPointId'
GO
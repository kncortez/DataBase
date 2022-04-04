USE [DeliveryBackOffice]
GO

ALTER TABLE [AccountingClosuresHeader]
ADD IdAccountingClosuresHeaderVisitPoint INT NULL 
CONSTRAINT [ACH_IdAccountClosuresHeaderVisitPoint] DEFAULT 0
GO

ALTER TABLE [dbo].[AccountingClosuresHeader]  WITH CHECK ADD  CONSTRAINT [FK_AccountingClosuresHeader_AccountingClosuresHeaderVisitPoint] FOREIGN KEY([IdAccountingClosuresHeaderVisitPoint])
REFERENCES [dbo].[AccountingClosuresHeaderVisitPoint] ([IdAccountingClosuresHeaderVisitPoint])
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'ID del cierre de VisitPoint en el que se registró este cierre', N'SCHEMA', N'dbo', N'TABLE', N'AccountingClosuresHeader', N'COLUMN', N'IdAccountingClosuresHeaderVisitPoint'
GO
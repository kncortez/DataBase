USE [DeliveryBackOffice]
GO


CREATE TYPE [dbo].[TblPaymentList] AS TABLE(
	[RowNumber] [int] NOT NULL,
	[IdTypeOfMoney] [int] NULL,
	[Voucher] [varchar](100) NULL,
	[Amount] [decimal](18, 2) NULL
)
GO


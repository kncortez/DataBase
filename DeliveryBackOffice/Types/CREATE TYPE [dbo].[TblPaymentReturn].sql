USE [DeliveryBackOffice]
GO

/****** Object:  UserDefinedTableType [dbo].[TblPaymentType]    Script Date: 20/05/2021 15:24:57 ******/
CREATE TYPE [dbo].[TblPaymentReturn] AS TABLE(
	[RowNumber] [int] NOT NULL,
	[IdPayment] [int] NULL,
	[Amount] [decimal](14, 2) NULL,
	[Voucher] [nvarchar] (25) NULL
)
GO



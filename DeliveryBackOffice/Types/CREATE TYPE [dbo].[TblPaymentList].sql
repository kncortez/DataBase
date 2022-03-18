USE [DeliveryBackOffice]
GO

drop Procedure [dbo].[sps_proof_ondelivery_fd]
drop Procedure [dbo].[SetPaymentCost]
DROP TYPE [dbo].[TblPaymentList]

/****** Object:  UserDefinedTableType [dbo].[TblPaymentList]    Script Date: 15/04/2021 11:56:18 ******/
CREATE TYPE [dbo].[TblPaymentList] AS TABLE(
	[RowNumber] [int] NOT NULL,
	[IdTypeOfMoney] [int] NULL,
	[Voucher] [varchar](100) NULL,
	[Amount] [decimal](18, 2) NULL,
	[Responsible] [nvarchar] (100) null
)
GO


USE [DeliveryBackOffice]
GO

/****** Object:  UserDefinedTableType [dbo].[TblDeliveryOrdersList]    Script Date: 05/02/2021 16:55:30 ******/
CREATE TYPE [dbo].[TblDeliveryOrdersList] AS TABLE(
	[RowNumber] [int] NOT NULL,
	[Guide_Serie] [nvarchar](2) NULL,
	[Guide_Number] [int] NULL,
	[PriceShippment] [decimal](14, 2) NULL,
	[IdWayToPayment] [int] NULL,
	[IdTypePayment] [int] NULL,
	[IdTimePayment] [int] NULL,
	[IsCollect] [bit] NULL,
	[AmmountToPay] [decimal](14, 2) NULL
)
GO



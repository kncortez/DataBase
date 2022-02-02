USE [DeliveryBackOffice]
GO


/****** Object:  UserDefinedTableType [dbo].[TblDeliveryOrdersList]    Script Date: 13/01/2022 10:57:48 ******/
CREATE TYPE [dbo].[TblDeliveryOrdersList2] AS TABLE(
	[RowNumber] [int] NOT NULL,
	[Guide_Serie] [nvarchar](2) NULL,
	[Guide_Number] [int] NULL,
	[PriceShippment] [decimal](14, 2) NULL,
	[IdWayToPayment] [int] NULL,
	[IdTypePayment] [int] NULL,
	[IdTimePayment] [int] NULL,
	[IsCollect] [bit] NULL,
	[AmmountToPay] [decimal](14, 2) NULL,
	[PaymentRecollections] [decimal](14, 2) NULL,
	[PaymentNow] [decimal](14, 2) NULL,
	[PaymentDelivery] [decimal](14, 2) NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[ShipmentCompleted] [bit] NULL,
	[RecollectionCompleted] [bit] NULL,
	[PaidGuide] [bit] NULL,
	[TransaccionFAC] [varchar](100) NULL,
	[IdHeaderRecolection] [int] NULL,
	[IdTypeService] [int] NULL,
	[CODAmountProccess] [decimal](18, 2) NULL
)
GO




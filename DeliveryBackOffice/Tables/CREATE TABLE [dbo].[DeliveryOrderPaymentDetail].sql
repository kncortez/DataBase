USE [DeliveryBackOffice]
GO
/****** Object:  Table [dbo].[[DeliveryOrderPaymentDetail]]    Script Date: 1/23/2021 5:01:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DeliveryOrderPaymentDetail](
	DopId bigint IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[GuideNumber] [int]  NOT NULL,
	[GuideSerie] nvarchar(2) NULL,
	[PayTypeId] [int] NULL,
	[WayPayId] [int] NULL,
	[TimePlaId] [int] NULL,
	[amount] [decimal](18,2) NULL,
	[TokenCreated] [varchar](50) NULL,
	[DateCreated] [datetime]  NULL,
	[TokenUpdated] [varchar](50) NULL,
	[DateUpdated] [datetime] NULL
	,[PaymentRecollections] [decimal](18,2) NULL
	,[PaymentNow] [decimal](18,2) NULL
	,[PaymentDelivery] [decimal](18,2) NULL
	,[StartDate] [datetime]  NULL
	,[EndDate] [datetime]  NULL
	,[ShipmentCompleted] [bit] NULL
	,[RecollectionCompleted] [bit] NULL
	,[PaidGuide] [bit] NULL
	,[TransaccionFAC] [varchar](50) NULL
	,[IdHeaderRecolection] [int] NULL
	
	
	
	
)
ALTER TABLE [dbo].[DeliveryOrderPaid]  WITH CHECK ADD  CONSTRAINT [FK_PaidDeliveryOrder] FOREIGN KEY([Guide_Serie], [Guide_Number])
REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number])
GO

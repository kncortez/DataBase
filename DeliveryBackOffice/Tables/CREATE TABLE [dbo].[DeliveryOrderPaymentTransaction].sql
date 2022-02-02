USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[DeliveryOrderPaymentTransaction]    Script Date: 2/02/2022 16:20:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DeliveryOrderPaymentTransaction](
	[DopId] [bigint] IDENTITY(1,1) NOT NULL,
	[GuideNumber] [int] NULL,
	[GuideSerie] [nvarchar](2) NULL,
	[PayTypeId] [int] NULL,
	[TypeofInOutMoneyId] [int] NULL,
	[TimePlaId] [int] NULL,
	[amount] [decimal](18, 2) NULL,
	[TokenCreated] [varchar](50) NULL,
	[DateCreated] [datetime] NULL,
	[TokenUpdated] [varchar](50) NULL,
	[DateUpdated] [datetime] NULL,
	[PaymentRecollections] [decimal](18, 2) NULL,
	[PaymentNow] [decimal](18, 2) NULL,
	[PaymentDelivery] [decimal](18, 2) NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[ShipmentCompleted] [bit] NULL,
	[RecollectionCompleted] [bit] NULL,
	[PaidGuide] [bit] NULL,
	[TransaccionFAC] [nvarchar](100) NULL,
	[IdHeaderRecolection] [int] NULL,
	[RecolectNow] [decimal](18, 2) NULL,
	[RecolectDelivery] [decimal](18, 2) NULL,
	[RecolectPayment] [decimal](18, 2) NULL,
	[TypeServiceId] [int] NULL,
	[AccountId] [bigint] NULL,
	[CODAmountProcess] [decimal](18, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[DopId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[DeliveryOrderPaymentTransaction]  WITH CHECK ADD  CONSTRAINT [FK_Account] FOREIGN KEY([AccountId])
REFERENCES [dbo].[Account] ([AccIdAccount])
GO

ALTER TABLE [dbo].[DeliveryOrderPaymentTransaction] CHECK CONSTRAINT [FK_Account]
GO

ALTER TABLE [dbo].[DeliveryOrderPaymentTransaction]  WITH CHECK ADD  CONSTRAINT [FK_CatTypeServiceClosure] FOREIGN KEY([TypeServiceId])
REFERENCES [dbo].[CatTypeServiceClosure] ([IdTypeService])
GO

ALTER TABLE [dbo].[DeliveryOrderPaymentTransaction] CHECK CONSTRAINT [FK_CatTypeServiceClosure]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID del tipo de servicio de tabla CatTypeServiceClosure' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DeliveryOrderPaymentTransaction', @level2type=N'COLUMN',@level2name=N'TypeServiceId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de la cuenta del usuario' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DeliveryOrderPaymentTransaction', @level2type=N'COLUMN',@level2name=N'AccountId'
GO



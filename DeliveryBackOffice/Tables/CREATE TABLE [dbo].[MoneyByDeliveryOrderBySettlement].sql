USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[MoneyByDeliveryOrderBySettlement]    Script Date: 26/11/2021 15:21:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[MoneyByDeliveryOrderBySettlement](
	[CatMoneyId] [int] NOT NULL,
	[DeliveryOrderBySettlementId] [bigint] NOT NULL,
	[Quantity] [int] NOT NULL,
 CONSTRAINT [PK_MoneyByDeliveryOrderBySettlement_CatMoneyId_DeliveryOrderBySettlementId] PRIMARY KEY CLUSTERED 
(
	[CatMoneyId] ASC,
	[DeliveryOrderBySettlementId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[MoneyByDeliveryOrderBySettlement]  WITH CHECK ADD  CONSTRAINT [FK_MoneyByDeliveryOrderBySettlement_CatMoneyId] FOREIGN KEY([CatMoneyId])
REFERENCES [dbo].[CatMoney] ([IdCatMoney])
GO

ALTER TABLE [dbo].[MoneyByDeliveryOrderBySettlement] CHECK CONSTRAINT [FK_MoneyByDeliveryOrderBySettlement_CatMoneyId]
GO

ALTER TABLE [dbo].[MoneyByDeliveryOrderBySettlement]  WITH CHECK ADD  CONSTRAINT [FK_MoneyByDeliveryOrderBySettlement_DeliveryOrderBySettlementId] FOREIGN KEY([DeliveryOrderBySettlementId])
REFERENCES [dbo].[DeliveryOrderBySettlement] ([ID])
GO

ALTER TABLE [dbo].[MoneyByDeliveryOrderBySettlement] CHECK CONSTRAINT [FK_MoneyByDeliveryOrderBySettlement_DeliveryOrderBySettlementId]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de la tabla CatMoney, que indica el id de la denominación.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MoneyByDeliveryOrderBySettlement', @level2type=N'COLUMN',@level2name=N'CatMoneyId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de la tabla DeliveryOrderBySettlement, que indica el id del manifiesto.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MoneyByDeliveryOrderBySettlement', @level2type=N'COLUMN',@level2name=N'DeliveryOrderBySettlementId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cantidad de la denominación.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MoneyByDeliveryOrderBySettlement', @level2type=N'COLUMN',@level2name=N'Quantity'
GO



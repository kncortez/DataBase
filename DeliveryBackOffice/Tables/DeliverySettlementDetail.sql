USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[DeliverySettlementDetail]    Script Date: 16/09/2020 16:40:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DeliverySettlementDetail](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ID_DeliveryOrderBySettlement] [bigint] NOT NULL,
	[Guide_Serie] [nvarchar](2) NOT NULL,
	[Guide_Number] [int] NOT NULL
) ON [PRIMARY]
GO

--ALTER TABLE DeliverySettlementDetail ADD [Serie_DeliveryOrderBySettlement] nvarchar(2) NOT NULL

--ALTER TABLE DeliverySettlementDetail DROP CONSTRAINT [FK_DeliverySettlementDetail_DeliveryOrderBySettlement]
--ALTER TABLE DeliverySettlementDetail DROP CONSTRAINT FK_DeliverySettlementDetail_DeliveryOrderBySettlement
--ALTER TABLE DeliverySettlementDetail DROP column Serie_DeliveryOrderBySettlement

ALTER TABLE DeliverySettlementDetail ADD CONSTRAINT [FK_DeliverySettlementDetail_DeliveryOrder] FOREIGN KEY([Guide_Serie], [Guide_Number])
REFERENCES DeliveryOrder ([Guide_Serie], [Guide_Number])

ALTER TABLE DeliverySettlementDetail ADD CONSTRAINT [FK_DeliverySettlementDetail_DeliveryOrderBySettlement] FOREIGN KEY ([ID_DeliveryOrderBySettlement])
REFERENCES DeliveryOrderBySettlement ([ID])

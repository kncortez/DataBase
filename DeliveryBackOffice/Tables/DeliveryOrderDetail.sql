USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[DeliveryOrderDetail]    Script Date: 25/06/2020 18:18:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DeliveryOrderDetail](
	[Guide_Serie] [nvarchar](2) NOT NULL,
	[Guide_Number] [int] NOT NULL,
	[StatusOrderId] [tinyint] NOT NULL,
	[UserCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[DateCreatedInSystem] [datetime] NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[DeliveryOrderDetail]  WITH CHECK ADD  CONSTRAINT [FK_DeliveryOrderDetail_DeliveryOrder] FOREIGN KEY([Guide_Serie], [Guide_Number])
REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number])
GO

ALTER TABLE [dbo].[DeliveryOrderDetail] CHECK CONSTRAINT [FK_DeliveryOrderDetail_DeliveryOrder]
GO

ALTER TABLE [dbo].[DeliveryOrderDetail]  WITH CHECK ADD  CONSTRAINT [FK_DeliveryOrderDetail_StatusOrder] FOREIGN KEY([StatusOrderId])
REFERENCES [dbo].[StatusOrder] ([StatusOrderId])
GO

ALTER TABLE [dbo].[DeliveryOrderDetail] CHECK CONSTRAINT [FK_DeliveryOrderDetail_StatusOrder]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripción de status order' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DeliveryOrderDetail', @level2type=N'COLUMN',@level2name=N'Guide_Serie'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripción de status order' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DeliveryOrderDetail', @level2type=N'COLUMN',@level2name=N'Guide_Number'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripción de status order' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DeliveryOrderDetail', @level2type=N'COLUMN',@level2name=N'StatusOrderId'
GO



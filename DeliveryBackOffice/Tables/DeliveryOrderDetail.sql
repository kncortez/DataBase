USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[DeliveryOrderDetail]    Script Date: 3/06/2020 16:53:46 ******/
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
 CONSTRAINT [PK_DeliveryOrderDetail] PRIMARY KEY CLUSTERED 
(
	[Guide_Serie] ASC,
	[Guide_Number] ASC,
	[StatusOrderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
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



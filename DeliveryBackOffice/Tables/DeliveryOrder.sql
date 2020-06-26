USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[DeliveryOrder]    Script Date: 25/06/2020 18:17:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DeliveryOrder](
	[Ticket_Number] [nvarchar](150) NULL,
	[Order_Number] [int] NULL,
	[Preparation_Date] [datetime] NULL,
	[Shipping_Date] [datetime] NULL,
	[Pieces_Dry] [int] NULL,
	[Pieces_Cold] [int] NULL,
	[Consolidated_Number] [int] NULL,
	[Recipe_Number] [nvarchar](1000) NULL,
	[Sender_ID] [int] NULL,
	[Sender_FirstName] [nvarchar](100) NULL,
	[Sender_LastName] [nvarchar](100) NULL,
	[Sender_Address] [nvarchar](200) NULL,
	[Sender_Zone] [nvarchar](100) NULL,
	[Sender_Town] [nvarchar](100) NULL,
	[Sender_Department] [nvarchar](100) NULL,
	[Sender_Phone] [nvarchar](50) NULL,
	[Receiver_ID] [int] NULL,
	[Receiver_FirstName] [nvarchar](100) NULL,
	[Receiver_LastName] [nvarchar](100) NULL,
	[Receiver_Address] [nvarchar](200) NULL,
	[Receiver_Zone] [nvarchar](100) NULL,
	[Receiver_Town] [nvarchar](100) NULL,
	[Receiver_Department] [nvarchar](100) NULL,
	[Receiver_Phone] [nvarchar](100) NULL,
	[Receiver_Email] [nvarchar](200) NULL,
	[Receiver_SocialSecurity_ID] [nvarchar](200) NULL,
	[Receiver_Alternant_ID] [int] NULL,
	[Receiver_Alternant_FullName] [nvarchar](200) NULL,
	[Receiver_Alternant_Address] [nvarchar](200) NULL,
	[Receiver_Alternant_Zone] [nvarchar](100) NULL,
	[Receiver_Alternant_Town] [nvarchar](100) NULL,
	[Receiver_Alternant_Department] [nvarchar](100) NULL,
	[Receiver_Alternant_Phone] [nvarchar](100) NULL,
	[Receiver_Alternant_Email] [nvarchar](200) NULL,
	[Receiver_Alternant_SocialSecurity_ID] [nvarchar](200) NULL,
	[Delivery_Max_Date] [datetime] NULL,
	[printedStatus] [tinyint] NULL,
	[Guide_Serie] [nvarchar](2) NOT NULL,
	[Guide_Number] [int] NOT NULL,
	[Manifest_Serie] [nvarchar](2) NOT NULL,
	[Manifest_Number] [int] NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[StatusOrderId] [tinyint] NOT NULL,
	[Receiver_CUI] [nvarchar](25) NULL,
	[Package_Description] [nvarchar](200) NULL,
	[Sender_Internal_Code] [nvarchar](50) NULL,
	[Receiver_Alternant_CUI] [nvarchar](25) NULL,
	[Courier_Route] [nvarchar](50) NULL,
	[Courier_Name] [nvarchar](200) NULL,
	[Courier_Vehicle_Plate] [nvarchar](15) NULL,
	[Dispatched_Date] [datetime] NULL,
	[Dispatched_Token] [nvarchar](50) NULL,
	[NameOfReceiver] [nvarchar](200) NULL,
	[Package_Type] [tinyint] NULL,
 CONSTRAINT [pk_primary_key_delivery_order] PRIMARY KEY CLUSTERED 
(
	[Guide_Serie] ASC,
	[Guide_Number] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[DeliveryOrder]  WITH CHECK ADD  CONSTRAINT [FK_DeliveryOrder_ServiceRequest] FOREIGN KEY([Manifest_Serie], [Manifest_Number])
REFERENCES [dbo].[ServiceRequest] ([Manifest_Serie], [Manifest_Number])
GO

ALTER TABLE [dbo].[DeliveryOrder] CHECK CONSTRAINT [FK_DeliveryOrder_ServiceRequest]
GO

ALTER TABLE [dbo].[DeliveryOrder]  WITH CHECK ADD  CONSTRAINT [FK_DeliveryOrder_StatusOrder] FOREIGN KEY([StatusOrderId])
REFERENCES [dbo].[StatusOrder] ([StatusOrderId])
GO

ALTER TABLE [dbo].[DeliveryOrder] CHECK CONSTRAINT [FK_DeliveryOrder_StatusOrder]
GO

ALTER TABLE [dbo].[DeliveryOrder]  WITH CHECK ADD  CONSTRAINT [FK_DeliveryOrder_VisitPointClient] FOREIGN KEY([Sender_ID])
REFERENCES [dbo].[VisitPointClient] ([CodeOfReference])
GO

ALTER TABLE [dbo].[DeliveryOrder] CHECK CONSTRAINT [FK_DeliveryOrder_VisitPointClient]
GO

ALTER TABLE [dbo].[DeliveryOrder]  WITH CHECK ADD  CONSTRAINT [FK_DeliveryOrder_VisitPointClient1] FOREIGN KEY([Receiver_ID])
REFERENCES [dbo].[VisitPointClient] ([CodeOfReference])
GO

ALTER TABLE [dbo].[DeliveryOrder] CHECK CONSTRAINT [FK_DeliveryOrder_VisitPointClient1]
GO

ALTER TABLE [dbo].[DeliveryOrder]  WITH CHECK ADD  CONSTRAINT [FK_PackageType] FOREIGN KEY([Package_Type])
REFERENCES [dbo].[Package] ([Package_Type])
GO

ALTER TABLE [dbo].[DeliveryOrder] CHECK CONSTRAINT [FK_PackageType]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha máximo de servicio' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DeliveryOrder', @level2type=N'COLUMN',@level2name=N'Delivery_Max_Date'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 Impreso, 2 Reimpreso' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DeliveryOrder', @level2type=N'COLUMN',@level2name=N'printedStatus'
GO



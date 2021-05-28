USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[WebhookRestrinctionByUser]    Script Date: 27/05/2021 16:42:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[WebhookRestrinctionByUser](
	[WebhookRestrinctionByUserId] [int] IDENTITY(1,1) NOT NULL,
	[IdCustomer] [int] NOT NULL,
	[IdEcommerce] [int]  NULL,
	[WebhookTypeId] [int] NOT NULL,
	[Name] [varchar](250) NOT NULL,
	[Description] [nvarchar](500) NOT NULL,
	[StatusOrderId] [nvarchar](max) NOT NULL,
	[StatusInternalName] [nvarchar](max)  NULL,
	[StatusExternalName] [nvarchar](max)  NULL,
	[StatusRow] [int] NOT NULL,
	[CreatedToken] [nvarchar](max) NULL,
	[CreatedDate] [datetime]  NULL,
	[UpdatedToken] [nvarchar](max) NULL,
	[UpdatedDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[WebhookRestrinctionByUserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[WebhookRestrinctionByUser]  WITH NOCHECK ADD  CONSTRAINT [FK_WebhookRestrinctionByUser_IdCustomer] FOREIGN KEY([IdCustomer])
REFERENCES [dbo].[Customer] ([IdCustomer])
GO

ALTER TABLE [dbo].[WebhookRestrinctionByUser] CHECK CONSTRAINT [FK_WebhookRestrinctionByUser_IdCustomer]
GO

ALTER TABLE [dbo].[WebhookRestrinctionByUser]  WITH NOCHECK ADD  CONSTRAINT [FK_WebhookRestrinctionByUser_WebhookTypeId] FOREIGN KEY([WebhookTypeId])
REFERENCES [dbo].[WebhookType] ([WebhookTypeId])
GO

ALTER TABLE [dbo].[WebhookRestrinctionByUser] CHECK CONSTRAINT [FK_WebhookRestrinctionByUser_WebhookTypeId]
GO



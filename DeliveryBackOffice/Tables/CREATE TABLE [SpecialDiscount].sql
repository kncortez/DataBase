USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[SpetialDiscount]    Script Date: 21/07/2020 22:13:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SpecialDiscount](
	[IdSpecialDiscount] [int] IDENTITY(1,1) NOT NULL,
	[DiscountName] [nvarchar](50) NULL,
	[PercentValue] [decimal](18, 2) NULL,
	[SpecialDiscountStatus] [bit] NULL,
	[DateExpire] [datetime] NULL,
	[IdCustomer] [int] NULL,
	[TokenCreated] [nvarchar](50) NULL,
	[DateCreated] datetime NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] datetime NULL
 CONSTRAINT [PK_SpecialDiscount] PRIMARY KEY CLUSTERED 
(
	[IdSpecialDiscount] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[SpecialDiscount]  WITH CHECK ADD  CONSTRAINT [FK_SpecialDiscount_Customer] FOREIGN KEY([IdCustomer])
REFERENCES [dbo].[Customer] ([IdCustomer])
GO

ALTER TABLE [dbo].[SpecialDiscount] CHECK CONSTRAINT [FK_SpecialDiscount_Customer]
GO



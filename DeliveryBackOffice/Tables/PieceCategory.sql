USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[PieceCategory]    Script Date: 15/12/2020 12:09:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PieceCategory](
	[Category_Id] [smallint] IDENTITY(1,1) NOT NULL,
	[Category_Name] [nvarchar](100) NOT NULL,
	[Customer_Id] [int] NOT NULL,
 CONSTRAINT [PK_PackageCategory] PRIMARY KEY CLUSTERED 
(
	[Category_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[PieceCategory]  WITH CHECK ADD  CONSTRAINT [FK_Customer_PieceCategory] FOREIGN KEY([Customer_Id])
REFERENCES [dbo].[Customer] ([IdCustomer])
GO

ALTER TABLE [dbo].[PieceCategory] CHECK CONSTRAINT [FK_Customer_PieceCategory]
GO



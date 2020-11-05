USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[EcommerceBySeller]    Script Date: 11/3/2020 8:05:27 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[EcommerceBySeller](
	[IdAssigment] [int] IDENTITY(1,1) NOT NULL,
	[IdCommerce] [int] NOT NULL,
	[IdSeller] [int] NOT NULL,
	[StatusAssignment] [bit] NOT NULL,
	[DateCreated] [datetime] NOT NULL,
 CONSTRAINT [PK_EcommerceBySeller] PRIMARY KEY CLUSTERED 
(
	[IdAssigment] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[EcommerceBySeller]  WITH CHECK ADD  CONSTRAINT [FK_EcommerceBySeller] FOREIGN KEY([IdCommerce])
REFERENCES [dbo].[Ecommerce] ([IdEcommerce])
GO

ALTER TABLE [dbo].[EcommerceBySeller] CHECK CONSTRAINT [FK_EcommerceBySeller]
GO

ALTER TABLE [dbo].[EcommerceBySeller]  WITH CHECK ADD  CONSTRAINT [FK_EcommerceBySeller_2] FOREIGN KEY([IdSeller])
REFERENCES [dbo].[Seller] ([IdSeller])
GO

ALTER TABLE [dbo].[EcommerceBySeller] CHECK CONSTRAINT [FK_EcommerceBySeller_2]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de asignación de sellers a ecommerce' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EcommerceBySeller', @level2type=N'COLUMN',@level2name=N'IdAssigment'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de ecommerce' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EcommerceBySeller', @level2type=N'COLUMN',@level2name=N'IdCommerce'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de seller' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EcommerceBySeller', @level2type=N'COLUMN',@level2name=N'IdSeller'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado de asignación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EcommerceBySeller', @level2type=N'COLUMN',@level2name=N'StatusAssignment'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EcommerceBySeller', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO



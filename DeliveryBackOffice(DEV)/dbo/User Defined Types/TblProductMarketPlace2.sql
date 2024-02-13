USE [DeliveryBackOffice]
GO

/****** Object:  UserDefinedTableType [dbo].[TblProductMarketPlace2]    Script Date: 13/02/2024 16:55:17 ******/
CREATE TYPE [dbo].[TblProductMarketPlace2] AS TABLE(
	[IsGift] [bit] NOT NULL,
	[ProductGiftShippingEmail] [nvarchar](100) NOT NULL,
	[IdCatProduct] [int] NOT NULL,
	[TypeSalePackage] [nvarchar](25) NOT NULL
)
GO



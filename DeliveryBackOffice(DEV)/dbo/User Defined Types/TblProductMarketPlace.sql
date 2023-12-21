USE [DeliveryBackOffice]
GO

/****** Object:  UserDefinedTableType [dbo].[TblSalePackageMarketPlace]    Script Date: 11/12/2023 19:19:19 ******/
CREATE TYPE [dbo].[TblProductMarketPlace] AS TABLE(
    [IsGift] [bit] NOT NULL,
	[ProductGiftShippingEmail] [nvarchar](100) NOT NULL,
	[IdCatProduct] [int] NOT NULL
	
)
GO






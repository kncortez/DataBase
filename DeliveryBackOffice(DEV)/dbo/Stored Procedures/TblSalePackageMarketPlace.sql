USE [DeliveryBackOffice]
GO

/****** Object:  UserDefinedTableType [dbo].[TblGuides]    Script Date: 6/12/2023 20:02:14 ******/
CREATE TYPE [dbo].[TblSalePackageMarketPlace] AS TABLE(
	[TypeSalePackage] [NVARCHAR](25) NOT NULL,
	[IdSalePackage] [int] NOT NULL

	
)
GO



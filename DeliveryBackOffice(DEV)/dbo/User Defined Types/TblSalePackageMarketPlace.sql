USE [DeliveryBackOffice]
GO

/****** Object:  UserDefinedTableType [dbo].[TblSalePackageMarketPlace]    Script Date: 20/12/2023 23:25:36 ******/
CREATE TYPE [dbo].[TblSalePackageMarketPlace] AS TABLE(
	[TypeSalePackage] [nvarchar](25) NOT NULL,
	[IdSalePackage] [int] NOT NULL
)
GO



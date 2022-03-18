USE [DeliveryBackOffice]
GO

/****** Object:  UserDefinedTableType [dbo].[TblGuidePrice]    Script Date: 3/17/2022 10:25:54 PM ******/
CREATE TYPE [dbo].[TblGuidePrice] AS TABLE(
	[GuideSerie] [nvarchar](2) NOT NULL,
	[GuideNumber] [int] NOT NULL,
	[GuidePrice] [decimal](12, 2) NOT NULL
)
GO



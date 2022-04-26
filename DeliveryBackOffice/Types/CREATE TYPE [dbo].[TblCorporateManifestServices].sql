USE [DeliveryBackOffice]
GO

/****** Object:  UserDefinedTableType [dbo].[TblCorporateManifestServices]    Script Date: 25/04/2022 10:12:07 ******/
CREATE TYPE [dbo].[TblCorporateManifestServices] AS TABLE(
	[GuideSerie] [nvarchar](10) NOT NULL,
	[GuideNumber] [int] NOT NULL,
	[ManifestSerie] [nvarchar](10) NOT NULL,
	[ManifestNumber] [int] NOT NULL
)
GO



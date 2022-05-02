USE [DeliveryBackOffice]
GO

/****** Object:  UserDefinedTableType [dbo].[TblLocationReview]    Script Date: 3/11/2022 3:00:59 PM ******/
CREATE TYPE [dbo].[TblLocationReview] AS TABLE(
	[LocationSocialSecurity] [nvarchar](200) NULL,
	[LocationPhone] [nvarchar](10) NULL,
	[LocationAddress] [nvarchar](600) NULL,
	[LocationAccuracy] [nvarchar](20) NULL,
	[LocationLatitude] [nvarchar](20) NULL,
	[LocationLongitude] [nvarchar](20) NULL,
	[IsUpdateCandidate] [bit] NULL
)
GO



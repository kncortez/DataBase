USE [DeliveryBackOffice]
GO

CREATE TYPE [dbo].[TblLocationReview] AS TABLE(
	[LocationSocialSecurity] NVARCHAR(200) NULL,
	[LocationPhone] NVARCHAR(10) NULL,
	[LocationAddress] NVARCHAR(600) NULL,
	[LocationAccuracy] NVARCHAR(20) NULL,
	[LocationLatitude] NVARCHAR(20) NULL,
	[LocationLongitude] NVARCHAR(20) NULL

)
GO



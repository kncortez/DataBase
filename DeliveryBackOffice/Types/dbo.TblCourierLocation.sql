USE [DeliveryBackOffice]
GO

/****** Object:  UserDefinedTableType [dbo].[TblCourierLocation]    Script Date: 4/18/2022 16:02:13 ******/
CREATE TYPE [dbo].[TblCourierLocation] AS TABLE(
	[CourierPhone] [nvarchar](10) NOT NULL,
	[CourierLatitude] [nvarchar](20) NOT NULL,
	[CourierLongitude] [nvarchar](20) NOT NULL,
	[VehicleType] [int] NULL,
	[VehicleTypeDescription] [nvarchar](50) NULL
)
GO



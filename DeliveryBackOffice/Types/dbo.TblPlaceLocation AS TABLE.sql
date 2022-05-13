USE [DeliveryBackOffice]
GO

/****** Object:  UserDefinedTableType [dbo].[TblPlaceLocation]    Script Date: 5/12/2022 17:20:12 ******/
CREATE TYPE [dbo].[TblPlaceLocation] AS TABLE(
	[PlaceName] [nvarchar](50) NULL,
	[PlaceNameExtended] [nvarchar](100) NULL,
	[PlaceIdentifier] [int] NULL,
	[PlaceIdentifierExtended] [bigint] NULL,
	[PlaceLatitude] [nvarchar](20) NOT NULL,
	[PlaceLongitude] [nvarchar](20) NOT NULL
)
GO



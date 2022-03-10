USE [DeliveryBackOffice]
GO

/****** Object:  UserDefinedTableType [dbo].[TblExtPlatNumericParameterList]    Script Date: 3/9/2022 4:18:35 PM ******/
CREATE TYPE [dbo].[TblTownshipZone] AS TABLE(
	[Township] [int] NULL,
	[Zone] [nvarchar](2) NULL
)
GO



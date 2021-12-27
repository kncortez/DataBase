USE [DeliveryBackOffice]
GO

/****** Object:  UserDefinedTableType [dbo].[TblGuides]    Script Date: 27/12/2021 15:55:30 ******/
CREATE TYPE [dbo].[TblGuides] AS TABLE(
	[Guide_Serie] [nvarchar](2) NOT NULL,
	[Guide_Number] [int] NOT NULL
)
GO



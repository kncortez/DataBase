USE [DeliveryBackOffice]
GO

/****** Object:  UserDefinedTableType [dbo].[TblOrderGuides]    Script Date: 11/07/2021 18:48:00 ******/
CREATE TYPE [dbo].[TblOrderGuides] AS TABLE(
	[RowNumber] [int] NOT NULL,
	[Guide_Serie] [nvarchar](2) NULL,
	[Guide_Number] [int] NULL
)
GO



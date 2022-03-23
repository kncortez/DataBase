USE [DeliveryBackOffice]
GO

/****** Object:  UserDefinedTableType [dbo].[TblGuidesCancel]    Script Date: 20/12/2021 19:52:21 ******/
CREATE TYPE [dbo].[TblGuidesCancel] AS TABLE(
	[Guide_Serie] [varchar](2) NULL,
	[Guide_Number] [int] NULL
)
GO



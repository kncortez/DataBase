USE [DeliveryBackOffice]
GO

/****** Object:  UserDefinedTableType [dbo].[TblDeliveryOrdersList]    Script Date: 18/05/2021 15:04:52 ******/
CREATE TYPE [dbo].[TblGuidesReturns] AS TABLE(
	[RowNumber] [int] NOT NULL,
	[Serie] [nvarchar](25) NULL,
	[NumberGuide] [nvarchar](25) NULL,
	[NoPiece] [int] null,
	[State] [int] NULL
)
GO



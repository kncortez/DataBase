USE [DeliveryBackOffice]
GO

/****** Object:  UserDefinedTableType [dbo].[TblChangeList]    Script Date: 4/03/2021 09:12:52 ******/
CREATE TYPE [dbo].[TblChangeList] AS TABLE(
	[RowNumber] [int] NOT NULL,
	[IdCost] [int] NULL,
	[Description] [varchar](100) NULL,
	[Amount] [decimal](18, 2) NULL,
	[ModIdModule] [int] NULL,
	[RowStatus] [bit] NULL,
	[TokenCreated] [varchar](50) NULL
)
GO


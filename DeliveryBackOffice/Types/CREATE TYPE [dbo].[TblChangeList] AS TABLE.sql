USE [DeliveryBackOffice]
GO

/****** Object:  UserDefinedTableType [dbo].[TblIncidenceLink]    Script Date: 26/02/2021 15:24:50 ******/
CREATE TYPE [dbo].[TblChangeList] AS TABLE(
	[RowNumber] [int] NOT NULL,
	[IdCost] [int] NULL,
	[Description] [varchar](100) NULL,
	[Amount] [decimal] (18,2) NULL,
	[ModIdModule] [int] NULL,
	[RowStatus] [bit] NULL,
	[TokenCreated] [varchar](50) NULL
)
GO



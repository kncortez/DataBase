USE [DeliveryBackOffice]
GO

/****** Object:  UserDefinedTableType [dbo].[TblDeliveryOrdersList]    Script Date: 24/02/2021 16:17:12 ******/
CREATE TYPE [dbo].[TblIncidenceLink] AS TABLE(
	[RowNumber] [int] NOT NULL,
	[IncidenceId] [int] NULL,
	[PathIncidence] [varchar](200) NULL,
	[RowStatus] [bit] NULL,
	[TokenCreated] [varchar] (150) NULL,
	[DateCreated] [datetime] NULL,
	[TokenUpdated] [varchar] (150) NULL,
	[DateUpdated] [datetime] NULL
	
)
GO
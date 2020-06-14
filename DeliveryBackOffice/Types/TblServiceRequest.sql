USE [DeliveryBackOffice]
GO

/****** Object:  UserDefinedTableType [dbo].[TblServiceRequest]    Script Date: 3/06/2020 17:03:30 ******/
CREATE TYPE [dbo].[TblServiceRequest] AS TABLE(
	[RowNumber] [int] NOT NULL,
	[Messageid] [nvarchar](max) NULL,
	[Receiver_Name] [nvarchar](100) NULL,
	[Receiver_Email] [nvarchar](200) NOT NULL,
	[PathReceivedFile] [nvarchar](100) NULL,
	[PathSticker] [nvarchar](100) NULL,
	[Status] [nvarchar](50) NOT NULL,
	[Receiver_Date] [datetime] NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[CustomerID] [int] NOT NULL
)
GO



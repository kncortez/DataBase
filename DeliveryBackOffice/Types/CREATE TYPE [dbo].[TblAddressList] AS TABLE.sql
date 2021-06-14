USE [DeliveryBackOffice]
GO

--drop  TYPE [dbo].[TblAddressList]

/****** Object:  UserDefinedTableType [dbo].[TblAddressList]    Script Date: 11/06/2021 16:59:30 ******/
CREATE TYPE [dbo].[TblAddressList] AS TABLE(
	[RowNumber] [int] NOT NULL,
	[IdAddress] [int] NULL,
	[IdTownship] [int] NULL,
	[IdAccount] [int] NULL,
	[IdCountry] [nvarchar](5) NULL,
	[FullName] [nvarchar](150) NULL,
	[Address1] [nvarchar](600) NULL,
	[Address2] [nvarchar](600) NULL,
	[NirPhone] [nvarchar](10) NULL,
	[Phone] [nvarchar](20) NULL,
	[AdditionalInstructions] [nvarchar](200) NULL,
	[Status] [int] NULL,
	[Token] [nvarchar](200) NULL,
	[IdVisitPointByClientPortfolio] [int] NULL
)
GO



USE [DeliveryBackOffice]
GO

/****** Object:  UserDefinedTableType [dbo].[TblAddressList]    Script Date: 9/1/2021 12:53:16 PM ******/
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
	[IdVisitPointByClientPortfolio] [int] NULL,
	[IdSettlement] [int] NULL,
	[IdDeliveryOption] [int] NULL
)
GO



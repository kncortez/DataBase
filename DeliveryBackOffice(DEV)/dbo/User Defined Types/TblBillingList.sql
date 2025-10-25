CREATE TYPE [dbo].[TblBillingList] AS TABLE(
	[RowNumber] [int] NOT NULL,
	[IdBilling] [int] NULL,
	[IdAccount] [int] NULL,
	[Name] [nvarchar](100) NULL,
	[Address] [nvarchar](600) NULL,
	[TaxId] [nvarchar](100) NULL,
	[NRC] [nvarchar](200) NULL,
	[TypeIdentificationDocumentCode] [nvarchar](100) NULL,
	[IdDocument] [nvarchar](20) NULL,
	[DistrictId] [int] NULL,
	[StateId] [int] NULL,
	[ActivityCode] [nvarchar](100) NULL,
	[Inv_type] [int] NULL,
	[Status] [int] NULL,
	[Token] [nvarchar](150) NULL,
	[IdVisitPointByClientPortfolio] [int] NULL
);
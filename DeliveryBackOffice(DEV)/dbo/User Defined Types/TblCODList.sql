CREATE TYPE [dbo].[TblCODList] AS TABLE(
	[RowNumber] [int] NOT NULL,
	[Id] [int] NULL,
	[IdAccount] [int] NULL,
	[IdBank] [int] NULL,
	[NameAccount] [nvarchar](200) NULL,
	[TypeAccount] [nvarchar](10) NULL,
	[DocID] [nvarchar](20) NULL,
	[Alias] [nvarchar](100) NULL,
	[Token] [nvarchar](100) NULL,
	[TokenUpdate] [nvarchar](100) NULL,
	[NumberAcc] [nvarchar](100) NULL,
	[Status] [int] NULL,
	[IdVisitPointByClientPortfolio] [int] NULL
);
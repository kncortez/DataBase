CREATE TYPE [dbo].[TblPayment] AS TABLE(
	[RowNumber] [int] NOT NULL,
	[IdTypePay] [int] NULL,
	[Voucher] [varchar](100) NULL,
	[ServiceAmount] [decimal](18, 2) NULL,
	[CODAmount] [decimal](18, 2) NULL
)

CREATE TYPE [dbo].[TblListGuides] AS TABLE(
	[Guide_Serie] [varchar](2) NULL,
	[Guide_Number] [int] NULL,
	[ExcludeCOD] [bit] NULL
)


CREATE TYPE [dbo].[TblExclusions] AS TABLE(
	[Voucher] [varchar](100) NULL,
	[Responsible] [nvarchar](100) NULL
)


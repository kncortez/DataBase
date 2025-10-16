CREATE TYPE [dbo].[TblResponseCreditNoteSV] AS TABLE
(
	[InvoiceId]			bigint	NULL,
	[NumberFel]			nvarchar (100) NULL,
	[CertificationFel]	nvarchar (100) NULL,
	[Serial]			nvarchar (100) NULL,
	[ResponesJson]		nvarchar (MAX) NULL,
	[IssueDate]			nvarchar (100) NULL
)

CREATE TYPE [dbo].[TblProductWithoutLogin] AS TABLE(
	[Id]			int				NULL,
	[Name]			nvarchar(200)	NULL,
	[Description]	nvarchar(200)	NULL,
	[Quantity]		int				NULL,
	[Price]			Decimal(14,2)	NULL
)
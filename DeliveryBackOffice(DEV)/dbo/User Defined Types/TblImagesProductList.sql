CREATE TYPE [dbo].[TblImagesProductList] AS TABLE
(
    [IdProductImages]	INT				NULL,
    [ProductId]			INT				NULL,
    [Url]				NVARCHAR (600)  NULL,
    [Position]			INT				NULL,
	[StrImage]			NVARCHAR(MAX)	NULL
)

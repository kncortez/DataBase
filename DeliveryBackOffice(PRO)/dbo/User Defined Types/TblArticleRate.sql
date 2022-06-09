CREATE TYPE [dbo].[TblArticleRate] AS TABLE (
    [IdArticle] INT             NULL,
    [Segment]   VARCHAR (10)    NULL,
    [Rate]      DECIMAL (12, 2) NULL,
    [Status]    BIT             NULL);


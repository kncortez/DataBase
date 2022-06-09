CREATE TYPE [dbo].[TblChangeList] AS TABLE (
    [RowNumber]    INT             NOT NULL,
    [IdCost]       INT             NULL,
    [Description]  VARCHAR (100)   NULL,
    [Amount]       DECIMAL (18, 2) NULL,
    [ModIdModule]  INT             NULL,
    [RowStatus]    BIT             NULL,
    [TokenCreated] VARCHAR (50)    NULL);


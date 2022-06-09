CREATE TYPE [dbo].[TblCODList] AS TABLE (
    [RowNumber]                     INT            NOT NULL,
    [Id]                            INT            NULL,
    [IdAccount]                     INT            NULL,
    [IdBank]                        INT            NULL,
    [NameAccount]                   NVARCHAR (200) NULL,
    [TypeAccount]                   NVARCHAR (10)  NULL,
    [DocID]                         NVARCHAR (20)  NULL,
    [Alias]                         NVARCHAR (100) NULL,
    [Token]                         NVARCHAR (100) NULL,
    [TokenUpdate]                   NVARCHAR (100) NULL,
    [NumberAcc]                     NVARCHAR (100) NULL,
    [Status]                        INT            NULL,
    [IdVisitPointByClientPortfolio] INT            NULL);


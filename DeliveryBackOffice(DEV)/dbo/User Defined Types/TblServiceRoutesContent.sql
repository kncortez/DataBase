CREATE TYPE [dbo].[TblServiceRoutesContent] AS TABLE (
    [IdTblServiceRoutesContent] INT             NOT NULL,
    [TblServiceRoutesId]        INT             NOT NULL,
    [Code]                      NVARCHAR (100)  NULL,
    [Description]               NVARCHAR (500)  NULL,
    [Price]                     DECIMAL (18, 2) NULL,
    PRIMARY KEY CLUSTERED ([IdTblServiceRoutesContent] ASC));


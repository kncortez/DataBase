CREATE TYPE [dbo].[TblBillingList] AS TABLE (
    [RowNumber]                     INT            NOT NULL,
    [IdBilling]                     INT            NULL,
    [IdAccount]                     INT            NULL,
    [Name]                          NVARCHAR (100) NULL,
    [Address]                       NVARCHAR (600) NULL,
    [TaxId]                         NVARCHAR (100) NULL,
    [Status]                        INT            NULL,
    [Token]                         NVARCHAR (150) NULL,
    [IdVisitPointByClientPortfolio] INT            NULL);


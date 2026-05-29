CREATE TABLE [dbo].[FEB202602LOTE5_DETALLE] (
    [inv_pk_id]       INT             NULL,
    [DocNum]          INT             NULL,
    [LineNum]         INT             NOT NULL,
    [ItemCode]        VARCHAR (50)    NULL,
    [ItemDescription] VARCHAR (200)   NULL,
    [Quantity]        DECIMAL (10, 5) NULL,
    [PriceAfterVAT]   MONEY           NULL,
    [Currency]        VARCHAR (5)     NULL,
    [SalesPersonCode] INT             NULL,
    [CostingCode]     VARCHAR (20)    NULL,
    [TaxCode]         VARCHAR (10)    NULL,
    [CostingCode2]    VARCHAR (20)    NULL
);


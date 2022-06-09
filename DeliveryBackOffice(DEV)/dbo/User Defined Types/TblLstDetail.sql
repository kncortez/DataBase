CREATE TYPE [dbo].[TblLstDetail] AS TABLE (
    [orderSerie]     NVARCHAR (2)    NULL,
    [orderNumber]    INT             NULL,
    [identification] VARCHAR (200)   NULL,
    [category]       VARCHAR (50)    NULL,
    [quantity]       DECIMAL (10, 5) NULL,
    [measurement]    VARCHAR (20)    NULL,
    [priceUnit]      MONEY           NULL,
    [description]    VARCHAR (MAX)   NULL,
    [IVA]            MONEY           NULL,
    [amount]         MONEY           NULL,
    [SAPCode]        VARCHAR (50)    NULL,
    [SendToInvoice]  BIT             NULL);


CREATE TYPE [dbo].[TblPaymentList] AS TABLE (
    [RowNumber]     INT             NOT NULL,
    [IdTypeOfMoney] INT             NULL,
    [Voucher]       VARCHAR (100)   NULL,
    [Amount]        DECIMAL (18, 2) NULL,
    [Responsible]   NVARCHAR (100)  NULL);


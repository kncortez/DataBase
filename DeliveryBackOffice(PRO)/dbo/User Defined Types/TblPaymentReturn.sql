CREATE TYPE [dbo].[TblPaymentReturn] AS TABLE (
    [RowNumber] INT             NOT NULL,
    [IdPayment] INT             NULL,
    [Amount]    DECIMAL (14, 2) NULL,
    [Voucher]   NVARCHAR (25)   NULL);


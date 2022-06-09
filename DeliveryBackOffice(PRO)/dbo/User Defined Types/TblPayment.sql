CREATE TYPE [dbo].[TblPayment] AS TABLE (
    [RowNumber]     INT             NOT NULL,
    [IdTypePay]     INT             NULL,
    [Voucher]       VARCHAR (100)   NULL,
    [ServiceAmount] DECIMAL (18, 2) NULL,
    [CODAmount]     DECIMAL (18, 2) NULL);


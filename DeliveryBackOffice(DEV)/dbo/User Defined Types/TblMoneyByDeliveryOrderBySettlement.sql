CREATE TYPE [dbo].[TblMoneyByDeliveryOrderBySettlement] AS TABLE (
    [IdCatMoney]   INT             NOT NULL,
    [Denomination] DECIMAL (8, 2)  NULL,
    [Quantity]     INT             NOT NULL,
    [Total]        DECIMAL (14, 2) NULL);


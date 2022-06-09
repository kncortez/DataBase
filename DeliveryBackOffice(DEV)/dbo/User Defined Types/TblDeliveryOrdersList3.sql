CREATE TYPE [dbo].[TblDeliveryOrdersList3] AS TABLE (
    [Guide_Serie]        NVARCHAR (2)    NULL,
    [Guide_Number]       INT             NULL,
    [TypeofInOutMoneyId] INT             NULL,
    [amount]             DECIMAL (14, 2) NULL,
    [TokenCreated]       VARCHAR (100)   NULL,
    [IdTypeService]      INT             NULL,
    [AccountId]          INT             NULL);


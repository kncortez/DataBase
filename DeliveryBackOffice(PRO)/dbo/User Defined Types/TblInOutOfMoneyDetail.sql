CREATE TYPE [dbo].[TblInOutOfMoneyDetail] AS TABLE (
    [type]               VARCHAR (200) NULL,
    [vpCodeOfReferences] INT           NULL,
    [ticket]             VARCHAR (100) NULL,
    [amount]             MONEY         NULL,
    [status]             INT           NULL,
    [invoice]            BIGINT        NULL);


CREATE TABLE [dbo].[DeliveryOrderPaidTemp] (
    [IdDeliveryOrderPaid]       BIGINT        IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Guide_Serie]               NVARCHAR (2)  NULL,
    [Guide_Number]              INT           NULL,
    [Deposit_Number]            NVARCHAR (50) NULL,
    [IsVirtualDeposit]          BIT           NULL,
    [IdStatus]                  BIT           NULL,
    [TokenCreated]              NVARCHAR (50) NULL,
    [DateCreated]               DATETIME      NULL,
    [TokenUpdate]               NVARCHAR (50) NULL,
    [DateUpdate]                DATETIME      NULL,
    [IdDeliveryOrderPaidHeader] BIGINT        NULL,
    [DocumentType]              INT           NULL,
    CONSTRAINT [PK_DeliveryOrderPaid_temp] PRIMARY KEY CLUSTERED ([IdDeliveryOrderPaid] ASC)
);


CREATE TABLE [dbo].[DeliveryOrderPaidHeader] (
    [IdDeliveryOrderPaid] BIGINT       IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Manifest_Date]       DATETIME     NULL,
    [Manifest_Serie]      NVARCHAR (5) NULL,
    [Manifest_Number]     BIGINT       NULL,
    [IdStatus]            BIT          NULL,
    CONSTRAINT [PK_DeliveryOrderPaidHeader] PRIMARY KEY CLUSTERED ([IdDeliveryOrderPaid] ASC)
);

